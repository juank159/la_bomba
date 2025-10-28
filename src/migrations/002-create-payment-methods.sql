-- src/migrations/002-create-payment-methods.sql
-- Migración para crear tabla de métodos de pago

-- Crear tabla payment_methods
CREATE TABLE IF NOT EXISTS payment_methods (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255),
  icon VARCHAR(50),
  is_active BOOLEAN DEFAULT true,
  created_by VARCHAR(100) NOT NULL,
  updated_by VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Agregar columna payment_method_id a client_balance_transactions
ALTER TABLE client_balance_transactions
ADD COLUMN IF NOT EXISTS payment_method_id UUID REFERENCES payment_methods(id);

-- Índices
CREATE INDEX IF NOT EXISTS idx_payment_methods_active ON payment_methods(is_active);
CREATE INDEX IF NOT EXISTS idx_payment_methods_name ON payment_methods(name);
CREATE INDEX IF NOT EXISTS idx_client_balance_transactions_payment_method
  ON client_balance_transactions(payment_method_id);

-- Insertar métodos de pago por defecto
INSERT INTO payment_methods (name, description, icon, is_active, created_by)
VALUES
  ('Efectivo', 'Pago en efectivo', 'cash', true, 'system'),
  ('Transferencia Bancaria', 'Transferencia a cuenta bancaria', 'bank_transfer', true, 'system'),
  ('Nequi', 'Pago por Nequi', 'mobile_payment', true, 'system'),
  ('Daviplata', 'Pago por Daviplata', 'mobile_payment', true, 'system'),
  ('Tarjeta Débito', 'Pago con tarjeta débito', 'debit_card', true, 'system'),
  ('Tarjeta Crédito', 'Pago con tarjeta crédito', 'credit_card', true, 'system')
ON CONFLICT DO NOTHING;

-- Comentarios
COMMENT ON TABLE payment_methods IS 'Métodos de pago disponibles para devoluciones y transacciones';
COMMENT ON COLUMN payment_methods.name IS 'Nombre del método de pago';
COMMENT ON COLUMN payment_methods.description IS 'Descripción del método de pago';
COMMENT ON COLUMN payment_methods.icon IS 'Icono asociado al método de pago';
COMMENT ON COLUMN payment_methods.is_active IS 'Indica si el método de pago está activo';
COMMENT ON COLUMN client_balance_transactions.payment_method_id IS 'Método de pago utilizado en la transacción';
