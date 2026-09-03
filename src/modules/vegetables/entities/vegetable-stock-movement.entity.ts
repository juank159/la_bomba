import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn, CreateDateColumn } from 'typeorm';
import { VegetableItem } from './vegetable-item.entity';

export enum StockMovementType {
  // Entrada de mercancía (compra/reabastecimiento recibido)
  IN = 'in',
  // Salida automática por una venta (creada por el sistema, no por el usuario)
  SALE = 'sale',
  // Merma: producto dañado/vencido que se da de baja del inventario
  MERMA = 'merma',
  // Corrección manual (ej. ajuste tras un conteo físico) - puede ser + o -
  ADJUSTMENT = 'adjustment',
}

/// Un movimiento de inventario: cada cambio al stock de un producto queda
/// registrado acá (quién, cuándo, cuánto, por qué), en vez de solo
/// sobrescribir el número de stock. `vegetable_items.stock` es el saldo
/// actual (para lecturas rápidas); esta tabla es el histórico/auditoría
/// completo de cómo se llegó a ese saldo.
@Entity('vegetable_stock_movements')
export class VegetableStockMovement {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => VegetableItem, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'vegetable_item_id' })
  vegetableItem: VegetableItem;

  @Column({ name: 'vegetable_item_id' })
  vegetableItemId: string;

  @Column({ type: 'enum', enum: StockMovementType })
  type: StockMovementType;

  // Delta aplicado al stock (positivo para IN/ajustes que suman, negativo
  // para SALE/MERMA/ajustes que restan). El stock resultante = stock
  // anterior + quantity.
  @Column('decimal', { precision: 10, scale: 3 })
  quantity: number;

  // Saldo de stock justo después de aplicar este movimiento (snapshot para
  // poder reconstruir el histórico sin recalcular sumando todo cada vez).
  @Column('decimal', { name: 'resulting_stock', precision: 10, scale: 3 })
  resultingStock: number;

  // Obligatorio para MERMA, opcional para el resto.
  @Column({ nullable: true })
  reason: string;

  // Solo se llena cuando type = SALE, para trazabilidad hacia el recibo.
  @Column({ name: 'sale_id', nullable: true })
  saleId: string;

  // Solo se llena cuando type = IN viene de una compra registrada (no de
  // una entrada manual desde Inventario), para trazabilidad hacia la compra.
  @Column({ name: 'purchase_id', nullable: true })
  purchaseId: string;

  @Column({ name: 'created_by' })
  createdBy: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
