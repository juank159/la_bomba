import { OrdersService } from './orders.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderDto } from './dto/update-order.dto';
import { UpdateOrderItemsDto } from './dto/update-order-items.dto';
export declare class OrdersController {
    private readonly ordersService;
    constructor(ordersService: OrdersService);
    create(createOrderDto: CreateOrderDto, req: any): Promise<import("./entities/order.entity").Order>;
    findAll(): Promise<import("./entities/order.entity").Order[]>;
    findOne(id: string): Promise<import("./entities/order.entity").Order>;
    update(id: string, updateOrderDto: UpdateOrderDto, req: any): Promise<import("./entities/order.entity").Order>;
    updateRequestedQuantities(updateItemsDto: UpdateOrderItemsDto[], req: any): Promise<void>;
    addProductToOrder(orderId: string, addProductDto: {
        productId: string;
        existingQuantity: number;
        requestedQuantity?: number;
        measurementUnit: string;
    }, req: any): Promise<import("./entities/order.entity").Order>;
    removeProductFromOrder(orderId: string, itemId: string, req: any): Promise<import("./entities/order.entity").Order>;
    updateOrderItemQuantity(orderId: string, itemId: string, updateDto: {
        existingQuantity?: number;
        requestedQuantity?: number;
    }, req: any): Promise<import("./entities/order.entity").Order>;
    remove(id: string): Promise<void>;
}
