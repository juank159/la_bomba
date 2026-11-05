import {
  Entity,
  Index,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  OneToMany,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { VegetableSaleItem } from './vegetable-sale-item.entity';
import { PaymentMethod } from '../../credits/entities/payment-method.entity';
import { VegetableSalePayment } from './vegetable-sale-payment.entity';

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

  @OneToMany(() => VegetableSaleItem, (item) => item.sale, { cascade: true })
  items: VegetableSaleItem[];

  // Partes del pago (ej. Bre-B $20.000 + Efectivo $30.000). Suman `total`.
  // `paymentMethodId` de arriba queda como el método principal (Bre-B si
  // hubo Bre-B) para listados; el dinero real se cuenta desde acá.
  @OneToMany(() => VegetableSalePayment, (p) => p.sale)
  payments: VegetableSalePayment[];

  // Baja lógica: false = eliminada (su descuento de inventario ya se
  // revirtió - ver VegetablesService.deleteSale). No se borra la fila para
  // no perder el histórico de ventas.
  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
