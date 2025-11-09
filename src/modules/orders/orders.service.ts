import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Order, OrderStatus } from './entities/order.entity';
import { OrderItem, MeasurementUnit } from './entities/order-item.entity';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderDto } from './dto/update-order.dto';
import { UpdateOrderItemsDto } from './dto/update-order-items.dto';
import { UserRole } from '../users/entities/user.entity';

@Injectable()
export class OrdersService {
  constructor(
    @InjectRepository(Order)
    private ordersRepository: Repository<Order>,
    @InjectRepository(OrderItem)
    private orderItemsRepository: Repository<OrderItem>,
  ) {}

  async create(createOrderDto: CreateOrderDto, userId: string): Promise<Order> {
    const order = this.ordersRepository.create({
      description: createOrderDto.description,
      provider: createOrderDto.provider,
      createdById: userId,
    });

    const savedOrder = await this.ordersRepository.save(order);

    const orderItems = createOrderDto.items.map(item =>
      this.orderItemsRepository.create({
        orderId: savedOrder.id,
        productId: item.productId,
        temporaryProductId: item.temporaryProductId,
        supplierId: item.supplierId,
        existingQuantity: item.existingQuantity,
        requestedQuantity: item.requestedQuantity,
        measurementUnit: item.measurementUnit,
      })
    );

    await this.orderItemsRepository.save(orderItems);

    return this.findOne(savedOrder.id);
  }

  async findAll(
    search?: string,
    status?: string,
    page: number = 0,
    limit: number = 20,
  ): Promise<Order[]> {
    console.log('findAll called with:', { search, status, page, limit });

    // If no search query, return all orders with filters
    if (!search || search.trim().length === 0) {
      const queryBuilder = this.ordersRepository
        .createQueryBuilder('order')
        .leftJoinAndSelect('order.createdBy', 'createdBy')
        .leftJoinAndSelect('order.items', 'items')
        .leftJoinAndSelect('items.product', 'product')
        .leftJoinAndSelect('items.temporaryProduct', 'temporaryProduct')
        .leftJoinAndSelect('items.supplier', 'supplier');

      if (status) {
        queryBuilder.where('order.status = :status', { status });
      }

      queryBuilder.orderBy('order.createdAt', 'DESC');
      queryBuilder.skip(page * limit);
      queryBuilder.take(limit);

      return queryBuilder.getMany();
    }

    // MEJORA: Búsqueda inteligente con palabras individuales
    const stopWords = new Set([
      'de', 'la', 'el', 'y', 'en', 'con', 'para', 'por', 'un', 'una',
      'los', 'las', 'del', 'al', 'o', 'e', 'u', 'a'
    ]);

    const searchTerm = search.trim();
    const allWords = searchTerm.split(/\s+/);
    const searchWords = allWords.filter(word => {
      const cleanWord = word.toLowerCase();
      return word.length >= 2 && !stopWords.has(cleanWord);
    });

    console.log('🔍 Palabras originales:', allWords);
    console.log('✨ Palabras filtradas para búsqueda:', searchWords);

    if (searchWords.length === 0) {
      console.log('⚠️ No hay palabras válidas, usando término completo');
      searchWords.push(searchTerm);
    }

    const queryBuilder = this.ordersRepository
      .createQueryBuilder('order')
      .leftJoinAndSelect('order.createdBy', 'createdBy')
      .leftJoinAndSelect('order.items', 'items')
      .leftJoinAndSelect('items.product', 'product')
      .leftJoinAndSelect('items.temporaryProduct', 'temporaryProduct')
      .leftJoinAndSelect('items.supplier', 'supplier');

    // Construir búsqueda por palabras individuales
    // Buscar en: description y provider
    searchWords.forEach((word, index) => {
      const paramName = `searchWord${index}`;
      queryBuilder.andWhere(
        `(
          translate(LOWER(order.description), 'áéíóúàèìòùäëïöüâêîôûãõñçÁÉÍÓÚÀÈÌÒÙÄËÏÖÜÂÊÎÔÛÃÕÑÇ', 'aeiouaeiouaeiouaeiouaoncAEIOUAEIOUAEIOUAEIOUAONC')
          LIKE
          translate(LOWER(:${paramName}), 'áéíóúàèìòùäëïöüâêîôûãõñçÁÉÍÓÚÀÈÌÒÙÄËÏÖÜÂÊÎÔÛÃÕÑÇ', 'aeiouaeiouaeiouaeiouaoncAEIOUAEIOUAEIOUAEIOUAONC')
          OR
          translate(LOWER(order.provider), 'áéíóúàèìòùäëïöüâêîôûãõñçÁÉÍÓÚÀÈÌÒÙÄËÏÖÜÂÊÎÔÛÃÕÑÇ', 'aeiouaeiouaeiouaeiouaoncAEIOUAEIOUAEIOUAEIOUAONC')
          LIKE
          translate(LOWER(:${paramName}), 'áéíóúàèìòùäëïöüâêîôûãõñçÁÉÍÓÚÀÈÌÒÙÄËÏÖÜÂÊÎÔÛÃÕÑÇ', 'aeiouaeiouaeiouaeiouaoncAEIOUAEIOUAEIOUAEIOUAONC')
        )`,
        { [paramName]: `%${word}%` }
      );
    });

    // Filtrar por estado si se proporciona
    if (status) {
      queryBuilder.andWhere('order.status = :status', { status });
    }

    queryBuilder.orderBy('order.createdAt', 'DESC');
    queryBuilder.skip(page * limit);
    queryBuilder.take(limit);

    const result = await queryBuilder.getMany();
    console.log('✅ Resultados encontrados:', result.length);

    return result;
  }

  async findOne(id: string): Promise<Order> {
    const order = await this.ordersRepository.findOne({
      where: { id },
      relations: ['createdBy', 'items', 'items.product', 'items.temporaryProduct', 'items.supplier'],
    });

    if (!order) {
      throw new NotFoundException(`Order with ID ${id} not found`);
    }

    return order;
  }

  async update(id: string, updateOrderDto: UpdateOrderDto, userRole: UserRole, userId?: string): Promise<Order> {
    const order = await this.findOne(id);

    // Role-based access control for order editing
    if (userRole === UserRole.EMPLOYEE) {
      // Employees can only edit their own orders
      if (order.createdById !== userId) {
        throw new ForbiddenException('Employees can only edit their own orders');
      }
    }

    if (updateOrderDto.status && userRole !== UserRole.ADMIN) {
      throw new ForbiddenException('Only admins can change order status');
    }

    // Validate supplier assignment for mixed orders when completing
    if (updateOrderDto.status === OrderStatus.COMPLETED) {
      const isMixedOrder = !order.provider || order.provider.trim() === '';

      if (isMixedOrder) {
        const itemsWithoutSupplier = order.items.filter(item => !item.supplierId);

        if (itemsWithoutSupplier.length > 0) {
          throw new ForbiddenException(
            `Cannot complete mixed order: ${itemsWithoutSupplier.length} product(s) without assigned supplier. All products must have a supplier assigned in mixed orders.`
          );
        }
      }
    }

    // CRITICAL FIX: Explicitly handle provider updates, including null values
    // Object.assign may not properly handle null values in all cases
    console.log('🔵 [OrdersService] Updating order with DTO:', JSON.stringify(updateOrderDto, null, 2));
    console.log('🔵 [OrdersService] Current order provider:', order.provider);

    if ('description' in updateOrderDto) {
      order.description = updateOrderDto.description;
    }

    // IMPORTANT: Handle provider explicitly to support mixed orders (provider = null)
    if ('provider' in updateOrderDto) {
      order.provider = updateOrderDto.provider;
      console.log('🔵 [OrdersService] Provider updated to:', order.provider ?? 'NULL (MIXED ORDER)');
    }

    if ('status' in updateOrderDto) {
      order.status = updateOrderDto.status;
    }

    await this.ordersRepository.save(order);
    console.log('🔵 [OrdersService] Order saved. Provider is now:', order.provider ?? 'NULL (MIXED ORDER)');

    if (updateOrderDto.items) {
      await this.orderItemsRepository.delete({ orderId: id });
      
      const orderItems = updateOrderDto.items.map(item =>
        this.orderItemsRepository.create({
          orderId: id,
          productId: item.productId,
          temporaryProductId: item.temporaryProductId,
          supplierId: item.supplierId,
          existingQuantity: item.existingQuantity,
          requestedQuantity: item.requestedQuantity,
          measurementUnit: item.measurementUnit,
        })
      );

      await this.orderItemsRepository.save(orderItems);
    }

    return this.findOne(id);
  }

  async updateRequestedQuantities(updateItemsDto: UpdateOrderItemsDto[], userRole: UserRole): Promise<void> {
    if (userRole !== UserRole.ADMIN) {
      throw new ForbiddenException('Only admins can update requested quantities');
    }

    for (const item of updateItemsDto) {
      await this.orderItemsRepository.update(
        item.itemId,
        { requestedQuantity: item.requestedQuantity }
      );
    }
  }

  async addProductToOrder(
    orderId: string,
    addProductDto: { productId?: string; temporaryProductId?: string; existingQuantity: number; requestedQuantity?: number; measurementUnit: string },
    userRole: UserRole,
    userId?: string
  ): Promise<Order> {
    const order = await this.findOne(orderId);

    // Check permissions
    if (userRole === UserRole.EMPLOYEE && order.createdById !== userId) {
      throw new ForbiddenException('Employees can only modify their own orders');
    }

    // Check if product already exists in order
    if (addProductDto.productId) {
      const existingItem = order.items.find(item => item.productId === addProductDto.productId);
      if (existingItem) {
        throw new ForbiddenException('Product already exists in order. Use update quantity instead.');
      }
    }

    // Check if temporary product already exists in order
    if (addProductDto.temporaryProductId) {
      const existingItem = order.items.find(item => item.temporaryProductId === addProductDto.temporaryProductId);
      if (existingItem) {
        throw new ForbiddenException('Temporary product already exists in order. Use update quantity instead.');
      }
    }

    // Create new order item
    const orderItem = this.orderItemsRepository.create({
      orderId,
      productId: addProductDto.productId,
      temporaryProductId: addProductDto.temporaryProductId,
      existingQuantity: addProductDto.existingQuantity,
      requestedQuantity: addProductDto.requestedQuantity,
      measurementUnit: addProductDto.measurementUnit as any,
    });

    await this.orderItemsRepository.save(orderItem);
    return this.findOne(orderId);
  }

  async removeProductFromOrder(
    orderId: string,
    itemId: string,
    userRole: UserRole,
    userId?: string
  ): Promise<Order> {
    const order = await this.findOne(orderId);

    // Check permissions
    if (userRole === UserRole.EMPLOYEE && order.createdById !== userId) {
      throw new ForbiddenException('Employees can only modify their own orders');
    }

    // Check if item exists in order
    const orderItem = await this.orderItemsRepository.findOne({
      where: { id: itemId, orderId }
    });

    if (!orderItem) {
      throw new NotFoundException('Order item not found');
    }

    await this.orderItemsRepository.remove(orderItem);
    return this.findOne(orderId);
  }

  async updateOrderItemQuantity(
    orderId: string,
    itemId: string,
    updateDto: { existingQuantity?: number; requestedQuantity?: number; measurementUnit?: string; supplierId?: string },
    userRole: UserRole,
    userId?: string
  ): Promise<Order> {
    const order = await this.findOne(orderId);

    // Check permissions
    if (userRole === UserRole.EMPLOYEE && order.createdById !== userId) {
      throw new ForbiddenException('Employees can only modify their own orders');
    }

    // Find the order item
    const orderItem = await this.orderItemsRepository.findOne({
      where: { id: itemId, orderId }
    });

    if (!orderItem) {
      throw new NotFoundException('Order item not found');
    }

    // Update the quantities and measurement unit
    if (updateDto.existingQuantity !== undefined) {
      orderItem.existingQuantity = updateDto.existingQuantity;
    }
    if (updateDto.requestedQuantity !== undefined) {
      orderItem.requestedQuantity = updateDto.requestedQuantity;
    }
    if (updateDto.measurementUnit !== undefined) {
      orderItem.measurementUnit = updateDto.measurementUnit as MeasurementUnit;
    }
    if (updateDto.supplierId !== undefined) {
      // Only admins can assign suppliers
      if (userRole !== UserRole.ADMIN) {
        throw new ForbiddenException('Only admins can assign suppliers');
      }
      orderItem.supplierId = updateDto.supplierId;
    }

    await this.orderItemsRepository.save(orderItem);
    return this.findOne(orderId);
  }

  /**
   * Group order items by supplier
   * Returns a map of supplier ID to items
   */
  async groupItemsBySupplier(orderId: string): Promise<Record<string, OrderItem[]>> {
    const order = await this.findOne(orderId);

    const groupedItems: Record<string, OrderItem[]> = {};

    for (const item of order.items) {
      // Use supplier ID or 'unassigned' key
      const key = item.supplierId || 'unassigned';

      if (!groupedItems[key]) {
        groupedItems[key] = [];
      }

      groupedItems[key].push(item);
    }

    return groupedItems;
  }

  /**
   * Assign a supplier to an order item
   * Only admins can assign suppliers
   */
  async assignSupplierToItem(
    orderId: string,
    itemId: string,
    supplierId: string,
    userRole: UserRole
  ): Promise<Order> {
    // Only admins can assign suppliers
    if (userRole !== UserRole.ADMIN) {
      throw new ForbiddenException('Only admins can assign suppliers to order items');
    }

    const order = await this.findOne(orderId);

    // Find the order item
    const orderItem = await this.orderItemsRepository.findOne({
      where: { id: itemId, orderId }
    });

    if (!orderItem) {
      throw new NotFoundException('Order item not found');
    }

    // Update the supplier
    orderItem.supplierId = supplierId;
    await this.orderItemsRepository.save(orderItem);

    return this.findOne(orderId);
  }

  async remove(id: string): Promise<void> {
    const order = await this.findOne(id);
    await this.ordersRepository.remove(order);
  }
}