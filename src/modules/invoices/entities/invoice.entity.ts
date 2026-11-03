import {
  Entity,
  Index,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { Client } from '../../clients/entities/client.entity';
import { PaymentMethod } from '../../credits/entities/payment-method.entity';
import { InvoiceItem } from './invoice-item.entity';

export enum InvoiceStatus {
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
}

@Entity('invoices')
export class Invoice {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // Consecutivo legible para el cliente/recibo (no es la PK)
  @Column({ type: 'int', generated: 'increment', unique: true })
  number: number;

  @ManyToOne(() => Client, { nullable: true })
  @JoinColumn({ name: 'client_id' })
  client: Client;

  @Column({ name: 'client_id', nullable: true })
  clientId: string;

  @ManyToOne(() => PaymentMethod)
  @JoinColumn({ name: 'payment_method_id' })
  paymentMethod: PaymentMethod;

  @Column({ name: 'payment_method_id' })
  paymentMethodId: string;

  @Column('decimal', { precision: 10, scale: 2 })
  subtotal: number;

  @Column('decimal', { precision: 10, scale: 2 })
  tax: number;

  @Column('decimal', { precision: 10, scale: 2 })
  total: number;

  @Column({
    type: 'enum',
    enum: InvoiceStatus,
    default: InvoiceStatus.COMPLETED,
  })
  status: InvoiceStatus;

  @Column({ name: 'created_by' })
  createdBy: string;

  @Column({ name: 'cancelled_by', nullable: true })
  cancelledBy: string;

  @Column({ name: 'cancelled_at', type: 'timestamp', nullable: true })
  cancelledAt: Date;

  // ── Pago Bre-B (solo si se cobró con llave Bre-B, ver BrebService) ──
  // Quién pagó (nombre del cliente según el banco), por qué banco/llave
  // entró y con qué referencia — lo que permite cuadrar contra el extracto.
  @Index()
  @Column({ name: 'breb_charge_id', type: 'uuid', nullable: true })
  brebChargeId: string | null;

  @Column({ name: 'breb_payer_name', type: 'varchar', length: 255, nullable: true })
  brebPayerName: string | null;

  @Column({ name: 'breb_bank_label', type: 'varchar', length: 50, nullable: true })
  brebBankLabel: string | null;

  @Column({ name: 'breb_llave', type: 'varchar', length: 255, nullable: true })
  brebLlave: string | null;

  @Column({ name: 'breb_reference', type: 'varchar', length: 255, nullable: true })
  brebReference: string | null;

  // Lo que realmente llegó al banco. Puede ser hasta $9 menos que el total
  // (ajuste para que el monto del cobro sea único y se identifique solo).
  @Column({ name: 'breb_amount_received', type: 'decimal', precision: 12, scale: 2, nullable: true })
  brebAmountReceived: number | null;

  @OneToMany(() => InvoiceItem, item => item.invoice, { cascade: true })
  items: InvoiceItem[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
