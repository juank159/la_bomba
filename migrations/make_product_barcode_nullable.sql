-- Migration: Make barcode column nullable in products table
-- Date: 2025-10-26
-- Purpose: Allow products to be created without a barcode initially
--          The supervisor can add the barcode later

-- Make barcode column nullable
ALTER TABLE products
ALTER COLUMN barcode DROP NOT NULL;

-- Add comment explaining the change
COMMENT ON COLUMN products.barcode IS 'Product barcode - nullable to allow supervisor to add it later';
