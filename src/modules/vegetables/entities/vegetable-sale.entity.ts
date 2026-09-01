import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  OneToMany,
} from 'typeorm';
import { VegetableSaleItem } from './vegetable-sale-item.entity';

@Entity('vegetable_sales')
export class VegetableSale {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // Consecutivo legible para el recibo (no es la PK), igual que en invoices.
  @Column({ type: 'int', generated: 'increment', unique: true })
  number: number;

  @Column('decimal', { precision: 10, scale: 2 })
  total: number;

  @Column({ name: 'sold_by' })
  soldBy: string;

  @OneToMany(() => VegetableSaleItem, (item) => item.sale, { cascade: true })
  items: VegetableSaleItem[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
