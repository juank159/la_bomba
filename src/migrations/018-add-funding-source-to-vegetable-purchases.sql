-- Migration: Add funding source (caja/external) to vegetable purchases
-- Date: 2026-09-09
-- Description:
--   Mismo patrón que vegetable_expenses.funding_source (migración 012):
--   una compra pagada con plata de la caja debe descontarse del efectivo
--   esperado al cerrar el turno, igual que ya pasa con los gastos - antes
--   solo los gastos se restaban, así que una compra pagada de caja
--   descuadraba al cajero (la caja física quedaba con menos plata de la
--   que el sistema esperaba).

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'vegetable_purchases_funding_source_enum') THEN
    CREATE TYPE vegetable_purchases_funding_source_enum AS ENUM ('caja', 'external');
  END IF;
END$$;

ALTER TABLE vegetable_purchases
  ADD COLUMN IF NOT EXISTS funding_source vegetable_purchases_funding_source_enum NOT NULL DEFAULT 'external';

ALTER TABLE vegetable_purchases
  ADD COLUMN IF NOT EXISTS cash_session_id UUID REFERENCES vegetable_cash_sessions(id);

COMMENT ON COLUMN vegetable_purchases.funding_source IS
  'De dónde salió la plata para pagar la compra: caja (se descuenta del cierre de esa caja) o external (dinero que no pasó por la caja).';
