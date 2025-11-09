-- Migration: Add adminNotes column to product_update_tasks table
-- Date: 2025-11-08
-- Description: Adds adminNotes field to store notes from administrators when creating tasks

-- Add adminNotes column
ALTER TABLE product_update_tasks
ADD COLUMN IF NOT EXISTS "adminNotes" TEXT;

-- Add comment to column
COMMENT ON COLUMN product_update_tasks."adminNotes" IS 'Notes from the administrator when creating the task for the supervisor';

-- The existing 'notes' column is for supervisor notes when completing the task
COMMENT ON COLUMN product_update_tasks."notes" IS 'Notes from the supervisor when completing the task';
