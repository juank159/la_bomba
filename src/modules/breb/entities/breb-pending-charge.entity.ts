import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

/**
 * `matching` = transitorio: un correo ya "reclamó" este cobro (UPDATE
 * atómico `pending → matching`) y se está registrando la venta. Evita que
 * dos correos simultáneos del mismo monto confirmen el MISMO cobro.
 */
export type BrebChargeStatus = 'pending' | 'matching' | 'matched' | 'expired' | 'cancelled';

/** Módulo desde donde se cobró: decide qué se registra al confirmar. */
export type BrebChargeModule = 'vegetables' | 'invoices';

/**
 * Cobro Bre-B "esperando confirmación del banco".
 *
 * Diferencia con Food App: allá el cobro se hace sobre un pedido que ya
 * existe. En La Bomba la venta/factura se crea al cobrar, así que el cobro
 * guarda el BORRADOR completo (`draft`, el mismo cuerpo que POST
 * /vegetables/sales o POST /invoices) y el backend registra la venta solo
 * cuando llega el correo del banco. Así, aunque se cierre la app o se caiga
 * el internet del puesto justo después de que el cliente pague, la venta
 * queda registrada igual — nunca hay plata recibida sin venta.
 */
@Entity('breb_pending_charges')
export class BrebPendingCharge {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 20 })
  @Index()
  module: BrebChargeModule;

  /** Cuerpo de la venta/factura a registrar cuando se confirme el pago. */
  @Column({ type: 'jsonb' })
  draft: Record<string, any>;

  /** Cajero que inició el cobro — dueño de la venta y destino del push. */
  @Column({ name: 'initiated_by_user_id', type: 'uuid' })
  initiatedByUserId: string;

  @Column({ name: 'initiated_by_username', type: 'varchar', length: 100 })
  initiatedByUsername: string;

  /**
   * Monto que el cliente debe transferir (el que va en el QR). Es ÚNICO
   * entre los cobros pendientes: si ya hay otro pendiente por el mismo
   * valor se baja unos pesos — así cada correo apunta a UN solo cobro.
   */
  @Column({ type: 'decimal', precision: 12, scale: 2 })
  amount: number;

  /**
   * Lo que se le pide al cliente por Bre-B, antes del ajuste por monto
   * único. Es el total de la venta, o solo una parte si paga mixto.
   */
  @Column({ name: 'requested_amount', type: 'decimal', precision: 12, scale: 2 })
  requestedAmount: number;

  /**
   * Total de la venta/factura. Solo difiere de `requestedAmount` en un pago
   * mixto (ej. $50.000 de cuenta, $20.000 por Bre-B). `null` en cobros
   * viejos: entonces el total es `requestedAmount`.
   */
  @Column({ name: 'sale_total', type: 'decimal', precision: 12, scale: 2, nullable: true })
  saleTotal: number | null;

  /** Pago mixto: con qué se paga el resto (efectivo u otra cuenta). */
  @Column({ name: 'rest_payment_method_id', type: 'uuid', nullable: true })
  restPaymentMethodId: string | null;

  @Column({ type: 'varchar', length: 20, default: 'pending' })
  @Index()
  status: BrebChargeStatus;

  /** Referencia del correo del banco — idempotencia. */
  @Column({ name: 'matched_reference', type: 'varchar', length: 255, nullable: true })
  @Index({ unique: true, where: '"matched_reference" IS NOT NULL' })
  matchedReference: string | null;

  /** Nombre del cliente que pagó, tal cual viene en el correo. */
  @Column({ name: 'payer_name', type: 'varchar', length: 255, nullable: true })
  payerName: string | null;

  /** Banco que confirmó ("Nequi", "Bancolombia"). */
  @Column({ name: 'bank_label', type: 'varchar', length: 50, nullable: true })
  bankLabel: string | null;

  /** Llave a la que llegó la plata (solo Bancolombia la reporta). */
  @Column({ name: 'matched_llave', type: 'varchar', length: 255, nullable: true })
  matchedLlave: string | null;

  /** Lo que realmente llegó al banco (puede ser menos en asignación manual). */
  @Column({ name: 'received_amount', type: 'decimal', precision: 12, scale: 2, nullable: true })
  receivedAmount: number | null;

  /** Venta de verduras o factura registrada al confirmar. */
  @Column({ name: 'sale_id', type: 'uuid', nullable: true })
  saleId: string | null;

  @Column({ name: 'sale_number', type: 'int', nullable: true })
  saleNumber: number | null;

  @Column({ name: 'confirmed_at', type: 'timestamp with time zone', nullable: true })
  confirmedAt: Date | null;

  /** Cómo se confirmó: 'email' (automático) o 'manual' (asignado a mano). */
  @Column({ name: 'confirmed_via', type: 'varchar', length: 10, nullable: true })
  confirmedVia: 'email' | 'manual' | null;

  /** Último error al intentar registrar la venta (auditoría). */
  @Column({ name: 'last_error', type: 'text', nullable: true })
  lastError: string | null;

  @Column({ name: 'expires_at', type: 'timestamp with time zone' })
  expiresAt: Date;

  @CreateDateColumn({ name: 'created_at', type: 'timestamp with time zone' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamp with time zone' })
  updatedAt: Date;
}
