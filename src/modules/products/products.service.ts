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
import { ChangeType } from "./entities/product-update-task.entity";
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
    updatedById?: string
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
          updatedById
        );
      } catch (error) {
        console.error("⚠️ Failed to create update task:", error);
        // Don't fail the product update if task creation fails
      }
    }

    return savedProduct;
  }

  /// Helper method to create update tasks
  private async createUpdateTask(
    oldValues: any,
    updateData: UpdateProductDto,
    product: Product,
    updatedById: string
  ): Promise<void> {
    const priceFields = ["precioA", "precioB", "precioC", "costo"];

    let hasChanges = false;
    let changeType = ChangeType.INFO;
    let description = "";
    const changeDetails: string[] = [];

    // Check for price changes
    const priceChanges = priceFields.filter(
      (field) =>
        updateData[field] !== undefined &&
        updateData[field] !== oldValues[field]
    );

    // Check for description change
    const descriptionChanged =
      updateData["description"] !== undefined &&
      updateData["description"] !== oldValues["description"];

    // Check for IVA change
    const ivaChanged =
      updateData["iva"] !== undefined && updateData["iva"] !== oldValues["iva"];

    // Build detailed change description
    if (priceChanges.length > 0) {
      hasChanges = true;
      changeType = ChangeType.PRICE;
      changeDetails.push(`Precios: ${priceChanges.join(", ")}`);
    }

    if (descriptionChanged) {
      hasChanges = true;
      if (changeType !== ChangeType.PRICE) {
        changeType = ChangeType.INFO;
      }
      changeDetails.push(`Nombre del producto`);
    }

    if (ivaChanged) {
      hasChanges = true;
      if (changeType !== ChangeType.PRICE) {
        changeType = ChangeType.INFO;
      }
      changeDetails.push(`IVA (${oldValues["iva"]}% → ${updateData["iva"]}%)`);
    }

    if (hasChanges) {
      description = changeDetails.join(", ");

      console.log("📝 Creating update task for product:", {
        productId: product.id,
        changeType,
        description,
        changes: {
          prices: priceChanges,
          descriptionChanged,
          ivaChanged,
        },
      });

      await this.tasksService.createTaskForProductUpdate(
        product.id,
        changeType,
        oldValues,
        updateData,
        updatedById,
        description
      );
    }
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

    const searchTerm = `%${query.trim()}%`;
    console.log("Searching with term:", searchTerm);

    try {
      const result = await this.productsRepository.find({
        where: [
          { description: ILike(searchTerm), isActive: true },
          { barcode: ILike(searchTerm), isActive: true },
        ],
        order: { createdAt: "DESC" },
        skip: page * limit,
        take: limit,
      });
      console.log("Search result count:", result.length);
      return result;
    } catch (error) {
      console.error("Database search error:", error);
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

      // Notificar a todos los supervisores con los detalles de precios e IVA
      const supervisors = await this.usersRepository.find({
        where: { role: UserRole.SUPERVISOR, isActive: true },
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
    notes?: string
  ): Promise<TemporaryProduct> {
    const temporaryProduct = await this.findTemporaryProduct(id);

    if (temporaryProduct.status !== TemporaryProductStatus.PENDING_SUPERVISOR) {
      throw new NotFoundException(
        `Solo se pueden completar productos temporales en estado pending_supervisor`
      );
    }

    // Verificar que el producto real fue creado
    // TODO: Descomentar después de ejecutar la migración
    // if (!temporaryProduct.productId) {
    //   console.error('❌ No product ID found in temporary product. This should not happen.');
    //   throw new NotFoundException(
    //     `El producto temporal no tiene un producto real asociado. Por favor, contacte al administrador.`,
    //   );
    // }

    // console.log('✅ Supervisor confirming product was applied. Product ID:', temporaryProduct.productId);
    console.log("✅ Supervisor confirming product was applied.");

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

  async deleteTemporaryProduct(id: string): Promise<void> {
    const result = await this.temporaryProductsRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`Temporary product with ID ${id} not found`);
    }
  }
}
