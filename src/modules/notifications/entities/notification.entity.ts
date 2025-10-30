import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Product } from '../../products/entities/product.entity';

export enum NotificationType {
  TASK_COMPLETED = 'task_completed',
  PRODUCT_UPDATE = 'product_update',                                         // Actualización de producto que requiere revisión
  TEMPORARY_PRODUCT_PENDING_ADMIN = 'temporary_product_pending_admin',       // Producto temporal necesita precios/IVA
  TEMPORARY_PRODUCT_PENDING_SUPERVISOR = 'temporary_product_pending_supervisor', // Producto temporal listo para revisar
  TEMPORARY_PRODUCT_COMPLETED = 'temporary_product_completed',               // Producto temporal confirmado por supervisor
  CREDIT_OVERDUE_30_DAYS = 'credit_overdue_30_days',                        // Cliente sin pagos en 30+ días
}

@Entity('notifications')
export class Notification {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({
    type: 'enum',
    enum: NotificationType,
    default: NotificationType.TASK_COMPLETED,
  })
  type: NotificationType;

  @Column()
  title: string;

  @Column('text')
  message: string;

  @Column({ default: false })
  isRead: boolean;

  @Column('uuid')
  userId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column('uuid', { nullable: true })
  productId: string;

  @ManyToOne(() => Product, { nullable: true })
  @JoinColumn({ name: 'productId' })
  product: Product;

  @Column('uuid', { nullable: true })
  relatedTaskId: string;

  @Column('uuid', { nullable: true })
  temporaryProductId: string;

  @Column('uuid', { nullable: true })
  creditId: string;

  @CreateDateColumn()
  createdAt: Date;
}
