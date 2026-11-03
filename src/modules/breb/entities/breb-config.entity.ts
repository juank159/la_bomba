import { Column, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

/**
 * Una llave Bre-B del negocio. El administrador decide en qué módulo se
 * muestra cada una (Facturación y/o Verduras) — así cada caja le enseña al
 * cliente solo las llaves/QR que le corresponden.
 */
export interface BrebLlaveConfig {
  id: string;
  /** Nombre amigable: "Nequi negocio", "Bancolombia". */
  label: string;
  /** La llave tal cual se le dicta al cliente: "3001234567", "@labomba". */
  llave: string;
  /** Texto crudo del QR EMV que da el banco (opcional). */
  qr_template?: string;
  show_in_invoices: boolean;
  show_in_vegetables: boolean;
}

/**
 * Configuración única (una sola fila, id = 1) de la conciliación Bre-B.
 * La Bomba no es multi-negocio como Food App, así que en vez de guardar
 * esto en `tenant.settings` vive en su propia tabla.
 */
@Entity('breb_config')
export class BrebConfig {
  @PrimaryColumn({ type: 'int' })
  id: number;

  @Column({ type: 'jsonb', default: () => "'[]'::jsonb" })
  llaves: BrebLlaveConfig[];

  /**
   * Slug aleatorio e impredecible de la dirección de reenvío:
   * pagos-<slug>@<BREB_INBOUND_DOMAIN>. Es lo único que autentica que un
   * correo entrante le pertenece a este negocio (además de la firma de
   * Mailgun).
   */
  @Column({ name: 'inbound_slug', type: 'varchar', length: 64, unique: true })
  inboundSlug: string;

  @Column({ name: 'updated_by', type: 'varchar', length: 100, nullable: true })
  updatedBy: string | null;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamp with time zone' })
  updatedAt: Date;
}
