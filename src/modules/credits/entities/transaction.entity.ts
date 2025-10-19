import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Credit } from './credit.entity';

export enum TransactionType {
  DEBT_INCREASE = 'debt_increase',  // Aumento de deuda
  PAYMENT = 'payment',               // Pago
}

@Entity('credit_transactions')
export class CreditTransaction {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // Relation with Credit
  @ManyToOne(() => Credit, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'credit_id' })
  credit: Credit;

  @Column({ name: 'credit_id' })
  creditId: string;

  @Column({
    type: 'enum',
    enum: TransactionType,
  })
  type: TransactionType;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  amount: number;

  @Column({ type: 'text', nullable: true })
  description: string;

  // Traceability - who made this transaction
  @Column({ name: 'created_by', nullable: true })
  createdBy: string;

  @CreateDateColumn()
  createdAt: Date;
}
