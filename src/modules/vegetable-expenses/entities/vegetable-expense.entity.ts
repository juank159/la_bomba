import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';

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
