import { OrderStatus } from '../entities/order.entity';
import { CreateOrderItemDto } from './create-order.dto';
export declare class UpdateOrderDto {
    description?: string;
    provider?: string;
    status?: OrderStatus;
    items?: CreateOrderItemDto[];
}
