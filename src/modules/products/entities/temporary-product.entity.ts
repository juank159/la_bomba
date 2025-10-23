import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

export enum TemporaryProductStatus {
  PENDING_ADMIN = 'pending_admin',           // Esperando que admin agregue precios/IVA
  PENDING_SUPERVISOR = 'pending_supervisor', // Esperando que supervisor revise y agregue al sistema
  COMPLETED = 'completed',                   // Producto agregado al sistema
  CANCELLED = 'cancelled',                   // Producto no llegó / Cancelado por admin
}

@Entity('temporary_products')
export class TemporaryProduct {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // Información básica del producto
  @Column()
  name: string;

  @Column({ nullable: true })
  description: string;

  @Column({ nullable: true })
  barcode: string;

  @Column({ default: true })
  isActive: boolean;

  // Precios - todos opcionales hasta que el admin los complete
  @Column('decimal', { precision: 10, scale: 2, nullable: true, name: 'precioa' })
  precioA: number;

  @Column('decimal', { precision: 10, scale: 2, nullable: true, name: 'preciob' })
  precioB: number;

  @Column('decimal', { precision: 10, scale: 2, nullable: true, name: 'precioc' })
  precioC: number;

  // Costo - opcional
  @Column('decimal', { precision: 10, scale: 2, nullable: true })
  costo: number;

  // IVA - opcional hasta que el admin lo complete
  @Column('decimal', { precision: 5, scale: 2, nullable: true })
  iva: number;

  @Column({ nullable: true })
  notes: string;

  // Referencia al producto real creado (cuando el supervisor lo aplica)
  @Column({ name: 'product_id', nullable: true })
  productId: string;

  // Control de flujo de trabajo
  @Column({
    type: 'enum',
    enum: TemporaryProductStatus,
    default: TemporaryProductStatus.PENDING_ADMIN,
  })
  status: TemporaryProductStatus;

  @Column({ name: 'created_by' })
  createdBy: string;

  @Column({ name: 'completed_by_admin', nullable: true })
  completedByAdmin: string;

  @Column({ name: 'completed_by_admin_at', nullable: true })
  completedByAdminAt: Date;

  @Column({ name: 'completed_by_supervisor', nullable: true })
  completedBySupervisor: string;

  @Column({ name: 'completed_by_supervisor_at', nullable: true })
  completedBySupervisorAt: Date;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
