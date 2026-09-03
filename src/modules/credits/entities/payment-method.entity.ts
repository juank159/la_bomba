// src/modules/credits/entities/payment-method.entity.ts

import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('payment_methods')
export class PaymentMethod {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 100 })
  name: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  description: string;

  @Column({ type: 'varchar', length: 50, nullable: true })
  icon: string; // Nombre del icono (ej: 'cash', 'credit_card', 'bank_transfer')

  @Column({ name: 'is_active', type: 'boolean', default: true })
  isActive: boolean;

  // true solo para el método que representa dinero físico en la caja (ej.
  // "Efectivo"). El cierre de caja del módulo de verduras usa esto para
  // saber qué ventas cuentan como efectivo real vs plata que fue a un
  // banco (Nequi, Bancolombia, etc.) y por lo tanto no está en la caja.
  @Column({ name: 'is_cash', type: 'boolean', default: false })
  isCash: boolean;

  @Column({ name: 'created_by', type: 'varchar', length: 100 })
  createdBy: string;

  @Column({ name: 'updated_by', type: 'varchar', length: 100, nullable: true })
  updatedBy: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
