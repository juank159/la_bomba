import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, OneToMany } from 'typeorm';
import { VegetablePurchaseItem } from './vegetable-purchase-item.entity';

/// Mirrors ExpenseFundingSource (vegetable-expense.entity.ts) - de dónde
/// salió la plata para pagar la compra. CAJA la descuenta del turno de
/// caja abierto al calcular el cierre; EXTERNAL no afecta el conteo de
/// caja. Cada entidad tiene su propio enum (mismos valores) en vez de
/// compartir uno para no acoplar los dos módulos.
export enum PurchaseFundingSource {
  CAJA = 'caja',
  EXTERNAL = 'external',
}

/// A completed purchase of produce for the vegetables module: what was
/// bought, how much it cost, and (via VegetablesService.createPurchase)
/// automatically adds the bought quantity to each item's inventory.
@Entity('vegetable_purchases')
export class VegetablePurchase {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // Consecutivo legible, igual que en ventas/facturas (no es la PK).
  @Column({ type: 'int', generated: 'increment', unique: true })
  number: number;

  @Column('decimal', { precision: 10, scale: 2 })
  total: number;

  @Column({ name: 'created_by' })
  createdBy: string;

  @Column({
    type: 'enum',
    enum: PurchaseFundingSource,
    name: 'funding_source',
    default: PurchaseFundingSource.EXTERNAL,
  })
  fundingSource: PurchaseFundingSource;

  // Solo se llena cuando fundingSource = CAJA: el turno de caja del que
  // salió la plata, para poder incluirlo en el cierre de esa caja.
  @Column({ name: 'cash_session_id', nullable: true })
  cashSessionId: string;

  // Baja lógica: false = eliminada (sus movimientos de inventario ya se
  // revirtieron - ver VegetablesService.deletePurchase). No se borra la
  // fila para no perder el histórico de costos.
  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @OneToMany(() => VegetablePurchaseItem, (item) => item.purchase, { cascade: true })
  items: VegetablePurchaseItem[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
