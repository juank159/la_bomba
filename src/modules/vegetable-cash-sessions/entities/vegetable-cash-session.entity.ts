import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

export enum CashSessionStatus {
  OPEN = 'open',
  CLOSED = 'closed',
}

/// Un turno de caja del puesto de verduras: se abre con un fondo inicial
/// en efectivo y se cierra contando lo que hay físicamente, comparándolo
/// contra lo esperado (fondo inicial + ventas en efectivo - gastos
/// pagados de la caja). Las ventas y los gastos "de caja" quedan
/// vinculados a la sesión que estaba abierta cuando se registraron (ver
/// VegetableSale.cashSessionId y VegetableExpense.cashSessionId).
@Entity('vegetable_cash_sessions')
export class VegetableCashSession {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'enum', enum: CashSessionStatus, default: CashSessionStatus.OPEN })
  status: CashSessionStatus;

  @Column({ name: 'opened_by' })
  openedBy: string;

  @CreateDateColumn({ name: 'opened_at' })
  openedAt: Date;

  @Column('decimal', { name: 'opening_amount', precision: 10, scale: 2 })
  openingAmount: number;

  @Column({ name: 'closed_by', nullable: true })
  closedBy: string;

  @Column({ name: 'closed_at', type: 'timestamp', nullable: true })
  closedAt: Date;

  // Conteo físico real del efectivo al cerrar.
  @Column('decimal', { name: 'closing_amount', precision: 10, scale: 2, nullable: true })
  closingAmount: number;

  // Lo que debería haber: openingAmount + ventas en efectivo - gastos de caja.
  @Column('decimal', { name: 'expected_amount', precision: 10, scale: 2, nullable: true })
  expectedAmount: number;

  // closingAmount - expectedAmount (positivo = sobrante, negativo = faltante).
  @Column('decimal', { precision: 10, scale: 2, nullable: true })
  difference: number;

  @Column({ nullable: true })
  notes: string;
}
