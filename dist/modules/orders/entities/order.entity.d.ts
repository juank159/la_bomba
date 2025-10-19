import { User } from '../../users/entities/user.entity';
import { OrderItem } from './order-item.entity';
export declare enum OrderStatus {
    PENDING = "pending",
    COMPLETED = "completed"
}
export declare class Order {
    id: string;
    description: string;
    provider: string;
    status: OrderStatus;
    createdBy: User;
    createdById: string;
    items: OrderItem[];
    createdAt: Date;
    updatedAt: Date;
}
