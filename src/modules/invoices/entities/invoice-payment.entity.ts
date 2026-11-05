import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn, Index } from 'typeorm';
import { Invoice } from './invoice.entity';
import { PaymentMethod } from '../../credits/entities/payment-method.entity';

/**
 * Cómo se pagó una factura, por partes (ej. Bre-B $20.000 + Efectivo
 * $30.000). La suma de las partes es el total de la factura. Ver
 * VegetableSalePayment, misma idea.
 */
@Entity('invoice_payments')
export class InvoicePayment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Invoice, (invoice) => invoice.payments, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'invoice_id' })
  invoice: Invoice;

  @Index()
  @Column({ name: 'invoice_id' })
  invoiceId: string;

  @ManyToOne(() => PaymentMethod)
  @JoinColumn({ name: 'payment_method_id' })
  paymentMethod: PaymentMethod;

  @Column({ name: 'payment_method_id' })
  paymentMethodId: string;

  @Column('decimal', { precision: 12, scale: 2 })
  amount: number;
}
