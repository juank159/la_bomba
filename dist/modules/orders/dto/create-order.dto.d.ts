import { MeasurementUnit } from '../entities/order-item.entity';
export declare class CreateOrderItemDto {
    productId: string;
    existingQuantity: number;
    requestedQuantity?: number;
    measurementUnit?: MeasurementUnit;
}
export declare class CreateOrderDto {
    description: string;
    provider?: string;
    items: CreateOrderItemDto[];
}
