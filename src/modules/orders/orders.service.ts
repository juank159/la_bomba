import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Order, OrderStatus } from './entities/order.entity';
import { OrderItem } from './entities/order-item.entity';
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

  async findAll(): Promise<Order[]> {
    return this.ordersRepository.find({
      relations: ['createdBy', 'items', 'items.product', 'items.temporaryProduct', 'items.supplier'],
      order: { createdAt: 'DESC' },
    });
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

    Object.assign(order, updateOrderDto);
    await this.ordersRepository.save(order);

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
    updateDto: { existingQuantity?: number; requestedQuantity?: number },
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

    // Update the quantities
    if (updateDto.existingQuantity !== undefined) {
      orderItem.existingQuantity = updateDto.existingQuantity;
    }
    if (updateDto.requestedQuantity !== undefined) {
      orderItem.requestedQuantity = updateDto.requestedQuantity;
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