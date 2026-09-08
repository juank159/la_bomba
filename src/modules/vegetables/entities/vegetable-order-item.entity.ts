import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { VegetableOrder } from './vegetable-order.entity';
import { VegetableItem } from './vegetable-item.entity';

// Los primeros tres valores son los mismos que MeasurementUnit del módulo
// de pedidos normal (kilogramos, libras, unidad); el resto son unidades
// propias de cómo se pide mercancía a un proveedor de verduras.
export enum VegetableOrderUnit {
  KILOGRAMOS = 'kilogramos',
  LIBRAS = 'libras',
  UNIDAD = 'unidad',
  CAJA = 'caja',
  BOLSA = 'bolsa',
  BANDEJA = 'bandeja',
  CESTA = 'cesta',
  BULTO = 'bulto',
  ROLLO = 'rollo',
  DOCENA = 'docena',
  CANASTA = 'canasta',
}

@Entity('vegetable_order_items')
export class VegetableOrderItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => VegetableOrder, (order) => order.items, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'order_id' })
  order: VegetableOrder;

  @Column({ name: 'order_id' })
  orderId: string;

  // Nullable: permite pedir algo que aún no está en el catálogo (producto
  // ocasional), en cuyo caso solo queda el nombre escrito a mano.
  @ManyToOne(() => VegetableItem, { nullable: true })
  @JoinColumn({ name: 'vegetable_item_id' })
  vegetableItem: VegetableItem;

  @Column({ name: 'vegetable_item_id', nullable: true })
  vegetableItemId: string;

  // Snapshot del nombre al momento de pedir (del catálogo o escrito a mano).
  @Column()
  description: string;

  @Column('decimal', { precision: 10, scale: 3 })
  quantity: number;

  @Column({ type: 'enum', enum: VegetableOrderUnit })
  unit: VegetableOrderUnit;
}
