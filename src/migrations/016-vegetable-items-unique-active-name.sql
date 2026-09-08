-- Migration: Enforce unique product name among active vegetable items
-- Date: 2026-09-08
-- Description:
--   Prevents creating two active products with the same name (case
--   insensitive). Scoped to active items only (WHERE is_active = true)
--   so a soft-deleted product doesn't block reusing its name, but
--   reactivating one that collides with an active product still fails.

CREATE UNIQUE INDEX IF NOT EXISTS vegetable_items_active_name_unique
  ON vegetable_items (LOWER(name)) WHERE is_active = true;
