-- 021 - Pagos mixtos (parciales): una venta/factura se puede pagar por
-- partes, ej. cuenta de $50.000 = Bre-B $20.000 + Efectivo $30.000.
--
-- Correr DESPUÉS de la 020 y ANTES de desplegar el backend nuevo:
--   psql "$DATABASE_URL" -f src/migrations/021-pagos-mixtos.sql
--
-- Idempotente: se puede correr más de una vez. Los nombres de restricciones
-- e índices son los que genera TypeORM (synchronize en desarrollo).
--
-- IMPORTANTE: rellena una parte por el total a cada venta/factura existente
-- (con su método actual). El cierre de caja ahora suma el efectivo desde
-- estas partes, así que sin este relleno las ventas viejas no contarían.

BEGIN;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── Partes del pago de cada venta de verduras ──────────────────────────
CREATE TABLE IF NOT EXISTS vegetable_sale_payments (
  id uuid DEFAULT uuid_generate_v4() NOT NULL,
  sale_id uuid NOT NULL,
  payment_method_id uuid NOT NULL,
  amount numeric(12,2) NOT NULL,
  CONSTRAINT "PK_3b372806c1b8f05ec708f427241" PRIMARY KEY (id),
  CONSTRAINT "FK_d36ce4a020072689582d22c02b4" FOREIGN KEY (sale_id)
    REFERENCES vegetable_sales(id) ON DELETE CASCADE,
  CONSTRAINT "FK_0c9acbbc691d51723aea302a997" FOREIGN KEY (payment_method_id)
    REFERENCES payment_methods(id)
);
CREATE INDEX IF NOT EXISTS "IDX_d36ce4a020072689582d22c02b" ON vegetable_sale_payments (sale_id);

-- ── Partes del pago de cada factura ────────────────────────────────────
CREATE TABLE IF NOT EXISTS invoice_payments (
  id uuid DEFAULT uuid_generate_v4() NOT NULL,
  invoice_id uuid NOT NULL,
  payment_method_id uuid NOT NULL,
  amount numeric(12,2) NOT NULL,
  CONSTRAINT "PK_e19c9ebfa432289f510de7b4e99" PRIMARY KEY (id),
  CONSTRAINT "FK_e94fa427d3da279450dba6f4aa6" FOREIGN KEY (invoice_id)
    REFERENCES invoices(id) ON DELETE CASCADE,
  CONSTRAINT "FK_2f162ee21b7b4ec06305f9fcd04" FOREIGN KEY (payment_method_id)
    REFERENCES payment_methods(id)
);
CREATE INDEX IF NOT EXISTS "IDX_e94fa427d3da279450dba6f4aa" ON invoice_payments (invoice_id);

-- ── Cobro Bre-B parcial: total de la venta + con qué se paga el resto ──
ALTER TABLE breb_pending_charges ADD COLUMN IF NOT EXISTS sale_total numeric(12,2);
ALTER TABLE breb_pending_charges ADD COLUMN IF NOT EXISTS rest_payment_method_id uuid;

-- ── Relleno: cada venta/factura existente = una parte por el total ─────
INSERT INTO vegetable_sale_payments (sale_id, payment_method_id, amount)
SELECT s.id, s.payment_method_id, s.total
FROM vegetable_sales s
WHERE NOT EXISTS (SELECT 1 FROM vegetable_sale_payments p WHERE p.sale_id = s.id);

INSERT INTO invoice_payments (invoice_id, payment_method_id, amount)
SELECT i.id, i.payment_method_id, i.total
FROM invoices i
WHERE NOT EXISTS (SELECT 1 FROM invoice_payments p WHERE p.invoice_id = i.id);

COMMIT;
