import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToMany, ManyToOne, JoinColumn, DeleteDateColumn } from 'typeorm';
import { Payment } from './payment.entity';
import { Client } from '../../clients/entities/client.entity';

export enum CreditStatus {
  PENDING = 'pending',
  PAID = 'paid',
}

@Entity('credits')
export class Credit {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // Relation with Client
  @ManyToOne(() => Client, client => client.credits, { eager: true })
  @JoinColumn({ name: 'client_id' })
  client: Client;

  @Column({ name: 'client_id' })
  clientId: string;

  @Column()
  description: string;

  // precision 15 (no 10): numeric(10,2) tenía un tope de $99.999.999,99 -
  // un cliente que se acercó a ese límite sufrió un desbordamiento
  // numérico silencioso al intentar superarlo (ver credits.service.ts,
  // addAmountToCredit). numeric(15,2) sube el tope a ~$9.99 billones.
  @Column({ type: 'decimal', precision: 15, scale: 2 })
  totalAmount: number;

  @Column({ type: 'decimal', precision: 15, scale: 2, default: 0 })
  paidAmount: number;

  @Column({
    type: 'enum',
    enum: CreditStatus,
    default: CreditStatus.PENDING,
  })
  status: CreditStatus;

  @OneToMany(() => Payment, payment => payment.credit)
  payments: Payment[];

  // Traceability fields - Track who did what
  @Column({ name: 'created_by', nullable: true })
  createdBy: string; // Username of admin who created this credit

  @Column({ name: 'updated_by', nullable: true })
  updatedBy: string; // Username of admin who last updated this credit

  @Column({ name: 'deleted_by', nullable: true })
  deletedBy: string; // Username of admin who deleted this credit

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @DeleteDateColumn({ name: 'deleted_at' })
  deletedAt?: Date; // Soft delete timestamp

  get remainingAmount(): number {
    return this.totalAmount - this.paidAmount;
  }
}