-- Migration: Compra libre de verduras + baja lógica de ventas
-- Date: 2026-09-12
-- Purpose: Permite registrar compras de verduras sin producto de catálogo
--          ("compra libre", igual que ya existe "venta libre") y permite
--          eliminar (baja lógica) ventas de verduras igual que ya se hace
--          con las compras.

-- Ventas de verduras: baja lógica (igual que ya existe en vegetable_purchases)
ALTER TABLE vegetable_sales
ADD COLUMN IF NOT EXISTS is_active boolean NOT NULL DEFAULT true;

-- Líneas de compra: permitir compra libre (sin producto de catálogo, sin
-- cantidad ni costo unitario - solo descripción y monto total de la línea)
ALTER TABLE vegetable_purchase_items
ALTER COLUMN vegetable_item_id DROP NOT NULL,
ALTER COLUMN quantity DROP NOT NULL,
ALTER COLUMN unit_cost DROP NOT NULL;
