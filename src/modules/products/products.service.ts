import {
  Injectable,
  NotFoundException,
  Inject,
  forwardRef,
} from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository, Like, ILike } from "typeorm";
import { Product } from "./entities/product.entity";
import {
  TemporaryProduct,
  TemporaryProductStatus,
} from "./entities/temporary-product.entity";
import { CreateProductDto } from "./dto/create-product.dto";
import { UpdateProductDto } from "./dto/update-product.dto";
import { CreateTemporaryProductDto } from "./dto/create-temporary-product.dto";
import { UpdateTemporaryProductDto } from "./dto/update-temporary-product.dto";
import { ProductUpdateTasksService } from "./product-update-tasks.service";
import { ChangeType, AssignedRole } from "./entities/product-update-task.entity";
import { NotificationsService } from "../notifications/notifications.service";
import { NotificationType } from "../notifications/entities/notification.entity";
import { User, UserRole } from "../users/entities/user.entity";

@Injectable()
export class ProductsService {
  constructor(
    @InjectRepository(Product)
    private productsRepository: Repository<Product>,
    @InjectRepository(TemporaryProduct)
    private temporaryProductsRepository: Repository<TemporaryProduct>,
    @InjectRepository(User)
    private usersRepository: Repository<User>,
    @Inject(forwardRef(() => ProductUpdateTasksService))
    private readonly tasksService: ProductUpdateTasksService,
    @Inject(forwardRef(() => NotificationsService))
    private readonly notificationsService: NotificationsService
  ) {}

  async create(createProductDto: CreateProductDto): Promise<Product> {
    const product = this.productsRepository.create(createProductDto);
    return this.productsRepository.save(product);
  }

  /**
   * Create product from admin with supervisor task
   * Creates a product and a temporary_product task for supervisor review
   */
  async createProductWithSupervisorTask(
    createProductDto: CreateProductDto,
    adminId: string
  ): Promise<{ product: Product; temporaryProduct: TemporaryProduct }> {
    console.log('🎯 Creating product with supervisor task:', {
      description: createProductDto.description,
      hasBarcode: !!createProductDto.barcode,
      adminId,
    });

    // 1. Create the product in products table
    const product = this.productsRepository.create({
      ...createProductDto,
      barcode: createProductDto.barcode || null, // null if not provided
      isActive: true,
    });
    const savedProduct = await this.productsRepository.save(product);

    console.log('✅ Product created:', savedProduct.id);

    // 2. Create temporary_product for supervisor review
    const temporaryProduct = this.temporaryProductsRepository.create({
      name: savedProduct.description,
      description: savedProduct.description,
      barcode: savedProduct.barcode,
      precioA: savedProduct.precioA,
      precioB: savedProduct.precioB,
      precioC: savedProduct.precioC,
      costo: savedProduct.costo,
      iva: savedProduct.iva,
      productId: savedProduct.id, // Link to the created product
      status: TemporaryProductStatus.PENDING_SUPERVISOR,
      createdBy: adminId,
      completedByAdmin: adminId, // Admin created it
      completedByAdminAt: new Date(),
      isActive: true,
    });

    const savedTemporaryProduct = await this.temporaryProductsRepository.save(
      temporaryProduct
    );

    console.log('✅ Temporary product created for supervisor:', savedTemporaryProduct.id);

    // 3. Notify supervisors AND digitadores (productos nuevos van a ambos roles)
    const recipients = await this.usersRepository.find({
      where: [
        { role: UserRole.SUPERVISOR, isActive: true },
        { role: UserRole.DIGITADOR, isActive: true },
      ],
    });

    console.log(`📣 Notifying ${recipients.length} recipient(s) about new product`);

    const hasBarcode = savedProduct.barcode && savedProduct.barcode.trim();
    const barcodeMessage = hasBarcode
      ? `Código de barras: ${savedProduct.barcode}`
      : '⚠️ Sin código de barras - Debe agregarlo';

    const detailedMessage = `Se creó un nuevo producto "${savedProduct.description}".\n\n` +
      `${barcodeMessage}\n` +
      `Precio A: $${Number(savedProduct.precioA).toFixed(2)}\n` +
      `IVA: ${savedProduct.iva}%\n\n` +
      `Por favor, revise el producto${!hasBarcode ? ' y agregue el código de barras' : ''}.`;

    const notificationPromises = recipients.map((recipient) =>
      this.notificationsService.createNotification(
        recipient.id,
        'Nuevo producto creado - Requiere revisión',
        detailedMessage,
        NotificationType.TEMPORARY_PRODUCT_PENDING_SUPERVISOR,
        undefined,
        undefined,
        savedTemporaryProduct.id
      )
    );

    await Promise.all(notificationPromises);

    console.log('✅ Notifications sent to supervisors and digitadores');

    // Reload with relations
    const reloadedTemporaryProduct = await this.temporaryProductsRepository.findOne({
      where: { id: savedTemporaryProduct.id },
      relations: ['completedByAdminUser', 'completedBySupervisorUser'],
    });

    return {
      product: savedProduct,
      temporaryProduct: reloadedTemporaryProduct,
    };
  }

  async findAll(
    search?: string,
    page?: number,
    limit?: number
  ): Promise<Product[]> {
    console.log('📊 ProductsService.findAll called with:', { search, page, limit, types: { page: typeof page, limit: typeof limit } });

    if (search && search.trim().length > 0) {
      return this.searchProducts(search, page || 0, limit || 20);
    }

    const queryOptions = {
      where: { isActive: true },
      order: { createdAt: "DESC" as const },
      skip: page !== undefined ? page * (limit || 20) : undefined,
      take: limit !== undefined ? limit : undefined,
    };

    console.log('📊 Query options:', JSON.stringify(queryOptions, null, 2));

    try {
      const results = await this.productsRepository.find(queryOptions);
      console.log(`✅ Found ${results.length} products`);
      return results;
    } catch (error) {
      console.error('❌ Database query error in findAll:', error);
      console.error('Error details:', {
        message: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : undefined,
      });
      throw error;
    }
  }

  async findOne(id: string): Promise<Product> {
    const product = await this.productsRepository.findOne({
      where: { id, isActive: true },
    });

    if (!product) {
      throw new NotFoundException(`Product with ID ${id} not found`);
    }

    return product;
  }

  /// Find product by ID for admin operations (includes inactive products)
  async findOneForAdmin(id: string): Promise<Product> {
    const product = await this.productsRepository.findOne({
      where: { id },
    });

    if (!product) {
      throw new NotFoundException(`Product with ID ${id} not found`);
    }

    return product;
  }

  async update(
    id: string,
    updateProductDto: UpdateProductDto,
    updatedById?: string,
    adminNotes?: string
  ): Promise<Product> {
    console.log("🔄 ProductsService.update called with:", {
      id,
      updateProductDto,
      updatedById,
    });
    console.log(
      "🔍 BACKEND: Received updateProductDto keys:",
      Object.keys(updateProductDto)
    );
    console.log(
      "🔍 BACKEND: Received updateProductDto values:",
      Object.values(updateProductDto)
    );
    console.log(
      "🔍 BACKEND: IVA in updateProductDto?",
      "iva" in updateProductDto
    );
    console.log("🔍 BACKEND: IVA value:", updateProductDto.iva);

    // For updates, we should allow updating both active and inactive products
    console.log("🔍 Searching for product with ID:", id);
    const product = await this.productsRepository.findOne({
      where: { id },
    });

    console.log("🔍 Found product:", product ? "YES" : "NO");
    if (product) {
      console.log("📊 Product details:", {
        id: product.id,
        description: product.description,
        isActive: product.isActive,
        currentIva: product.iva,
      });
    }

    if (!product) {
      console.log("❌ Product not found with ID:", id);
      throw new NotFoundException(`Product with ID ${id} not found`);
    }

    // Store old values for task creation
    const oldValues = {
      precioA: product.precioA,
      precioB: product.precioB,
      precioC: product.precioC,
      costo: product.costo,
      iva: product.iva,
      description: product.description,
      barcode: product.barcode,
    };

    console.log("✏️ Updating product with data:", updateProductDto);
    console.log("🔍 BEFORE update - product.iva:", product.iva);

    // CRITICAL FIX: Use TypeORM's update() method instead of save() to only update specified fields
    // This prevents any default values from being applied to fields that are not being updated
    await this.productsRepository.update(id, updateProductDto);

    console.log("💾 Product updated successfully");

    // Reload the product to get the updated values
    const savedProduct = await this.productsRepository.findOne({
      where: { id },
    });

    if (!savedProduct) {
      throw new NotFoundException(
        `Product with ID ${id} not found after update`
      );
    }

    console.log("✅ Product reloaded successfully:", savedProduct.id);
    console.log("✅ Saved product IVA:", savedProduct.iva);

    // Create task for supervisors if there are price or info changes and we have an updatedById
    if (updatedById) {
      try {
        await this.createUpdateTask(
          oldValues,
          updateProductDto,
          savedProduct,
          updatedById,
          adminNotes
        );
      } catch (error) {
        console.error("⚠️ Failed to create update task:", error);
        // Don't fail the product update if task creation fails
      }
    }

    return savedProduct;
  }

  /**
   * Detecta cambios y crea las tareas necesarias por edición de producto.
   *
   * Reglas de ruteo:
   *   • Supervisor: SOLO recibe tarea cuando cambia el precio.
   *     Una única tarea PRICE con la lista de campos modificados (precioA, precioB, etc).
   *
   *   • Digitador: recibe UNA tarea agrupada por edición que consolida TODOS los cambios
   *     que le corresponden (precio, nombre, IVA, barcode). El changeType refleja el
   *     contenido:
   *       - 1 solo cambio → tipo específico (PRICE / NAME / IVA / BARCODE)
   *       - múltiples cambios → tipo INFO con descripción que lista cada campo
   *
   * Las tareas son independientes: que supervisor complete la suya no afecta la del
   * digitador y viceversa.
   */
  private async createUpdateTask(
    oldValues: any,
    updateData: UpdateProductDto,
    product: Product,
    updatedById: string,
    adminNotes?: string
  ): Promise<void> {
    const priceFields = ["precioA", "precioB", "precioC", "costo"];

    const priceChanges = priceFields.filter(
      (field) =>
        updateData[field] !== undefined &&
        updateData[field] !== oldValues[field]
    );

    const nameChanged =
      updateData["description"] !== undefined &&
      updateData["description"] !== oldValues["description"];

    const ivaChanged =
      updateData["iva"] !== undefined && updateData["iva"] !== oldValues["iva"];

    const barcodeChanged =
      updateData["barcode"] !== undefined &&
      updateData["barcode"] !== oldValues["barcode"];

    /**
     * Construye payload (oldValue/newValue) restringido a un set de campos.
     * Solo incluye campos que efectivamente cambiaron; el frontend renderiza
     * cada uno en formato "antes → después".
     */
    const buildScopedPayload = (fields: string[]): { oldV: any; newV: any } => {
      const oldV: Record<string, any> = {};
      const newV: Record<string, any> = {};
      for (const f of fields) {
        const before = oldValues?.[f];
        const after = (updateData as any)[f];
        if (after !== undefined && after !== before) {
          oldV[f] = before;
          newV[f] = after;
        }
      }
      return { oldV, newV };
    };

    type TaskSpec = {
      changeType: ChangeType;
      description: string;
      assignedRole: AssignedRole;
      oldValue: any;
      newValue: any;
    };
    const tasksToCreate: TaskSpec[] = [];

    // --- Tarea para SUPERVISOR (solo si cambió precio) ---
    // Payload: SOLO campos de precio (precioA/B/C, costo). Nombre/IVA/barcode
    // pertenecen al digitador y NO deben aparecer en el detalle del supervisor.
    if (priceChanges.length > 0) {
      const { oldV, newV } = buildScopedPayload(priceFields);
      tasksToCreate.push({
        changeType: ChangeType.PRICE,
        description: `Precios: ${priceChanges.join(", ")}`,
        assignedRole: AssignedRole.SUPERVISOR,
        oldValue: oldV,
        newValue: newV,
      });
    }

    // --- Tarea agrupada para DIGITADOR ---
    // Acumula cada cambio que le corresponde con su tipo y descripción legible.
    type DigitadorChange = { type: ChangeType; description: string };
    const digitadorChanges: DigitadorChange[] = [];

    if (priceChanges.length > 0) {
      digitadorChanges.push({
        type: ChangeType.PRICE,
        description: `Precios (${priceChanges.join(", ")})`,
      });
    }
    if (nameChanged) {
      digitadorChanges.push({
        type: ChangeType.NAME,
        description: `Nombre del producto`,
      });
    }
    if (ivaChanged) {
      digitadorChanges.push({
        type: ChangeType.IVA,
        description: `IVA (${oldValues["iva"]}% → ${updateData["iva"]}%)`,
      });
    }
    if (barcodeChanged) {
      const oldBarcode = oldValues["barcode"] || "sin código";
      const newBarcode = updateData["barcode"] || "sin código";
      digitadorChanges.push({
        type: ChangeType.BARCODE,
        description: `Código de barras (${oldBarcode} → ${newBarcode})`,
      });
    }

    if (digitadorChanges.length > 0) {
      // Si solo hay 1 cambio, usar su tipo específico. Si hay varios, usar INFO
      // (representa "edición con múltiples cambios" — la descripción los detalla).
      const groupedType =
        digitadorChanges.length === 1 ? digitadorChanges[0].type : ChangeType.INFO;
      const groupedDescription = digitadorChanges
        .map((c) => c.description)
        .join(", ");

      // Payload: campos del digitador (precios + nombre/description + IVA + barcode)
      const { oldV, newV } = buildScopedPayload([
        ...priceFields,
        "description",
        "iva",
        "barcode",
      ]);

      tasksToCreate.push({
        changeType: groupedType,
        description: groupedDescription,
        assignedRole: AssignedRole.DIGITADOR,
        oldValue: oldV,
        newValue: newV,
      });
    }

    if (tasksToCreate.length === 0) return;

    console.log(
      `📝 Creating ${tasksToCreate.length} update task(s) for product ${product.id}:`,
      tasksToCreate.map((t) => `${t.changeType}→${t.assignedRole}`).join(", ")
    );

    await Promise.all(
      tasksToCreate.map((spec) =>
        this.tasksService.createTaskForProductUpdate(
          product.id,
          spec.changeType,
          spec.oldValue,
          spec.newValue,
          updatedById,
          spec.description,
          adminNotes,
          spec.assignedRole
        )
      )
    );
  }

  async remove(id: string): Promise<void> {
    const product = await this.findOne(id);
    product.isActive = false;
    await this.productsRepository.save(product);
  }

  async searchProducts(
    query: string,
    page: number = 0,
    limit: number = 20
  ): Promise<Product[]> {
    console.log("searchProducts called with:", { query, page, limit });

    if (!query || query.trim().length === 0) {
      console.log("No query provided, returning all products");
      return this.findAll();
    }

    const searchTerm = query.trim();
    console.log("Searching with term:", searchTerm);

    try {
      // MEJORA 1: Lista de stop words (palabras vacías) en español
      // Estas palabras se ignoran porque son muy comunes y no aportan a la búsqueda
      const stopWords = new Set([
        'de', 'la', 'el', 'y', 'en', 'con', 'para', 'por', 'un', 'una',
        'los', 'las', 'del', 'al', 'o', 'e', 'u', 'a'
      ]);

      // MEJORA 2: Dividir la búsqueda en palabras individuales
      // - Filtra palabras muy cortas (menos de 2 caracteres)
      // - Filtra stop words (palabras vacías)
      // Ejemplo: "CREMA DE LA NUTRIBELA" -> ["CREMA", "NUTRIBELA"]
      const allWords = searchTerm.split(/\s+/);
      const searchWords = allWords.filter(word => {
        const cleanWord = word.toLowerCase();
        // Ignorar palabras de 1 carácter o stop words
        return word.length >= 2 && !stopWords.has(cleanWord);
      });

      console.log("🔍 Palabras originales:", allWords);
      console.log("✨ Palabras filtradas para búsqueda:", searchWords);

      // Si después de filtrar no quedan palabras, usar la búsqueda original
      if (searchWords.length === 0) {
        console.log("⚠️ No hay palabras válidas después de filtrar, usando término completo");
        searchWords.push(searchTerm);
      }

      const queryBuilder = this.productsRepository
        .createQueryBuilder('product')
        .where('product.isActive = :isActive', { isActive: true });

      // Cada palabra debe aparecer en la descripción O en el código de barras
      // Esto permite búsquedas parciales como:
      // - "CREMA NUTRIBELA" encuentra "CREMA DE PEINAR NUTRIBELA"
      // - "PEINAR 300ml" encuentra "CREMA DE PEINAR NUTRIBELA 300ml"
      searchWords.forEach((word, index) => {
        const paramName = `searchWord${index}`;
        queryBuilder.andWhere(
          `(
            translate(LOWER(product.description), 'áéíóúàèìòùäëïöüâêîôûãõñçÁÉÍÓÚÀÈÌÒÙÄËÏÖÜÂÊÎÔÛÃÕÑÇ', 'aeiouaeiouaeiouaeiouaoncAEIOUAEIOUAEIOUAEIOUAONC')
            LIKE
            translate(LOWER(:${paramName}), 'áéíóúàèìòùäëïöüâêîôûãõñçÁÉÍÓÚÀÈÌÒÙÄËÏÖÜÂÊÎÔÛÃÕÑÇ', 'aeiouaeiouaeiouaeiouaoncAEIOUAEIOUAEIOUAEIOUAONC')
            OR
            translate(LOWER(product.barcode), 'áéíóúàèìòùäëïöüâêîôûãõñçÁÉÍÓÚÀÈÌÒÙÄËÏÖÜÂÊÎÔÛÃÕÑÇ', 'aeiouaeiouaeiouaeiouaoncAEIOUAEIOUAEIOUAEIOUAONC')
            LIKE
            translate(LOWER(:${paramName}), 'áéíóúàèìòùäëïöüâêîôûãõñçÁÉÍÓÚÀÈÌÒÙÄËÏÖÜÂÊÎÔÛÃÕÑÇ', 'aeiouaeiouaeiouaeiouaoncAEIOUAEIOUAEIOUAEIOUAONC')
          )`,
          { [paramName]: `%${word}%` }
        );
      });

      // MEJORA: Calcular score de relevancia
      // Prioridad:
      // 1. Código de barras exacto (1000 puntos)
      // 2. Código de barras que empieza con la búsqueda (900 puntos)
      // 3. Cada palabra encontrada suma puntos (primeras palabras valen más)
      let selectScore = `
        CASE
          WHEN product.barcode = :exactBarcode THEN 1000
          WHEN LOWER(product.barcode) LIKE LOWER(:firstWordExact) THEN 900
          ELSE 0
        END`;

      // Cada palabra encontrada suma puntos (decreciente)
      searchWords.forEach((word, index) => {
        selectScore += ` +
        CASE
          WHEN translate(LOWER(product.description), 'áéíóúàèìòùäëïöüâêîôûãõñçÁÉÍÓÚÀÈÌÒÙÄËÏÖÜÂÊÎÔÛÃÕÑÇ', 'aeiouaeiouaeiouaeiouaoncAEIOUAEIOUAEIOUAONC')
               LIKE translate(LOWER(:scoreWord${index}), 'áéíóúàèìòùäëïöüâêîôûãõñçÁÉÍÓÚÀÈÌÒÙÄËÏÖÜÂÊÎÔÛÃÕÑÇ', 'aeiouaeiouaeiouaeiouaoncAEIOUAEIOUAEIOUAEIOUAONC')
          THEN ${10 - index}
          ELSE 0
        END`;
      });

      queryBuilder.addSelect(`(${selectScore})`, 'relevance_score');

      // Parámetros para scoring
      queryBuilder.setParameter('exactBarcode', searchTerm);
      queryBuilder.setParameter('firstWordExact', `${searchWords[0]}%`);
      searchWords.forEach((word, index) => {
        queryBuilder.setParameter(`scoreWord${index}`, `%${word}%`);
      });

      // Ordenar por relevancia primero, luego por fecha
      queryBuilder.orderBy('relevance_score', 'DESC');
      queryBuilder.addOrderBy('product.createdAt', 'DESC');

      // Paginación
      queryBuilder.skip(page * limit);
      queryBuilder.take(limit);

      const result = await queryBuilder.getMany();

      console.log("✅ Resultados encontrados:", result.length);
      if (result.length > 0) {
        console.log("📦 Primeros 3 resultados:", result.slice(0, 3).map(p => ({
          description: p.description,
          barcode: p.barcode
        })));
      }

      return result;
    } catch (error) {
      console.error("❌ Error en búsqueda:", error);
      throw error;
    }
  }

  // Temporary Products Methods

  async createTemporaryProduct(
    dto: CreateTemporaryProductDto
  ): Promise<TemporaryProduct> {
    const temporaryProduct = this.temporaryProductsRepository.create({
      ...dto,
      status: TemporaryProductStatus.PENDING_ADMIN,
    });
    const savedProduct = await this.temporaryProductsRepository.save(
      temporaryProduct
    );

    // Notificar a todos los administradores
    const admins = await this.usersRepository.find({
      where: { role: UserRole.ADMIN, isActive: true },
    });

    const notificationPromises = admins.map((admin) =>
      this.notificationsService.createNotification(
        admin.id,
        "Nuevo producto temporal",
        `Se ha creado un producto temporal "${savedProduct.name}". Necesita completar los precios e IVA cuando el producto llegue.`,
        NotificationType.TEMPORARY_PRODUCT_PENDING_ADMIN,
        undefined,
        undefined,
        savedProduct.id
      )
    );

    await Promise.all(notificationPromises);

    return savedProduct;
  }

  async findAllTemporaryProducts(): Promise<TemporaryProduct[]> {
    return this.temporaryProductsRepository.find({
      order: { createdAt: "DESC" },
      relations: ['completedByAdminUser', 'completedBySupervisorUser'],
    });
  }

  async updateTemporaryProduct(
    id: string,
    dto: UpdateTemporaryProductDto,
    adminId: string
  ): Promise<TemporaryProduct> {
    const temporaryProduct = await this.findTemporaryProduct(id);

    // Actualizar los campos del producto
    Object.assign(temporaryProduct, dto);

    // Si se completaron todos los campos requeridos, cambiar estado a pending_supervisor
    const hasAllRequiredFields =
      temporaryProduct.precioA !== null &&
      temporaryProduct.precioA !== undefined &&
      temporaryProduct.iva !== null &&
      temporaryProduct.iva !== undefined;

    if (
      hasAllRequiredFields &&
      temporaryProduct.status === TemporaryProductStatus.PENDING_ADMIN
    ) {
      temporaryProduct.status = TemporaryProductStatus.PENDING_SUPERVISOR;
      temporaryProduct.completedByAdmin = adminId;
      temporaryProduct.completedByAdminAt = new Date();

      await this.temporaryProductsRepository.save(temporaryProduct);

      // Reload product with user relations
      const savedProduct = await this.temporaryProductsRepository.findOne({
        where: { id: temporaryProduct.id },
        relations: ['completedByAdminUser', 'completedBySupervisorUser'],
      });

      // Notificar a supervisores Y digitadores con los detalles de precios e IVA
      const supervisors = await this.usersRepository.find({
        where: [
          { role: UserRole.SUPERVISOR, isActive: true },
          { role: UserRole.DIGITADOR, isActive: true },
        ],
      });

      // Construir mensaje detallado con precios e IVA
      const priceDetails = [];
      if (savedProduct.precioA !== null && savedProduct.precioA !== undefined) {
        priceDetails.push(`Precio A: $${Number(savedProduct.precioA).toFixed(2)}`);
      }
      if (savedProduct.precioB !== null && savedProduct.precioB !== undefined) {
        priceDetails.push(`Precio B: $${Number(savedProduct.precioB).toFixed(2)}`);
      }
      if (savedProduct.precioC !== null && savedProduct.precioC !== undefined) {
        priceDetails.push(`Precio C: $${Number(savedProduct.precioC).toFixed(2)}`);
      }
      if (savedProduct.costo !== null && savedProduct.costo !== undefined) {
        priceDetails.push(`Costo: $${Number(savedProduct.costo).toFixed(2)}`);
      }

      const ivaText =
        savedProduct.iva !== null && savedProduct.iva !== undefined
          ? `IVA: ${savedProduct.iva}%`
          : "";

      const detailedMessage = `El producto temporal "${
        savedProduct.name
      }" ha sido completado por el administrador.\n\nDetalles:\n${priceDetails.join(
        "\n"
      )}\n${ivaText}\n\nPor favor, revise y aplique en el sistema externo.`;

      const notificationPromises = supervisors.map((supervisor) =>
        this.notificationsService.createNotification(
          supervisor.id,
          "Producto temporal listo para revisión",
          detailedMessage,
          NotificationType.TEMPORARY_PRODUCT_PENDING_SUPERVISOR,
          undefined,
          undefined,
          savedProduct.id
        )
      );

      await Promise.all(notificationPromises);

      return savedProduct;
    }

    await this.temporaryProductsRepository.save(temporaryProduct);

    // Reload with user relations
    return this.temporaryProductsRepository.findOne({
      where: { id: temporaryProduct.id },
      relations: ['completedByAdminUser', 'completedBySupervisorUser'],
    });
  }

  async findTemporaryProduct(id: string): Promise<TemporaryProduct> {
    const temporaryProduct = await this.temporaryProductsRepository.findOne({
      where: { id },
    });

    if (!temporaryProduct) {
      throw new NotFoundException(`Temporary product with ID ${id} not found`);
    }

    return temporaryProduct;
  }

  async cancelTemporaryProduct(
    id: string,
    adminId: string,
    reason?: string
  ): Promise<TemporaryProduct> {
    const temporaryProduct = await this.findTemporaryProduct(id);

    if (temporaryProduct.status !== TemporaryProductStatus.PENDING_ADMIN) {
      throw new NotFoundException(
        `Solo se pueden cancelar productos temporales en estado pending_admin`
      );
    }

    temporaryProduct.status = TemporaryProductStatus.CANCELLED;
    temporaryProduct.completedByAdmin = adminId;
    temporaryProduct.completedByAdminAt = new Date();
    if (reason) {
      temporaryProduct.notes = temporaryProduct.notes
        ? `${temporaryProduct.notes}\n\nCancelado: ${reason}`
        : `Cancelado: ${reason}`;
    }

    return await this.temporaryProductsRepository.save(temporaryProduct);
  }

  async completeTemporaryProductBySupervisor(
    id: string,
    supervisorId: string,
    notes?: string,
    barcode?: string
  ): Promise<TemporaryProduct> {
    const temporaryProduct = await this.findTemporaryProduct(id);

    if (temporaryProduct.status !== TemporaryProductStatus.PENDING_SUPERVISOR) {
      throw new NotFoundException(
        `Solo se pueden completar productos temporales en estado pending_supervisor`
      );
    }

    console.log('📦 Completing temporary product by supervisor:', {
      id,
      name: temporaryProduct.name,
      providedBarcode: barcode,
      existingBarcode: temporaryProduct.barcode,
    });

    // Si se proporciona un barcode, actualizar el campo barcode del producto temporal
    if (barcode && barcode.trim()) {
      console.log('🔍 Updating barcode from', temporaryProduct.barcode, 'to', barcode.trim());
      temporaryProduct.barcode = barcode.trim();
    }

    // Crear automáticamente el producto en la tabla products usando los datos del temporary product
    console.log('🚀 Auto-registering product in products table...');

    const newProduct = this.productsRepository.create({
      description: temporaryProduct.name, // El nombre del temporal es la descripción del producto
      barcode: temporaryProduct.barcode || '', // Usar el barcode actualizado o vacío si no hay
      precioA: temporaryProduct.precioA || 0,
      precioB: temporaryProduct.precioB || 0,
      precioC: temporaryProduct.precioC || 0,
      costo: temporaryProduct.costo || 0,
      iva: temporaryProduct.iva || 0,
      isActive: true,
    });

    const savedRealProduct = await this.productsRepository.save(newProduct);

    console.log('✅ Product auto-registered successfully:', {
      productId: savedRealProduct.id,
      description: savedRealProduct.description,
      barcode: savedRealProduct.barcode,
    });

    // Guardar el productId en el producto temporal
    temporaryProduct.productId = savedRealProduct.id;

    // Marcar como completado por supervisor
    temporaryProduct.status = TemporaryProductStatus.COMPLETED;
    temporaryProduct.completedBySupervisor = supervisorId;
    temporaryProduct.completedBySupervisorAt = new Date();

    // Agregar notas del supervisor si las hay
    if (notes) {
      temporaryProduct.notes = temporaryProduct.notes
        ? `${temporaryProduct.notes}\n\nNota del supervisor: ${notes}`
        : `Nota del supervisor: ${notes}`;
    }

    await this.temporaryProductsRepository.save(temporaryProduct);

    // Reload product with user relations
    const savedProduct = await this.temporaryProductsRepository.findOne({
      where: { id: temporaryProduct.id },
      relations: ['completedByAdminUser', 'completedBySupervisorUser'],
    });

    console.log('✅ Producto temporal completado:', {
      id: savedProduct.id,
      name: savedProduct.name,
      completedBySupervisor: savedProduct.completedBySupervisor,
      hasCompletedBySupervisorUser: !!savedProduct.completedBySupervisorUser,
      username: savedProduct.completedBySupervisorUser?.username,
    });

    // Notificar al admin que creó el producto temporal
    await this.notificationsService.createNotification(
      temporaryProduct.createdBy,
      "Producto Nuevo Registrado y completado",
      `El producto "${savedProduct.name}" ha sido registrado por el supervisor como aplicado correctamente en el sistema.`,
      NotificationType.TEMPORARY_PRODUCT_COMPLETED,
      undefined,
      undefined,
      savedProduct.id
    );

    return savedProduct;
  }

  /**
   * Update barcode of existing product when supervisor completes task
   * This is for when admin creates a product WITHOUT barcode
   * and supervisor adds it during review
   */
  async updateProductBarcodeFromTemporary(
    temporaryProductId: string,
    supervisorId: string,
    barcode: string,
    notes?: string
  ): Promise<{ product: Product; temporaryProduct: TemporaryProduct }> {
    console.log('🔄 Updating product barcode from temporary:', {
      temporaryProductId,
      supervisorId,
      barcode,
    });

    // 1. Find the temporary product
    const temporaryProduct = await this.findTemporaryProduct(temporaryProductId);

    // 2. Check if it has a linked real product
    if (!temporaryProduct.productId) {
      throw new NotFoundException(
        'This temporary product is not linked to a real product. Use completeTemporaryProductBySupervisor instead.'
      );
    }

    // 3. Find the real product
    const product = await this.productsRepository.findOne({
      where: { id: temporaryProduct.productId },
    });

    if (!product) {
      throw new NotFoundException(
        `Product with ID ${temporaryProduct.productId} not found`
      );
    }

    console.log('📦 Found product to update:', {
      id: product.id,
      description: product.description,
      currentBarcode: product.barcode,
      newBarcode: barcode,
    });

    // 4. Update the product's barcode
    product.barcode = barcode.trim();
    const updatedProduct = await this.productsRepository.save(product);

    console.log('✅ Product barcode updated successfully');

    // 5. Mark temporary product as completed by supervisor
    temporaryProduct.status = TemporaryProductStatus.COMPLETED;
    temporaryProduct.completedBySupervisor = supervisorId;
    temporaryProduct.completedBySupervisorAt = new Date();
    temporaryProduct.barcode = barcode.trim(); // Update barcode in temporary too

    // Add notes if provided
    if (notes && notes.trim()) {
      temporaryProduct.notes = temporaryProduct.notes
        ? `${temporaryProduct.notes}\n\nNota del supervisor: ${notes}`
        : `Nota del supervisor: ${notes}`;
    }

    await this.temporaryProductsRepository.save(temporaryProduct);

    // 6. Reload both with relations
    const savedTemporary = await this.temporaryProductsRepository.findOne({
      where: { id: temporaryProduct.id },
      relations: ['completedByAdminUser', 'completedBySupervisorUser'],
    });

    console.log('✅ Temporary product completed:', {
      id: savedTemporary.id,
      name: savedTemporary.name,
      productId: savedTemporary.productId,
    });

    // 7. Notify the admin who created it
    await this.notificationsService.createNotification(
      temporaryProduct.createdBy,
      "Código de Barras Agregado",
      `El supervisor agregó el código de barras "${barcode}" al producto "${product.description}".`,
      NotificationType.TEMPORARY_PRODUCT_COMPLETED,
      product.id,
      undefined,
      savedTemporary.id
    );

    return { product: updatedProduct, temporaryProduct: savedTemporary };
  }

  /**
   * Update barcode of an existing product (for products table, not temporary_products)
   * This is used when admin creates a product directly in products table WITHOUT barcode
   * and supervisor adds it when completing the task
   */
  async updateProductBarcode(
    productId: string,
    barcode: string,
    supervisorId: string,
  ): Promise<Product> {
    console.log('🔄 Updating product barcode directly in products table:', {
      productId,
      barcode,
      supervisorId,
    });

    // Find the product in products table
    const product = await this.productsRepository.findOne({
      where: { id: productId },
    });

    if (!product) {
      throw new NotFoundException(`Product with ID ${productId} not found`);
    }

    console.log('📦 Found product to update:', {
      id: product.id,
      description: product.description,
      currentBarcode: product.barcode,
      newBarcode: barcode,
    });

    // Update the product's barcode
    product.barcode = barcode.trim();
    const updatedProduct = await this.productsRepository.save(product);

    console.log('✅ Product barcode updated successfully in products table');

    // Find temporary_product linked to this product (if exists)
    const temporaryProduct = await this.temporaryProductsRepository.findOne({
      where: {
        productId: productId,
        status: TemporaryProductStatus.PENDING_SUPERVISOR,
      },
    });

    if (temporaryProduct) {
      console.log('📋 Found temporary product to complete:', temporaryProduct.id);

      // Mark temporary product as completed
      temporaryProduct.status = TemporaryProductStatus.COMPLETED;
      temporaryProduct.completedBySupervisor = supervisorId;
      temporaryProduct.completedBySupervisorAt = new Date();
      temporaryProduct.barcode = barcode.trim(); // Update barcode in temp product too

      await this.temporaryProductsRepository.save(temporaryProduct);
      console.log('✅ Temporary product marked as completed');
    } else {
      console.log('ℹ️ No temporary product found for this product');
    }

    // Find and complete all pending tasks for this product
    const pendingTasks = await this.tasksService.getPendingTasksByProductId(productId);

    if (pendingTasks && pendingTasks.length > 0) {
      console.log(`📝 Found ${pendingTasks.length} pending task(s) to complete`);

      for (const task of pendingTasks) {
        try {
          await this.tasksService.completeTask(
            task.id,
            { notes: `Código de barras agregado: ${barcode}` },
            supervisorId,
          );
          console.log(`✅ Task ${task.id} completed`);
        } catch (error) {
          console.error(`⚠️ Failed to complete task ${task.id}:`, error);
          // Continue with other tasks even if one fails
        }
      }
    } else {
      console.log('ℹ️ No pending tasks found for this product');
    }

    return updatedProduct;
  }

  async deleteTemporaryProduct(id: string): Promise<void> {
    const result = await this.temporaryProductsRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`Temporary product with ID ${id} not found`);
    }
  }
}
