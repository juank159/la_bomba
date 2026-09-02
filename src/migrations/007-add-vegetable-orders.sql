-- Migration: Add vegetable orders (pedidos de reabastecimiento)
-- Date: 2026-09-02
-- Description:
--   Simple restock list for the vegetables module: no supplier, no status
--   workflow - just items + quantity + unit (kilogramos/libras/unidad, same
--   values as the regular Order module's MeasurementUnit), with history.

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'vegetable_order_items_unit_enum') THEN
    CREATE TYPE vegetable_order_items_unit_enum AS ENUM ('kilogramos', 'libras', 'unidad');
  END IF;
END$$;

CREATE TABLE IF NOT EXISTS vegetable_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  number SERIAL UNIQUE,
  created_by VARCHAR NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS vegetable_order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES vegetable_orders(id) ON DELETE CASCADE,
  vegetable_item_id UUID REFERENCES vegetable_items(id),
  description VARCHAR NOT NULL,
  quantity DECIMAL(10, 3) NOT NULL,
  unit vegetable_order_items_unit_enum NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_vegetable_order_items_order_id ON vegetable_order_items (order_id);
CREATE INDEX IF NOT EXISTS idx_vegetable_orders_created_at ON vegetable_orders (created_at);

COMMENT ON TABLE vegetable_orders IS
  'Pedidos/lista de reabastecimiento del módulo de verduras: sin proveedor ni estado, solo items + cantidad + unidad, para imprimir/generar PDF.';
