import { Product } from './product.entity';
import { User } from '../../users/entities/user.entity';
export declare enum TaskStatus {
    PENDING = "pending",
    COMPLETED = "completed",
    EXPIRED = "expired"
}
export declare enum ChangeType {
    PRICE = "price",
    INFO = "info",
    INVENTORY = "inventory",
    ARRIVAL = "arrival"
}
export declare class ProductUpdateTask {
    id: string;
    product: Product;
    productId: string;
    changeType: ChangeType;
    oldValue: any;
    newValue: any;
    status: TaskStatus;
    description: string;
    createdById: string;
    createdBy: User;
    completedById: string;
    completedBy: User;
    createdAt: Date;
    updatedAt: Date;
    completedAt: Date;
    notes: string;
}
