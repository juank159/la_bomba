import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  OneToMany,
} from 'typeorm';
import { VegetableOrderItem } from './vegetable-order-item.entity';

/// A restock/shopping list ("pedido") for the vegetables module - just a
/// list of items + quantity + unit to hand to whoever supplies them.
/// Deliberately simpler than the full Order module: no supplier, no
/// status workflow, just a printable list with a history.
@Entity('vegetable_orders')
export class VegetableOrder {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // Consecutivo legible (no es la PK), igual que en vegetable_sales.
  @Column({ type: 'int', generated: 'increment', unique: true })
  number: number;

  @Column({ name: 'created_by' })
  createdBy: string;

  @OneToMany(() => VegetableOrderItem, (item) => item.order, { cascade: true })
  items: VegetableOrderItem[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
