import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn, DeleteDateColumn } from 'typeorm';
import { Credit } from './credit.entity';

@Entity('payments')
export class Payment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Credit, credit => credit.payments, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'credit_id' })
  credit: Credit;

  @Column({ name: 'credit_id' })
  creditId: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  amount: number;

  @Column({ nullable: true })
  description: string;

  // Traceability fields - Track who made this payment
  @Column({ name: 'created_by', nullable: true })
  createdBy: string; // Username of admin who created this payment

  @Column({ name: 'deleted_by', nullable: true })
  deletedBy: string; // Username of admin who deleted this payment

  @CreateDateColumn()
  createdAt: Date;

  @DeleteDateColumn({ name: 'deleted_at' })
  deletedAt?: Date; // Soft delete timestamp
}