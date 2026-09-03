-- Migration: Add payment method to vegetable sales + isCash flag
-- Date: 2026-09-03
-- Description:
--   - payment_methods.is_cash: marks which payment method represents
--     physical cash in the register (only "Efectivo") vs money that went
--     to a bank (Nequi, Bancolombia, etc.) and therefore isn't in the
--     drawer. Used by vegetable_cash_sessions to compute the real
--     expected cash on close.
--   - vegetable_sales.payment_method_id: how the customer paid for a
--     vegetable sale (same payment_methods table Facturación already
--     uses). Historical sales (before this feature existed) are
--     backfilled as "Efectivo", matching how they were already treated
--     100% as cash in the cash-session close calculation.

ALTER TABLE payment_methods
  ADD COLUMN IF NOT EXISTS is_cash BOOLEAN NOT NULL DEFAULT false;

UPDATE payment_methods SET is_cash = true WHERE name = 'Efectivo' AND NOT is_cash;

ALTER TABLE vegetable_sales
  ADD COLUMN IF NOT EXISTS payment_method_id UUID REFERENCES payment_methods(id);

UPDATE vegetable_sales
SET payment_method_id = (SELECT id FROM payment_methods WHERE name = 'Efectivo' LIMIT 1)
WHERE payment_method_id IS NULL;

ALTER TABLE vegetable_sales
  ALTER COLUMN payment_method_id SET NOT NULL;

COMMENT ON COLUMN payment_methods.is_cash IS
  'true solo para el método que representa efectivo físico en caja (Efectivo). Usado por el cierre de caja de verduras.';
COMMENT ON COLUMN vegetable_sales.payment_method_id IS
  'Cómo pagó el cliente (efectivo o un método de transferencia). Ventas históricas se marcaron como Efectivo.';
