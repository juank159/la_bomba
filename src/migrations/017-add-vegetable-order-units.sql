-- Migration: Add more units for vegetable orders (pedidos)
-- Date: 2026-09-09
-- Description:
--   The "pedido" (restock order) form only offered kilogramos/libras/
--   unidad, but produce is often ordered in cajas, bolsas, bandejas,
--   cestas, bultos, rollos, docena or canastas. Adds those values to the
--   existing enum type - additive only, no data changes.
--
-- Nota: ALTER TYPE ... ADD VALUE no puede ejecutarse dentro de un bloque
-- de transacción junto con un uso posterior de ese valor en la misma
-- transacción, así que estas sentencias van sueltas (cada una hace commit
-- implícito por su cuenta), no envueltas en BEGIN/COMMIT.

ALTER TYPE vegetable_order_items_unit_enum ADD VALUE IF NOT EXISTS 'caja';
ALTER TYPE vegetable_order_items_unit_enum ADD VALUE IF NOT EXISTS 'bolsa';
ALTER TYPE vegetable_order_items_unit_enum ADD VALUE IF NOT EXISTS 'bandeja';
ALTER TYPE vegetable_order_items_unit_enum ADD VALUE IF NOT EXISTS 'cesta';
ALTER TYPE vegetable_order_items_unit_enum ADD VALUE IF NOT EXISTS 'bulto';
ALTER TYPE vegetable_order_items_unit_enum ADD VALUE IF NOT EXISTS 'rollo';
ALTER TYPE vegetable_order_items_unit_enum ADD VALUE IF NOT EXISTS 'docena';
ALTER TYPE vegetable_order_items_unit_enum ADD VALUE IF NOT EXISTS 'canasta';
