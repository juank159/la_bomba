-- =====================================================
-- Migration: Add supplier to order_items
-- Purpose: Allow assigning suppliers to individual order items
-- Date: 2025-10-25
-- =====================================================

-- Add supplier_id column to order_items table
ALTER TABLE order_items
ADD COLUMN supplier_id UUID REFERENCES suppliers(id) ON DELETE SET NULL;

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_order_items_supplier_id ON order_items(supplier_id);

-- Add comments
COMMENT ON COLUMN order_items.supplier_id IS 'Proveedor asignado al item del pedido (opcional, solo si el pedido no tiene proveedor general)';

-- Update existing rows to have NULL supplier_id (already the default)
-- No action needed as new column is automatically NULL

-- Migration complete
