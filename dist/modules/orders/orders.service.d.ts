import { Repository } from 'typeorm';
import { Order } from './entities/order.entity';
import { OrderItem } from './entities/order-item.entity';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderDto } from './dto/update-order.dto';
import { UpdateOrderItemsDto } from './dto/update-order-items.dto';
import { UserRole } from '../users/entities/user.entity';
export declare class OrdersService {
    private ordersRepository;
    private orderItemsRepository;
    constructor(ordersRepository: Repository<Order>, orderItemsRepository: Repository<OrderItem>);
    create(createOrderDto: CreateOrderDto, userId: string): Promise<Order>;
    findAll(): Promise<Order[]>;
    findOne(id: string): Promise<Order>;
    update(id: string, updateOrderDto: UpdateOrderDto, userRole: UserRole, userId?: string): Promise<Order>;
    updateRequestedQuantities(updateItemsDto: UpdateOrderItemsDto[], userRole: UserRole): Promise<void>;
    addProductToOrder(orderId: string, addProductDto: {
        productId: string;
        existingQuantity: number;
        requestedQuantity?: number;
        measurementUnit: string;
    }, userRole: UserRole, userId?: string): Promise<Order>;
    removeProductFromOrder(orderId: string, itemId: string, userRole: UserRole, userId?: string): Promise<Order>;
    updateOrderItemQuantity(orderId: string, itemId: string, updateDto: {
        existingQuantity?: number;
        requestedQuantity?: number;
    }, userRole: UserRole, userId?: string): Promise<Order>;
    remove(id: string): Promise<void>;
}
