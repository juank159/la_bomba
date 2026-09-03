import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';

/// Comisión cobrada por el servicio de corresponsal bancario (ej. alguien
/// retira $1.000.000 y se le cobra $1.000 de comisión - eso $1.000 es lo
/// que se registra acá como ingreso). Módulo pequeño a propósito: solo
/// monto + nota opcional, sin editar - si se registró mal, se borra y se
/// vuelve a registrar.
@Entity('corresponsal_entries')
export class CorresponsalEntry {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('decimal', { precision: 10, scale: 2 })
  amount: number;

  @Column({ nullable: true })
  note: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'created_by' })
  createdBy: User;

  @Column({ name: 'created_by' })
  createdById: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
