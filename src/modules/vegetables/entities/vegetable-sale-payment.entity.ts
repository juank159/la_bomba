import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn, Index } from 'typeorm';
import { VegetableSale } from './vegetable-sale.entity';
import { PaymentMethod } from '../../credits/entities/payment-method.entity';

/**
 * Cómo se pagó una venta, por partes: una venta de $50.000 puede tener
 * Bre-B $20.000 + Efectivo $30.000. La suma de las partes es el total de la
 * venta. El cierre de caja cuenta como efectivo SOLO las partes en efectivo.
 * Una venta pagada con un solo método tiene una sola parte por el total.
 */
@Entity('vegetable_sale_payments')
export class VegetableSalePayment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => VegetableSale, (sale) => sale.payments, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'sale_id' })
  sale: VegetableSale;

  @Index()
  @Column({ name: 'sale_id' })
  saleId: string;

  @ManyToOne(() => PaymentMethod)
  @JoinColumn({ name: 'payment_method_id' })
  paymentMethod: PaymentMethod;

  @Column({ name: 'payment_method_id' })
  paymentMethodId: string;

  @Column('decimal', { precision: 12, scale: 2 })
  amount: number;
}
