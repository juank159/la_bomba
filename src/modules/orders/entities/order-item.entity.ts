import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { Order } from './order.entity';
import { Product } from '../../products/entities/product.entity';

export enum MeasurementUnit {
  UNIDAD = 'unidad',
  BULTOS = 'bultos', 
  FARDOS = 'fardos',
  CAJAS = 'cajas',
  PAQUETES = 'paquetes',
  LIBRAS = 'libras',
  KILOGRAMOS = 'kilogramos',
  LITROS = 'litros',
  METROS = 'metros',
  DOCENAS = 'docenas'
}

@Entity('order_items')
export class OrderItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Order, order => order.items, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'order_id' })
  order: Order;

  @Column({ name: 'order_id' })
  orderId: string;

  @ManyToOne(() => Product)
  @JoinColumn({ name: 'product_id' })
  product: Product;

  @Column({ name: 'product_id' })
  productId: string;

  @Column({ type: 'int' })
  existingQuantity: number;

  @Column({ type: 'int', nullable: true })
  requestedQuantity: number;

  @Column({
    type: 'enum',
    enum: MeasurementUnit,
    default: MeasurementUnit.UNIDAD,
  })
  measurementUnit: MeasurementUnit;
}