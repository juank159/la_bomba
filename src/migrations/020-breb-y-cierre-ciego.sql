-- 020 - Cobros con llaves Bre-B (conciliados por correo del banco) + datos
-- Bre-B en ventas de verduras y facturas.
--
-- Idempotente (IF NOT EXISTS): se puede correr más de una vez sin romper.
-- Los nombres de restricciones/índices son los mismos que genera TypeORM
-- (synchronize en desarrollo), para que ambos esquemas queden idénticos.
--
-- Ejecutar en producción ANTES de desplegar el backend nuevo:
--   psql "$DATABASE_URL" -f src/migrations/020-breb-y-cierre-ciego.sql
--
-- El cierre de caja a ciegas no necesita cambios de esquema (es lógica del
-- backend: al verdulero no se le devuelven esperado/diferencia/totales).

BEGIN;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── Método de pago "Bre-B" (código interno 'breb') ─────────────────────
ALTER TABLE payment_methods ADD COLUMN IF NOT EXISTS code character varying(30);
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'UQ_f8aad3eab194dfdae604ca11125') THEN
    ALTER TABLE payment_methods ADD CONSTRAINT "UQ_f8aad3eab194dfdae604ca11125" UNIQUE (code);
  END IF;
END $$;

INSERT INTO payment_methods (name, description, icon, is_active, is_cash, code, created_by)
SELECT 'Bre-B', 'Transferencia con llave Bre-B confirmada automáticamente por el banco', 'breb', true, false, 'breb', 'system'
WHERE NOT EXISTS (SELECT 1 FROM payment_methods WHERE code = 'breb');

-- ── Configuración (una sola fila, la crea el backend al arrancar) ──────
CREATE TABLE IF NOT EXISTS breb_config (
  id integer NOT NULL,
  llaves jsonb DEFAULT '[]'::jsonb NOT NULL,
  inbound_slug character varying(64) NOT NULL,
  updated_by character varying(100),
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT "PK_92717cbfed6e2934af97be33845" PRIMARY KEY (id),
  CONSTRAINT "UQ_fcc58fb2ec4a087f2f2ba23d181" UNIQUE (inbound_slug)
);

-- ── Cobros pendientes de confirmación ─────────────────────────────────
CREATE TABLE IF NOT EXISTS breb_pending_charges (
  id uuid DEFAULT uuid_generate_v4() NOT NULL,
  module character varying(20) NOT NULL,
  draft jsonb NOT NULL,
  initiated_by_user_id uuid NOT NULL,
  initiated_by_username character varying(100) NOT NULL,
  amount numeric(12,2) NOT NULL,
  requested_amount numeric(12,2) NOT NULL,
  status character varying(20) DEFAULT 'pending' NOT NULL,
  matched_reference character varying(255),
  payer_name character varying(255),
  bank_label character varying(50),
  matched_llave character varying(255),
  received_amount numeric(12,2),
  sale_id uuid,
  sale_number integer,
  confirmed_at timestamp with time zone,
  confirmed_via character varying(10),
  last_error text,
  expires_at timestamp with time zone NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT "PK_4aed88c91698b28edc977e32d17" PRIMARY KEY (id)
);
CREATE UNIQUE INDEX IF NOT EXISTS "IDX_176e20d31942fda3f928c9435b"
  ON breb_pending_charges (matched_reference) WHERE (matched_reference IS NOT NULL);
CREATE INDEX IF NOT EXISTS "IDX_5a19f6482b7317a64577258afb" ON breb_pending_charges (status);
CREATE INDEX IF NOT EXISTS "IDX_771b0667cfcf9138a1432d19c7" ON breb_pending_charges (module);

-- ── Correos que no se conciliaron solos (nunca se pierden) ────────────
CREATE TABLE IF NOT EXISTS breb_unmatched_emails (
  id uuid DEFAULT uuid_generate_v4() NOT NULL,
  raw_amount numeric(12,2),
  raw_reference character varying(255),
  raw_payer_name character varying(255),
  raw_body text,
  reason character varying(30) NOT NULL,
  bank_label character varying(50),
  llave character varying(255),
  resolved_charge_id uuid,
  resolved_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT "PK_67f419e79f43de5f6fb7d1b527a" PRIMARY KEY (id)
);

-- ── Datos del pago Bre-B en ventas de verduras y facturas ─────────────
ALTER TABLE vegetable_sales ADD COLUMN IF NOT EXISTS breb_charge_id uuid;
ALTER TABLE vegetable_sales ADD COLUMN IF NOT EXISTS breb_payer_name character varying(255);
ALTER TABLE vegetable_sales ADD COLUMN IF NOT EXISTS breb_bank_label character varying(50);
ALTER TABLE vegetable_sales ADD COLUMN IF NOT EXISTS breb_llave character varying(255);
ALTER TABLE vegetable_sales ADD COLUMN IF NOT EXISTS breb_reference character varying(255);
ALTER TABLE vegetable_sales ADD COLUMN IF NOT EXISTS breb_amount_received numeric(12,2);
CREATE INDEX IF NOT EXISTS "IDX_20f0006d8104cdebd7ace93576" ON vegetable_sales (breb_charge_id);

ALTER TABLE invoices ADD COLUMN IF NOT EXISTS breb_charge_id uuid;
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS breb_payer_name character varying(255);
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS breb_bank_label character varying(50);
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS breb_llave character varying(255);
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS breb_reference character varying(255);
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS breb_amount_received numeric(12,2);
CREATE INDEX IF NOT EXISTS "IDX_e60dace2a0bbed54625a74c763" ON invoices (breb_charge_id);

COMMIT;
