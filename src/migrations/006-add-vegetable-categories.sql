-- Migration: Add categories to the vegetables module
-- Date: 2026-09-01
-- Description:
--   1. Create vegetable_categories (ej. "Frutas", "Verduras") - own catalog,
--      manageable independently from products
--   2. Link vegetable_items to an optional category

CREATE TABLE IF NOT EXISTS vegetable_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR NOT NULL UNIQUE,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now()
);

ALTER TABLE vegetable_items
ADD COLUMN IF NOT EXISTS category_id UUID REFERENCES vegetable_categories(id);

CREATE INDEX IF NOT EXISTS idx_vegetable_items_category_id ON vegetable_items (category_id);

COMMENT ON TABLE vegetable_categories IS
  'Categorías del catálogo de verduras (ej. Frutas, Verduras) - administrables aparte del catálogo de productos.';

-- Seed the two categories the business asked for by name, so they're
-- available right away without needing a manual first step.
INSERT INTO vegetable_categories (name)
VALUES ('Verduras'), ('Frutas')
ON CONFLICT (name) DO NOTHING;
