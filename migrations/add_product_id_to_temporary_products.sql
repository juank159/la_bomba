-- Migration: Add product_id column to temporary_products table
-- Date: 2025-10-22
-- Description: Adds a reference to the actual product created when supervisor applies the temporary product

-- Add product_id column
ALTER TABLE temporary_products
ADD COLUMN IF NOT EXISTS product_id UUID;

-- Add foreign key constraint (optional, if you want to enforce referential integrity)
-- ALTER TABLE temporary_products
-- ADD CONSTRAINT fk_temporary_products_product
-- FOREIGN KEY (product_id) REFERENCES products(id)
-- ON DELETE SET NULL;

-- Add index for faster lookups
CREATE INDEX IF NOT EXISTS idx_temporary_products_product_id
ON temporary_products(product_id);
