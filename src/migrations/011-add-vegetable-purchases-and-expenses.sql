-- Migration: Add vegetable purchases (compras) and vegetable expenses (gastos)
-- Date: 2026-09-03
-- Description:
--   - vegetable_purchases / vegetable_purchase_items: real purchase
--     transactions (product + quantity + unit cost) for the vegetables
--     module. Unlike vegetable_orders (a simple wishlist to print before
--     buying), a purchase increases inventory automatically through a
--     vegetable_stock_movements 'in' row and keeps the cost paid.
--   - vegetable_stock_movements.purchase_id: traceability from a stock
--     entry back to the purchase that caused it (nullable - manual
--     entries from the Inventario screen have no purchase).
--   - vegetable_expenses: operating expenses for the vegetables stand
--     (bags, ice, transport, etc.), deliberately kept in its own table,
--     separate from the app's general `expenses` table.

CREATE TABLE IF NOT EXISTS vegetable_purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  number SERIAL UNIQUE,
  total DECIMAL(10, 2) NOT NULL,
  created_by VARCHAR NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS vegetable_purchase_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_id UUID NOT NULL REFERENCES vegetable_purchases(id) ON DELETE CASCADE,
  vegetable_item_id UUID NOT NULL REFERENCES vegetable_items(id),
  description VARCHAR NOT NULL,
  quantity DECIMAL(10, 3) NOT NULL,
  unit_cost DECIMAL(10, 2) NOT NULL,
  total DECIMAL(10, 2) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_vegetable_purchase_items_purchase_id ON vegetable_purchase_items (purchase_id);
CREATE INDEX IF NOT EXISTS idx_vegetable_purchases_created_at ON vegetable_purchases (created_at);

ALTER TABLE vegetable_stock_movements
  ADD COLUMN IF NOT EXISTS purchase_id UUID;

CREATE TABLE IF NOT EXISTS vegetable_expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  description VARCHAR NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  created_by UUID NOT NULL REFERENCES users(id),
  "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_vegetable_expenses_created_at ON vegetable_expenses ("createdAt");

COMMENT ON TABLE vegetable_purchases IS
  'Compras reales de mercancía para el módulo de verduras: aumentan el inventario automáticamente y registran el costo pagado.';
COMMENT ON TABLE vegetable_expenses IS
  'Gastos operativos del puesto de verduras (bolsas, hielo, transporte...) - separados de la tabla expenses general de la app.';
