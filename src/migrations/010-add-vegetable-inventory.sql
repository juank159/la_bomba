-- Migration: Add vegetable inventory (stock) + merma tracking
-- Date: 2026-09-03
-- Description:
--   Basic inventory for the vegetables module: a `stock` balance per
--   vegetable_items row, kept in sync through a full movement ledger
--   (vegetable_stock_movements) so every change is auditable - entries
--   (in), automatic deductions on sale (sale), damaged/spoiled produce
--   write-offs (merma), and manual corrections (adjustment).

ALTER TABLE vegetable_items
  ADD COLUMN IF NOT EXISTS stock DECIMAL(10, 3) NOT NULL DEFAULT 0;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'vegetable_stock_movements_type_enum') THEN
    CREATE TYPE vegetable_stock_movements_type_enum AS ENUM ('in', 'sale', 'merma', 'adjustment');
  END IF;
END$$;

CREATE TABLE IF NOT EXISTS vegetable_stock_movements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vegetable_item_id UUID NOT NULL REFERENCES vegetable_items(id) ON DELETE CASCADE,
  type vegetable_stock_movements_type_enum NOT NULL,
  quantity DECIMAL(10, 3) NOT NULL,
  resulting_stock DECIMAL(10, 3) NOT NULL,
  reason VARCHAR,
  sale_id UUID,
  created_by VARCHAR NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_vegetable_stock_movements_item_id
  ON vegetable_stock_movements (vegetable_item_id);
CREATE INDEX IF NOT EXISTS idx_vegetable_stock_movements_created_at
  ON vegetable_stock_movements (created_at);

COMMENT ON TABLE vegetable_stock_movements IS
  'Historial/auditoría de cada cambio al stock de un producto de verduras: entradas, ventas (automático), mermas y ajustes manuales.';
COMMENT ON COLUMN vegetable_items.stock IS
  'Saldo actual de inventario (kg si pricing_type=weight, unidades si =fixed). Se mantiene en sincronía con vegetable_stock_movements.';
