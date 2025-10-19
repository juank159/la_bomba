import { Order } from './order.entity';
import { Product } from '../../products/entities/product.entity';
export declare enum MeasurementUnit {
    UNIDAD = "unidad",
    BULTOS = "bultos",
    FARDOS = "fardos",
    CAJAS = "cajas",
    PAQUETES = "paquetes",
    LIBRAS = "libras",
    KILOGRAMOS = "kilogramos",
    LITROS = "litros",
    METROS = "metros",
    DOCENAS = "docenas"
}
export declare class OrderItem {
    id: string;
    order: Order;
    orderId: string;
    product: Product;
    productId: string;
    existingQuantity: number;
    requestedQuantity: number;
    measurementUnit: MeasurementUnit;
}
