import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn } from 'typeorm';

export type BrebUnmatchedReason =
  | 'unknown_slug'
  | 'not_approved'
  | 'not_a_sale'
  | 'parse_error'
  | 'status_rejected'
  | 'no_pending_match'
  | 'multiple_matches'
  | 'registration_failed'
  // Otro correo simultáneo ya había reclamado el único cobro candidato.
  | 'already_claimed';

/** Motivos en los que la plata SÍ llegó: el cajero puede asignarla a mano. */
export const BREB_ASSIGNABLE_REASONS: BrebUnmatchedReason[] = [
  'no_pending_match',
  'multiple_matches',
  'registration_failed',
  'already_claimed',
];

/**
 * Todo correo que llegó a la dirección Bre-B y NO se pudo conciliar solo
 * queda acá — nunca se descarta en silencio. Es la base de "Buscar pago"
 * (asignación manual) y de "Correos recibidos" en Configuración.
 */
@Entity('breb_unmatched_emails')
export class BrebUnmatchedEmail {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'raw_amount', type: 'decimal', precision: 12, scale: 2, nullable: true })
  rawAmount: number | null;

  @Column({ name: 'raw_reference', type: 'varchar', length: 255, nullable: true })
  rawReference: string | null;

  @Column({ name: 'raw_payer_name', type: 'varchar', length: 255, nullable: true })
  rawPayerName: string | null;

  @Column({ name: 'raw_body', type: 'text', nullable: true })
  rawBody: string | null;

  @Column({ type: 'varchar', length: 30 })
  reason: BrebUnmatchedReason;

  @Column({ name: 'bank_label', type: 'varchar', length: 50, nullable: true })
  bankLabel: string | null;

  @Column({ type: 'varchar', length: 255, nullable: true })
  llave: string | null;

  /** Cobro al que se asignó a mano — un correo asignado no se reutiliza. */
  @Column({ name: 'resolved_charge_id', type: 'uuid', nullable: true })
  resolvedChargeId: string | null;

  @Column({ name: 'resolved_at', type: 'timestamp with time zone', nullable: true })
  resolvedAt: Date | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamp with time zone' })
  createdAt: Date;
}
