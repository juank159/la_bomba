-- Migration: Add vegetable cash sessions (apertura/cierre de caja) and
-- expense funding source (caja vs dinero externo)
-- Date: 2026-09-03
-- Description:
--   - vegetable_cash_sessions: one row per cash-register shift for the
--     vegetables stand. Opens with a starting cash amount, closes with a
--     physical count compared against what's expected (opening amount +
--     cash sales - cash-funded expenses during that session).
--   - vegetable_sales.cash_session_id: which open session (if any) was
--     active when the sale happened - all vegetable sales are cash, so
--     this is what feeds a session's expected cash total.
--   - vegetable_expenses.funding_source + cash_session_id: whether an
--     expense was paid from the register's cash (and therefore reduces
--     that session's expected cash) or with money that never passed
--     through the register.

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'vegetable_cash_sessions_status_enum') THEN
    CREATE TYPE vegetable_cash_sessions_status_enum AS ENUM ('open', 'closed');
  END IF;
END$$;

CREATE TABLE IF NOT EXISTS vegetable_cash_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  status vegetable_cash_sessions_status_enum NOT NULL DEFAULT 'open',
  opened_by VARCHAR NOT NULL,
  opened_at TIMESTAMP NOT NULL DEFAULT now(),
  opening_amount DECIMAL(10, 2) NOT NULL,
  closed_by VARCHAR,
  closed_at TIMESTAMP,
  closing_amount DECIMAL(10, 2),
  expected_amount DECIMAL(10, 2),
  difference DECIMAL(10, 2),
  notes VARCHAR
);

CREATE INDEX IF NOT EXISTS idx_vegetable_cash_sessions_status ON vegetable_cash_sessions (status);
CREATE INDEX IF NOT EXISTS idx_vegetable_cash_sessions_opened_at ON vegetable_cash_sessions (opened_at);

-- Solo puede haber una caja abierta a la vez.
CREATE UNIQUE INDEX IF NOT EXISTS idx_vegetable_cash_sessions_one_open
  ON vegetable_cash_sessions (status)
  WHERE status = 'open';

ALTER TABLE vegetable_sales
  ADD COLUMN IF NOT EXISTS cash_session_id UUID REFERENCES vegetable_cash_sessions(id);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'vegetable_expenses_funding_source_enum') THEN
    CREATE TYPE vegetable_expenses_funding_source_enum AS ENUM ('caja', 'external');
  END IF;
END$$;

ALTER TABLE vegetable_expenses
  ADD COLUMN IF NOT EXISTS funding_source vegetable_expenses_funding_source_enum NOT NULL DEFAULT 'external';

ALTER TABLE vegetable_expenses
  ADD COLUMN IF NOT EXISTS cash_session_id UUID REFERENCES vegetable_cash_sessions(id);

COMMENT ON TABLE vegetable_cash_sessions IS
  'Turnos de caja del puesto de verduras: apertura con fondo inicial, cierre con conteo físico y diferencia contra lo esperado.';
