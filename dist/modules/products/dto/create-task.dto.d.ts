import { ChangeType } from '../entities/product-update-task.entity';
export declare class CreateTaskDto {
    productId: string;
    changeType: ChangeType;
    oldValue?: any;
    newValue?: any;
    description?: string;
}
