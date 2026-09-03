import { Injectable, NotFoundException, BadRequestException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In, QueryFailedError } from 'typeorm';
import { VegetableItem, PricingType } from './entities/vegetable-item.entity';
import { VegetableCategory } from './entities/vegetable-category.entity';
import { VegetableSale } from './entities/vegetable-sale.entity';
import { VegetableSaleItem } from './entities/vegetable-sale-item.entity';
import { VegetableOrder } from './entities/vegetable-order.entity';
import { VegetableOrderItem } from './entities/vegetable-order-item.entity';
import { VegetableStockMovement, StockMovementType } from './entities/vegetable-stock-movement.entity';
import { VegetablePurchase } from './entities/vegetable-purchase.entity';
import { VegetablePurchaseItem } from './entities/vegetable-purchase-item.entity';
import { CreateVegetableItemDto } from './dto/create-vegetable-item.dto';
import { UpdateVegetableItemDto } from './dto/update-vegetable-item.dto';
import { CreateVegetableCategoryDto } from './dto/create-vegetable-category.dto';
import { UpdateVegetableCategoryDto } from './dto/update-vegetable-category.dto';
import { CreateVegetableSaleDto } from './dto/create-vegetable-sale.dto';
import { CreateVegetableOrderDto } from './dto/create-vegetable-order.dto';
import { CreateStockMovementDto, CreatableStockMovementType } from './dto/create-stock-movement.dto';
import { CreateVegetablePurchaseDto } from './dto/create-vegetable-purchase.dto';
import { CloudinaryService } from '../../common/cloudinary/cloudinary.service';
import { VegetableCashSessionsService } from '../vegetable-cash-sessions/vegetable-cash-sessions.service';

@Injectable()
export class VegetablesService {
  constructor(
    @InjectRepository(VegetableItem)
    private itemsRepository: Repository<VegetableItem>,
    @InjectRepository(VegetableCategory)
    private categoriesRepository: Repository<VegetableCategory>,
    @InjectRepository(VegetableSale)
    private salesRepository: Repository<VegetableSale>,
    @InjectRepository(VegetableSaleItem)
    private saleItemsRepository: Repository<VegetableSaleItem>,
    @InjectRepository(VegetableOrder)
    private ordersRepository: Repository<VegetableOrder>,
    @InjectRepository(VegetableOrderItem)
    private orderItemsRepository: Repository<VegetableOrderItem>,
    @InjectRepository(VegetableStockMovement)
    private stockMovementsRepository: Repository<VegetableStockMovement>,
    @InjectRepository(VegetablePurchase)
    private purchasesRepository: Repository<VegetablePurchase>,
    @InjectRepository(VegetablePurchaseItem)
    private purchaseItemsRepository: Repository<VegetablePurchaseItem>,
    private cloudinaryService: CloudinaryService,
    private cashSessionsService: VegetableCashSessionsService,
  ) {}

  // ==========================================================================
  // Categorías (ej. Frutas, Verduras)
  // ==========================================================================

  async createCategory(dto: CreateVegetableCategoryDto): Promise<VegetableCategory> {
    try {
      const category = this.categoriesRepository.create(dto);
      return await this.categoriesRepository.save(category);
    } catch (error) {
      throw this.handleUniqueNameConflict(error, dto.name);
    }
  }

  async findAllCategories(includeInactive = false): Promise<VegetableCategory[]> {
    return this.categoriesRepository.find({
      where: includeInactive ? {} : { isActive: true },
      order: { name: 'ASC' },
    });
  }

  async findOneCategory(id: string): Promise<VegetableCategory> {
    const category = await this.categoriesRepository.findOne({ where: { id } });
    if (!category) {
      throw new NotFoundException(`Categoría con ID ${id} no encontrada`);
    }
    return category;
  }

  async updateCategory(id: string, dto: UpdateVegetableCategoryDto): Promise<VegetableCategory> {
    const category = await this.findOneCategory(id);
    const merged = this.categoriesRepository.merge(category, dto);
    try {
      return await this.categoriesRepository.save(merged);
    } catch (error) {
      throw this.handleUniqueNameConflict(error, dto.name ?? category.name);
    }
  }

  async removeCategory(id: string): Promise<void> {
    const category = await this.findOneCategory(id);
    // Baja lógica: no se borra para no perder la referencia en productos
    // que ya tienen esta categoría asignada (igual que isActive en items).
    category.isActive = false;
    await this.categoriesRepository.save(category);
  }

  private handleUniqueNameConflict(error: unknown, name: string): Error {
    if (error instanceof QueryFailedError && (error as any).code === '23505') {
      return new ConflictException(`Ya existe una categoría llamada "${name}"`);
    }
    return error as Error;
  }

  // ==========================================================================
  // Catálogo de verduras
  // ==========================================================================

  async createItem(dto: CreateVegetableItemDto): Promise<VegetableItem> {
    if (dto.pricingType === PricingType.WEIGHT && !dto.pricePerKg) {
      throw new BadRequestException('Los productos que se venden por peso requieren precio por kilo');
    }
    if (dto.pricingType === PricingType.FIXED && !dto.fixedPrice) {
      throw new BadRequestException('Los productos de precio fijo requieren un precio');
    }
    if (dto.categoryId) {
      await this.findOneCategory(dto.categoryId);
    }

    const { image, ...rest } = dto;
    const item = this.itemsRepository.create(rest);

    if (image) {
      const uploaded = await this.cloudinaryService.uploadBase64(image);
      item.imageUrl = uploaded.url;
      item.imagePublicId = uploaded.publicId;
    }

    const saved = await this.itemsRepository.save(item);
    return this.findOneItem(saved.id);
  }

  async findAllItems(includeInactive = false): Promise<VegetableItem[]> {
    return this.itemsRepository.find({
      where: includeInactive ? {} : { isActive: true },
      relations: ['category'],
      order: { name: 'ASC' },
    });
  }

  async findOneItem(id: string): Promise<VegetableItem> {
    const item = await this.itemsRepository.findOne({ where: { id }, relations: ['category'] });
    if (!item) {
      throw new NotFoundException(`Producto de verduras con ID ${id} no encontrado`);
    }
    return item;
  }

  async updateItem(id: string, dto: UpdateVegetableItemDto): Promise<VegetableItem> {
    const item = await this.findOneItem(id);
    if (dto.categoryId) {
      await this.findOneCategory(dto.categoryId);
    }

    const { image, ...rest } = dto;
    const merged = this.itemsRepository.merge(item, rest);

    if (merged.pricingType === PricingType.WEIGHT && !merged.pricePerKg) {
      throw new BadRequestException('Los productos que se venden por peso requieren precio por kilo');
    }
    if (merged.pricingType === PricingType.FIXED && !merged.fixedPrice) {
      throw new BadRequestException('Los productos de precio fijo requieren un precio');
    }

    // image === undefined: no se tocó la foto.
    // image === '' (string vacío): se pidió quitarla.
    // image === <base64>: se reemplaza por una nueva.
    if (image !== undefined) {
      const previousPublicId = merged.imagePublicId;

      if (image) {
        const uploaded = await this.cloudinaryService.uploadBase64(image);
        merged.imageUrl = uploaded.url;
        merged.imagePublicId = uploaded.publicId;
      } else {
        merged.imageUrl = null;
        merged.imagePublicId = null;
      }

      if (previousPublicId && previousPublicId !== merged.imagePublicId) {
        await this.cloudinaryService.deleteImage(previousPublicId);
      }
    }

    const saved = await this.itemsRepository.save(merged);
    return this.findOneItem(saved.id);
  }

  async removeItem(id: string): Promise<void> {
    const item = await this.findOneItem(id);
    // Baja lógica: no se borra para no perder el histórico de ventas que
    // referencian este producto (igual que isActive en products).
    item.isActive = false;
    await this.itemsRepository.save(item);
  }

  // ==========================================================================
  // Ventas
  // ==========================================================================

  async createSale(dto: CreateVegetableSaleDto, username: string): Promise<VegetableSale> {
    const itemIds = dto.items.map((i) => i.vegetableItemId);
    const items = await this.itemsRepository.find({ where: { id: In(itemIds) } });
    const itemsById = new Map(items.map((i) => [i.id, i]));

    const missingId = itemIds.find((id) => !itemsById.has(id));
    if (missingId) {
      throw new BadRequestException(`Producto no encontrado: ${missingId}`);
    }

    let total = 0;

    const itemsData = dto.items.map((line) => {
      const item = itemsById.get(line.vegetableItemId)!;

      if (item.pricingType === PricingType.WEIGHT) {
        if (!line.weightKg || line.weightKg <= 0) {
          throw new BadRequestException(
            `${item.name} se vende por peso: debes indicar el peso en kg`,
          );
        }
        const unitPrice = Number(item.pricePerKg);
        const lineTotal = unitPrice * line.weightKg;
        total += lineTotal;

        return {
          vegetableItemId: item.id,
          description: item.name,
          pricingType: item.pricingType,
          weightKg: line.weightKg,
          quantity: null,
          unitPrice,
          total: lineTotal,
        };
      }

      // FIXED
      const quantity = line.quantity && line.quantity > 0 ? line.quantity : 1;
      const unitPrice = Number(item.fixedPrice);
      const lineTotal = unitPrice * quantity;
      total += lineTotal;

      return {
        vegetableItemId: item.id,
        description: item.name,
        pricingType: item.pricingType,
        weightKg: null,
        quantity,
        unitPrice,
        total: lineTotal,
      };
    });

    const openSession = await this.cashSessionsService.getCurrentOpenSession();

    const sale = this.salesRepository.create({
      total,
      soldBy: username,
      cashSessionId: openSession?.id,
    });
    const savedSale = await this.salesRepository.save(sale);

    const saleItems = itemsData.map((item) =>
      this.saleItemsRepository.create({
        saleId: savedSale.id,
        ...item,
      }),
    );
    await this.saleItemsRepository.save(saleItems);

    // Descuenta del inventario lo vendido. No bloquea la venta si el stock
    // no alcanza (queda en negativo) - todavía no todos los productos
    // tienen un conteo inicial cargado, así que exigir stock suficiente
    // frenaría ventas normales. El número en negativo es justamente la
    // señal de "esto quedó sin cargar/contar".
    for (const line of itemsData) {
      const soldAmount = line.weightKg ?? line.quantity ?? 0;
      if (soldAmount > 0) {
        await this.applyStockMovement(itemsById.get(line.vegetableItemId)!, {
          type: StockMovementType.SALE,
          quantity: -soldAmount,
          saleId: savedSale.id,
          createdBy: username,
          enforceNonNegative: false,
        });
      }
    }

    return this.findOneSale(savedSale.id);
  }

  async findAllSales(): Promise<VegetableSale[]> {
    return this.salesRepository.find({
      relations: ['items'],
      order: { createdAt: 'DESC' },
    });
  }

  async findOneSale(id: string): Promise<VegetableSale> {
    const sale = await this.salesRepository.findOne({
      where: { id },
      relations: ['items'],
    });

    if (!sale) {
      throw new NotFoundException(`Venta con ID ${id} no encontrada`);
    }

    return sale;
  }

  // ==========================================================================
  // Pedidos (lista simple para reabastecer, sin proveedor ni estado)
  // ==========================================================================

  async createOrder(dto: CreateVegetableOrderDto, username: string): Promise<VegetableOrder> {
    const itemIds = dto.items
      .map((line) => line.vegetableItemId)
      .filter((id): id is string => !!id);
    const itemsById = itemIds.length
      ? new Map((await this.itemsRepository.find({ where: { id: In(itemIds) } })).map((i) => [i.id, i]))
      : new Map<string, VegetableItem>();

    const itemsData = dto.items.map((line) => {
      let description = line.description?.trim();

      if (line.vegetableItemId) {
        const item = itemsById.get(line.vegetableItemId);
        if (!item) {
          throw new BadRequestException(`Producto no encontrado: ${line.vegetableItemId}`);
        }
        description = item.name;
      }

      if (!description) {
        throw new BadRequestException('Cada línea del pedido necesita un producto del catálogo o un nombre');
      }

      return {
        vegetableItemId: line.vegetableItemId ?? null,
        description,
        quantity: line.quantity,
        unit: line.unit,
      };
    });

    const order = this.ordersRepository.create({ createdBy: username });
    const savedOrder = await this.ordersRepository.save(order);

    const orderItems = itemsData.map((item) =>
      this.orderItemsRepository.create({ orderId: savedOrder.id, ...item }),
    );
    await this.orderItemsRepository.save(orderItems);

    return this.findOneOrder(savedOrder.id);
  }

  async findAllOrders(): Promise<VegetableOrder[]> {
    return this.ordersRepository.find({
      relations: ['items'],
      order: { createdAt: 'DESC' },
    });
  }

  async findOneOrder(id: string): Promise<VegetableOrder> {
    const order = await this.ordersRepository.findOne({
      where: { id },
      relations: ['items'],
    });

    if (!order) {
      throw new NotFoundException(`Pedido con ID ${id} no encontrado`);
    }

    return order;
  }

  // ==========================================================================
  // Inventario / Merma
  // ==========================================================================

  /// Registra un movimiento de stock pedido explícitamente por un usuario
  /// (entrada, merma o ajuste manual). SALE nunca pasa por acá - lo crea
  /// createSale() directamente vía applyStockMovement().
  async registerStockMovement(
    itemId: string,
    dto: CreateStockMovementDto,
    username: string,
  ): Promise<VegetableItem> {
    const item = await this.findOneItem(itemId);

    const quantity =
      dto.type === CreatableStockMovementType.MERMA
        ? -Math.abs(dto.quantity)
        : dto.type === CreatableStockMovementType.IN
          ? Math.abs(dto.quantity)
          : dto.quantity; // ADJUSTMENT: se respeta el signo que mandó el usuario

    await this.applyStockMovement(item, {
      type: dto.type as unknown as StockMovementType,
      quantity,
      reason: dto.reason,
      createdBy: username,
      enforceNonNegative: true,
    });

    return this.findOneItem(itemId);
  }

  async findStockMovements(itemId: string): Promise<VegetableStockMovement[]> {
    await this.findOneItem(itemId); // 404 si no existe
    return this.stockMovementsRepository.find({
      where: { vegetableItemId: itemId },
      order: { createdAt: 'DESC' },
    });
  }

  /// Único lugar que de verdad cambia `vegetable_items.stock`: aplica
  /// [quantity] (con signo) al saldo actual de [item], guarda el
  /// movimiento con el saldo resultante como snapshot, y persiste el nuevo
  /// stock en el item. Si `enforceNonNegative` es true y el resultado
  /// quedaría negativo, rechaza la operación (usado para merma/ajustes
  /// manuales; las ventas SÍ pueden dejar el stock en negativo, ver nota
  /// en createSale()).
  private async applyStockMovement(
    item: VegetableItem,
    params: {
      type: StockMovementType;
      quantity: number;
      reason?: string;
      saleId?: string;
      purchaseId?: string;
      createdBy: string;
      enforceNonNegative: boolean;
    },
  ): Promise<void> {
    const resultingStock = Number(item.stock) + params.quantity;

    if (params.enforceNonNegative && resultingStock < 0) {
      throw new BadRequestException(
        `Stock insuficiente: "${item.name}" tiene ${Number(item.stock)} y esta operación dejaría ${resultingStock}`,
      );
    }

    const movement = this.stockMovementsRepository.create({
      vegetableItemId: item.id,
      type: params.type,
      quantity: params.quantity,
      resultingStock,
      reason: params.reason,
      saleId: params.saleId,
      purchaseId: params.purchaseId,
      createdBy: params.createdBy,
    });
    await this.stockMovementsRepository.save(movement);

    item.stock = resultingStock;
    await this.itemsRepository.save(item);
  }

  // ==========================================================================
  // Compras (registro real de mercancía comprada, con costo)
  // ==========================================================================

  /// A diferencia de "Pedidos" (solo una lista para saber qué comprar), una
  /// compra es la transacción real: suma al inventario lo comprado y queda
  /// como registro de costo. Solo acepta productos ya existentes en el
  /// catálogo.
  async createPurchase(dto: CreateVegetablePurchaseDto, username: string): Promise<VegetablePurchase> {
    const itemIds = dto.items.map((i) => i.vegetableItemId);
    const items = await this.itemsRepository.find({ where: { id: In(itemIds) } });
    const itemsById = new Map(items.map((i) => [i.id, i]));

    const missingId = itemIds.find((id) => !itemsById.has(id));
    if (missingId) {
      throw new BadRequestException(`Producto no encontrado: ${missingId}`);
    }

    let total = 0;
    const itemsData = dto.items.map((line) => {
      const item = itemsById.get(line.vegetableItemId)!;
      const lineTotal = line.quantity * line.unitCost;
      total += lineTotal;

      return {
        vegetableItemId: item.id,
        description: item.name,
        quantity: line.quantity,
        unitCost: line.unitCost,
        total: lineTotal,
      };
    });

    const purchase = this.purchasesRepository.create({ total, createdBy: username });
    const savedPurchase = await this.purchasesRepository.save(purchase);

    const purchaseItems = itemsData.map((item) =>
      this.purchaseItemsRepository.create({ purchaseId: savedPurchase.id, ...item }),
    );
    await this.purchaseItemsRepository.save(purchaseItems);

    for (const line of itemsData) {
      await this.applyStockMovement(itemsById.get(line.vegetableItemId)!, {
        type: StockMovementType.IN,
        quantity: line.quantity,
        purchaseId: savedPurchase.id,
        createdBy: username,
        enforceNonNegative: true,
      });
    }

    return this.findOnePurchase(savedPurchase.id);
  }

  async findAllPurchases(): Promise<VegetablePurchase[]> {
    return this.purchasesRepository.find({
      relations: ['items'],
      order: { createdAt: 'DESC' },
    });
  }

  async findOnePurchase(id: string): Promise<VegetablePurchase> {
    const purchase = await this.purchasesRepository.findOne({
      where: { id },
      relations: ['items'],
    });

    if (!purchase) {
      throw new NotFoundException(`Compra con ID ${id} no encontrada`);
    }

    return purchase;
  }
}
