import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';

/// De dónde salió la plata para pagar el gasto: CAJA lo descuenta del
/// turno de caja abierto (vegetable_cash_sessions) al calcular el cierre;
/// EXTERNAL es dinero que no pasó por la caja del puesto (ej. el dueño lo
/// pagó de su bolsillo) y no afecta el conteo de caja.
export enum ExpenseFundingSource {
  CAJA = 'caja',
  EXTERNAL = 'external',
}

/// Gastos operativos del puesto de verduras (bolsas, hielo, transporte,
/// etc.) - separado de `expenses` (los gastos generales de la aplicación)
/// a propósito, en su propia tabla, para no mezclar las dos contabilidades.
/// La compra de mercancía para vender NO va acá: eso se registra en
/// vegetable_purchases, que además mueve el inventario.
@Entity('vegetable_expenses')
export class VegetableExpense {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  description: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  amount: number;

  @Column({
    type: 'enum',
    enum: ExpenseFundingSource,
    name: 'funding_source',
    default: ExpenseFundingSource.EXTERNAL,
  })
  fundingSource: ExpenseFundingSource;

  // Solo se llena cuando fundingSource = CAJA: el turno de caja del que
  // salió la plata, para poder incluirlo en el cierre de esa caja.
  @Column({ name: 'cash_session_id', nullable: true })
  cashSessionId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'created_by' })
  createdBy: User;

  @Column({ name: 'created_by' })
  createdById: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
