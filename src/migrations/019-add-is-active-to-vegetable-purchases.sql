-- Migration: Add soft delete (is_active) to vegetable purchases
-- Date: 2026-09-10
-- Description:
--   Las compras de verduras no se podían editar ni borrar - si alguien
--   digitaba mal el valor (ej. $37.000.000 en vez de $3.700.000) quedaba
--   así para siempre, descuadrando inventario y el cuadre de caja. Se
--   agrega is_active (baja lógica, mismo patrón que vegetable_items) para
--   poder eliminar una compra sin perder el registro histórico.

ALTER TABLE vegetable_purchases
  ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT true;

COMMENT ON COLUMN vegetable_purchases.is_active IS
  'Baja lógica: false = compra eliminada (sus movimientos de inventario ya se revirtieron). No se borra la fila para no perder el histórico.';
