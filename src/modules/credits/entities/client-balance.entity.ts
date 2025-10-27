import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  OneToMany,
  OneToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Client } from '../../clients/entities/client.entity';
import { ClientBalanceTransaction } from './client-balance-transaction.entity';

@Entity('client_balances')
export class ClientBalance {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true, name: 'client_id' })
  clientId: string;

  @OneToOne(() => Client, { eager: true })
  @JoinColumn({ name: 'client_id' })
  client: Client;

  // Saldo actual del cliente
  // Positivo: Cliente tiene saldo a favor (la tienda le debe)
  // Cero: Sin saldo
  // Nota: No permitimos saldo negativo (las deudas se manejan con Credits)
  @Column({
    type: 'decimal',
    precision: 10,
    scale: 2,
    default: 0,
  })
  balance: number;

  @OneToMany(() => ClientBalanceTransaction, transaction => transaction.clientBalance, {
    cascade: true,
  })
  transactions: ClientBalanceTransaction[];

  // Traceability
  @Column({ name: 'created_by' })
  createdBy: string;

  @Column({ nullable: true, name: 'updated_by' })
  updatedBy: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
