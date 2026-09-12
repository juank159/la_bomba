import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { VegetablePurchase } from './vegetable-purchase.entity';
import { VegetableItem } from './vegetable-item.entity';

@Entity('vegetable_purchase_items')
export class VegetablePurchaseItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => VegetablePurchase, (purchase) => purchase.items, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'purchase_id' })
  purchase: VegetablePurchase;

  @Column({ name: 'purchase_id' })
  purchaseId: string;

  @ManyToOne(() => VegetableItem, { nullable: true })
  @JoinColumn({ name: 'vegetable_item_id' })
  vegetableItem: VegetableItem;

  // Nullable: una línea de "compra libre" (ver VegetablesService.createPurchase)
  // no referencia ningún producto del catálogo ni afecta inventario.
  @Column({ name: 'vegetable_item_id', nullable: true })
  vegetableItemId: string | null;

  // Snapshot del nombre al momento de la compra (si el producto se
  // renombra después, el histórico no cambia con él) - o la descripción
  // libre digitada a mano si es una compra libre.
  @Column()
  description: string;

  // Cantidad comprada: kg si el producto se vende por peso, unidades si es
  // de precio fijo (mismo criterio que vegetable_sale_items.weight_kg/quantity,
  // pero acá se guarda como un solo campo porque la compra siempre suma
  // exactamente lo que dice la etiqueta - no depende de una lectura de báscula).
  // Null en una línea de compra libre (no hay cantidad de catálogo que registrar).
  @Column('decimal', { precision: 10, scale: 3, nullable: true })
  quantity: number | null;

  // Costo pagado por kg o por unidad, según el tipo de precio del producto.
  // Null en una línea de compra libre (el total ya viene dado, no se
  // calcula a partir de cantidad*costo unitario).
  @Column('decimal', { name: 'unit_cost', precision: 10, scale: 2, nullable: true })
  unitCost: number | null;

  @Column('decimal', { precision: 10, scale: 2 })
  total: number;
}
