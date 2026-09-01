-- Migration: Add vegetables sales module
-- Date: 2026-09-01
-- Description:
--   1. Add 'verdulero' role (verduras stand employee)
--   2. Create vegetable_items catalog (weight-priced or fixed-price produce)
--   3. Create vegetable_sales / vegetable_sale_items (separate from invoices,
--      no IVA — produce is not taxed — sold independently by the verdulero role)

-- 1. Add 'verdulero' role
ALTER TYPE users_role_enum ADD VALUE IF NOT EXISTS 'verdulero';

-- 2. Pricing type enum
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'vegetable_items_pricing_type_enum') THEN
    CREATE TYPE vegetable_items_pricing_type_enum AS ENUM ('weight', 'fixed');
  END IF;
END$$;

-- 3. Catalog
CREATE TABLE IF NOT EXISTS vegetable_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR NOT NULL,
  pricing_type vegetable_items_pricing_type_enum NOT NULL,
  price_per_kg DECIMAL(10, 2),
  fixed_price DECIMAL(10, 2),
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now()
);

-- 4. Sales header
CREATE TABLE IF NOT EXISTS vegetable_sales (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  number SERIAL UNIQUE,
  total DECIMAL(10, 2) NOT NULL,
  sold_by VARCHAR NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

-- 5. Sale line items
CREATE TABLE IF NOT EXISTS vegetable_sale_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id UUID NOT NULL REFERENCES vegetable_sales(id) ON DELETE CASCADE,
  vegetable_item_id UUID REFERENCES vegetable_items(id),
  description VARCHAR NOT NULL,
  pricing_type vegetable_items_pricing_type_enum NOT NULL,
  weight_kg DECIMAL(10, 3),
  quantity INT,
  unit_price DECIMAL(10, 2) NOT NULL,
  total DECIMAL(10, 2) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_vegetable_sale_items_sale_id ON vegetable_sale_items (sale_id);
CREATE INDEX IF NOT EXISTS idx_vegetable_sales_created_at ON vegetable_sales (created_at);

COMMENT ON TABLE vegetable_items IS
  'Catálogo del módulo de verduras: productos que se pesan en báscula (pricing_type=weight) o de precio fijo por unidad (pricing_type=fixed).';
COMMENT ON TABLE vegetable_sales IS
  'Ventas del módulo de verduras. Independiente de invoices/facturación: las verduras no llevan IVA.';
