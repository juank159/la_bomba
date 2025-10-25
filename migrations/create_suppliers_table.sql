-- =====================================================
-- Migration: Create suppliers table
-- Purpose: Store supplier information with same structure as clients
-- Date: 2025-10-25
-- =====================================================

-- Create suppliers table
CREATE TABLE IF NOT EXISTS suppliers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre VARCHAR NOT NULL UNIQUE,
  celular VARCHAR UNIQUE,
  email VARCHAR,
  direccion VARCHAR,
  "isActive" BOOLEAN NOT NULL DEFAULT true,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_suppliers_nombre ON suppliers(nombre);
CREATE INDEX IF NOT EXISTS idx_suppliers_celular ON suppliers(celular);
CREATE INDEX IF NOT EXISTS idx_suppliers_isActive ON suppliers("isActive");

-- Add comment to table
COMMENT ON TABLE suppliers IS 'Tabla de proveedores del sistema';
COMMENT ON COLUMN suppliers.id IS 'Identificador único del proveedor';
COMMENT ON COLUMN suppliers.nombre IS 'Nombre del proveedor (único)';
COMMENT ON COLUMN suppliers.celular IS 'Número de celular del proveedor (único)';
COMMENT ON COLUMN suppliers.email IS 'Correo electrónico del proveedor';
COMMENT ON COLUMN suppliers.direccion IS 'Dirección física del proveedor';
COMMENT ON COLUMN suppliers."isActive" IS 'Indica si el proveedor está activo (soft delete)';
COMMENT ON COLUMN suppliers."createdAt" IS 'Fecha y hora de creación del registro';
COMMENT ON COLUMN suppliers."updatedAt" IS 'Fecha y hora de última actualización del registro';
