import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, OneToMany } from 'typeorm';
import { VegetablePurchaseItem } from './vegetable-purchase-item.entity';

/// A completed purchase of produce for the vegetables module: what was
/// bought, how much it cost, and (via VegetablesService.createPurchase)
/// automatically adds the bought quantity to each item's inventory.
@Entity('vegetable_purchases')
export class VegetablePurchase {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // Consecutivo legible, igual que en ventas/facturas (no es la PK).
  @Column({ type: 'int', generated: 'increment', unique: true })
  number: number;

  @Column('decimal', { precision: 10, scale: 2 })
  total: number;

  @Column({ name: 'created_by' })
  createdBy: string;

  @OneToMany(() => VegetablePurchaseItem, (item) => item.purchase, { cascade: true })
  items: VegetablePurchaseItem[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
