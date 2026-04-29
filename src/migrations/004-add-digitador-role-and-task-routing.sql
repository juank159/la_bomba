-- Migration: Add digitador role and task routing
-- Date: 2026-04-29
-- Description:
--   1. Add 'digitador' value to user_role enum
--   2. Add granular change types (name, iva, barcode, description) to change_type enum
--   3. Add assigned_role column to product_update_tasks for per-role task routing
--      (when an edit affects multiple roles, separate tasks are created — one per role —
--       so each role can complete independently without affecting the other)

-- 1. Add 'digitador' value to user_role enum
ALTER TYPE users_role_enum ADD VALUE IF NOT EXISTS 'digitador';

-- 2. Add granular change types
ALTER TYPE product_update_tasks_changetype_enum ADD VALUE IF NOT EXISTS 'name';
ALTER TYPE product_update_tasks_changetype_enum ADD VALUE IF NOT EXISTS 'iva';
ALTER TYPE product_update_tasks_changetype_enum ADD VALUE IF NOT EXISTS 'barcode';
ALTER TYPE product_update_tasks_changetype_enum ADD VALUE IF NOT EXISTS 'description';

-- 3. Create assigned_role enum (subset of user_role: only roles that can receive tasks)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'product_update_tasks_assigned_role_enum') THEN
    CREATE TYPE product_update_tasks_assigned_role_enum AS ENUM ('supervisor', 'digitador');
  END IF;
END$$;

-- 4. Add assigned_role column with default 'supervisor' (preserves legacy task visibility)
ALTER TABLE product_update_tasks
ADD COLUMN IF NOT EXISTS "assignedRole" product_update_tasks_assigned_role_enum
NOT NULL DEFAULT 'supervisor';

-- 5. Index to speed up the per-role pending/completed queries
CREATE INDEX IF NOT EXISTS idx_product_update_tasks_assigned_role_status
ON product_update_tasks ("assignedRole", status);

-- Comments
COMMENT ON COLUMN product_update_tasks."assignedRole" IS
  'Rol al que pertenece esta tarea. Cuando un cambio afecta a múltiples roles se crean tareas separadas — una por rol — con su propio status/completedBy/completedAt';
