-- Migration: Add PRODUCT_UPDATE notification type
-- Date: 2025-10-30
-- Description: Adds 'product_update' to the notification type enum for product update notifications

-- PostgreSQL automatically handles enum updates through TypeORM
-- This migration is for documentation purposes

-- The new notification type 'product_update' will be used when:
-- - An admin updates a product (name, price, or IVA)
-- - Supervisors need to be notified of the change

-- Note: TypeORM will automatically sync the enum values
-- No manual ALTER TYPE command needed
