import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { VegetableSale } from './vegetable-sale.entity';
import { VegetableItem, PricingType } from './vegetable-item.entity';

@Entity('vegetable_sale_items')
export class VegetableSaleItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => VegetableSale, (sale) => sale.items, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'sale_id' })
  sale: VegetableSale;

  @Column({ name: 'sale_id' })
  saleId: string;

  @ManyToOne(() => VegetableItem, { nullable: true })
  @JoinColumn({ name: 'vegetable_item_id' })
  vegetableItem: VegetableItem;

  @Column({ name: 'vegetable_item_id', nullable: true })
  vegetableItemId: string;

  // Snapshot de datos del producto al momento de la venta: si el precio
  // cambia después, el recibo histórico no debe cambiar con él.
  @Column()
  description: string;

  @Column({ type: 'enum', enum: PricingType, name: 'pricing_type' })
  pricingType: PricingType;

  // Kilogramos vendidos (solo para items pesados por báscula)
  @Column('decimal', { precision: 10, scale: 3, nullable: true })
  weightKg: number;

  // Unidades vendidas (solo para items de precio fijo)
  @Column({ type: 'int', nullable: true })
  quantity: number;

  // Precio por kilo o precio fijo por unidad, según pricingType (snapshot)
  @Column('decimal', { name: 'unit_price', precision: 10, scale: 2 })
  unitPrice: number;

  // weightKg*unitPrice o quantity*unitPrice, según pricingType
  @Column('decimal', { precision: 10, scale: 2 })
  total: number;
}
