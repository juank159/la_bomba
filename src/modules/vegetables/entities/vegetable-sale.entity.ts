import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  OneToMany,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { VegetableSaleItem } from './vegetable-sale-item.entity';
import { PaymentMethod } from '../../credits/entities/payment-method.entity';

@Entity('vegetable_sales')
export class VegetableSale {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // Consecutivo legible para el recibo (no es la PK), igual que en invoices.
  @Column({ type: 'int', generated: 'increment', unique: true })
  number: number;

  @Column('decimal', { precision: 10, scale: 2 })
  total: number;

  @Column({ name: 'sold_by' })
  soldBy: string;

  // Cómo pagó el cliente: efectivo o uno de los métodos de transferencia
  // (Nequi, Bancolombia, etc.). Determina si esta venta cuenta como
  // efectivo real en el cierre de caja (paymentMethod.isCash) o como
  // plata que fue a un banco.
  @ManyToOne(() => PaymentMethod)
  @JoinColumn({ name: 'payment_method_id' })
  paymentMethod: PaymentMethod;

  @Column({ name: 'payment_method_id' })
  paymentMethodId: string;

  // Turno de caja que estaba abierto al momento de la venta (null si no
  // había ninguno abierto).
  @Column({ name: 'cash_session_id', nullable: true })
  cashSessionId: string;

  @OneToMany(() => VegetableSaleItem, (item) => item.sale, { cascade: true })
  items: VegetableSaleItem[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
