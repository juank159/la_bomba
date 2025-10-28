import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
} from 'typeorm';
import { ClientBalance } from './client-balance.entity';
import { Credit } from './credit.entity';
import { PaymentMethod } from './payment-method.entity';

export enum BalanceTransactionType {
  DEPOSIT = 'deposit',       // Dinero agregado al saldo (sobrepago, depósito directo)
  USAGE = 'usage',            // Saldo usado en pago de crédito/pedido
  REFUND = 'refund',          // Devolución de saldo al cliente
  ADJUSTMENT = 'adjustment',  // Ajuste manual (corrección)
}

@Entity('client_balance_transactions')
export class ClientBalanceTransaction {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'client_balance_id' })
  clientBalanceId: string;

  @ManyToOne(() => ClientBalance, balance => balance.transactions, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'client_balance_id' })
  clientBalance: ClientBalance;

  @Column({
    type: 'enum',
    enum: BalanceTransactionType,
  })
  type: BalanceTransactionType;

  @Column({
    type: 'decimal',
    precision: 10,
    scale: 2,
  })
  amount: number;

  @Column({ type: 'text' })
  description: string;

  // Saldo después de esta transacción (para historial)
  @Column({
    type: 'decimal',
    precision: 10,
    scale: 2,
    name: 'balance_after',
  })
  balanceAfter: number;

  // Referencias opcionales a entidades relacionadas
  @Column({ nullable: true, name: 'related_credit_id' })
  relatedCreditId?: string;

  @ManyToOne(() => Credit, { nullable: true })
  @JoinColumn({ name: 'related_credit_id' })
  relatedCredit?: Credit;

  @Column({ nullable: true, name: 'related_order_id' })
  relatedOrderId?: string;

  // Payment method (for refunds)
  @Column({ nullable: true, name: 'payment_method_id' })
  paymentMethodId?: string;

  @ManyToOne(() => PaymentMethod, { nullable: true, eager: true })
  @JoinColumn({ name: 'payment_method_id' })
  paymentMethod?: PaymentMethod;

  // Traceability
  @Column({ name: 'created_by' })
  createdBy: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
