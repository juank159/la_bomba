import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Product } from './product.entity';
import { User } from '../../users/entities/user.entity';

export enum TaskStatus {
  PENDING = 'pending',
  COMPLETED = 'completed',
  EXPIRED = 'expired',
}

export enum ChangeType {
  PRICE = 'price',
  INFO = 'info',
  INVENTORY = 'inventory',
  ARRIVAL = 'arrival',
}

@Entity('product_update_tasks')
export class ProductUpdateTask {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Product, { eager: true })
  @JoinColumn({ name: 'productId' })
  product: Product;

  @Column()
  productId: string;

  @Column({
    type: 'enum',
    enum: ChangeType,
    default: ChangeType.PRICE,
  })
  changeType: ChangeType;

  @Column({ type: 'jsonb', nullable: true })
  oldValue: any;

  @Column({ type: 'jsonb', nullable: true })
  newValue: any;

  @Column({
    type: 'enum',
    enum: TaskStatus,
    default: TaskStatus.PENDING,
  })
  status: TaskStatus;

  @Column({ nullable: true })
  description: string;

  @Column()
  createdById: string;

  @ManyToOne(() => User, { eager: true })
  @JoinColumn({ name: 'createdById' })
  createdBy: User;

  @Column({ nullable: true })
  completedById: string;

  @ManyToOne(() => User, { nullable: true, eager: false })
  @JoinColumn({ name: 'completedById' })
  completedBy: User;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column({ nullable: true })
  completedAt: Date;

  @Column({ nullable: true, type: 'text' })
  adminNotes: string; // Notas del administrador al crear la tarea

  @Column({ nullable: true, type: 'text' })
  notes: string; // Notas del supervisor al completar
}