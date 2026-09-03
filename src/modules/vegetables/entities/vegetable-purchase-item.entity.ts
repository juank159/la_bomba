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

  @ManyToOne(() => VegetableItem)
  @JoinColumn({ name: 'vegetable_item_id' })
  vegetableItem: VegetableItem;

  @Column({ name: 'vegetable_item_id' })
  vegetableItemId: string;

  // Snapshot del nombre al momento de la compra (si el producto se
  // renombra después, el histórico no cambia con él).
  @Column()
  description: string;

  // Cantidad comprada: kg si el producto se vende por peso, unidades si es
  // de precio fijo (mismo criterio que vegetable_sale_items.weight_kg/quantity,
  // pero acá se guarda como un solo campo porque la compra siempre suma
  // exactamente lo que dice la etiqueta - no depende de una lectura de báscula).
  @Column('decimal', { precision: 10, scale: 3 })
  quantity: number;

  // Costo pagado por kg o por unidad, según el tipo de precio del producto.
  @Column('decimal', { name: 'unit_cost', precision: 10, scale: 2 })
  unitCost: number;

  @Column('decimal', { precision: 10, scale: 2 })
  total: number;
}
