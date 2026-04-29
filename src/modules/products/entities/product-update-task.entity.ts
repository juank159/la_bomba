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
  INFO = 'info', // legado: cambio genérico (tareas viejas). Nuevas ediciones usan los tipos granulares
  INVENTORY = 'inventory',
  ARRIVAL = 'arrival',
  NAME = 'name',
  IVA = 'iva',
  BARCODE = 'barcode',
  DESCRIPTION = 'description',
}

/**
 * Rol al que se asigna una tarea. Cuando un cambio afecta a múltiples roles
 * se crean tareas separadas (una por rol) con su propio status/completedBy.
 */
export enum AssignedRole {
  SUPERVISOR = 'supervisor',
  DIGITADOR = 'digitador',
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

  @Column({
    type: 'enum',
    enum: AssignedRole,
    default: AssignedRole.SUPERVISOR,
    enumName: 'product_update_tasks_assigned_role_enum',
  })
  assignedRole: AssignedRole;

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