-- Migration: Add corresponsal (banking correspondent commission income)
-- Date: 2026-09-03
-- Description:
--   Small module to register the commission charged for the banking
--   correspondent service (ej. alguien retira $1.000.000 y se cobra
--   $1.000 de comisión - eso $1.000 se registra acá). Just amount + an
--   optional note, no editing - delete and re-add if entered wrong.

CREATE TABLE IF NOT EXISTS corresponsal_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  amount DECIMAL(10, 2) NOT NULL,
  note VARCHAR,
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_corresponsal_entries_created_at ON corresponsal_entries (created_at);

COMMENT ON TABLE corresponsal_entries IS
  'Comisiones cobradas por el servicio de corresponsal bancario (retiros de efectivo).';
