-- Migración: Crear tablas para sistema de saldo a favor de clientes
-- Fecha: 2025-10-27
-- Descripción: Agrega soporte para manejo de sobrepagos y saldo a favor de clientes

-- ============================================================================
-- Tabla: client_balances
-- ============================================================================
CREATE TABLE IF NOT EXISTS client_balances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL UNIQUE,
  balance DECIMAL(10, 2) NOT NULL DEFAULT 0,
  created_by VARCHAR NOT NULL,
  updated_by VARCHAR,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_client_balance_client FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
);

-- Índice para búsqueda rápida por cliente
CREATE INDEX IF NOT EXISTS idx_client_balances_client_id ON client_balances(client_id);

-- Índice para búsqueda de saldos positivos
CREATE INDEX IF NOT EXISTS idx_client_balances_balance ON client_balances(balance) WHERE balance > 0;

COMMENT ON TABLE client_balances IS 'Saldo a favor de clientes (prepago/sobrepago)';
COMMENT ON COLUMN client_balances.balance IS 'Saldo actual del cliente - Positivo: cliente tiene saldo a favor';
COMMENT ON COLUMN client_balances.client_id IS 'Referencia al cliente (relación 1:1)';

-- ============================================================================
-- Tabla: client_balance_transactions
-- ============================================================================
CREATE TABLE IF NOT EXISTS client_balance_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_balance_id UUID NOT NULL,
  type VARCHAR NOT NULL CHECK (type IN ('deposit', 'usage', 'refund', 'adjustment')),
  amount DECIMAL(10, 2) NOT NULL,
  description TEXT NOT NULL,
  balance_after DECIMAL(10, 2) NOT NULL,
  related_credit_id UUID,
  related_order_id UUID,
  created_by VARCHAR NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_balance_transaction_balance FOREIGN KEY (client_balance_id) REFERENCES client_balances(id) ON DELETE CASCADE,
  CONSTRAINT fk_balance_transaction_credit FOREIGN KEY (related_credit_id) REFERENCES credits(id) ON DELETE SET NULL
);

-- Índices para búsqueda eficiente
CREATE INDEX IF NOT EXISTS idx_balance_transactions_balance_id ON client_balance_transactions(client_balance_id);
CREATE INDEX IF NOT EXISTS idx_balance_transactions_type ON client_balance_transactions(type);
CREATE INDEX IF NOT EXISTS idx_balance_transactions_created_at ON client_balance_transactions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_balance_transactions_credit_id ON client_balance_transactions(related_credit_id) WHERE related_credit_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_balance_transactions_order_id ON client_balance_transactions(related_order_id) WHERE related_order_id IS NOT NULL;

COMMENT ON TABLE client_balance_transactions IS 'Historial de transacciones de saldo de clientes';
COMMENT ON COLUMN client_balance_transactions.type IS 'Tipo: deposit=sobrepago, usage=uso en pago, refund=devolución, adjustment=ajuste manual';
COMMENT ON COLUMN client_balance_transactions.balance_after IS 'Saldo del cliente después de esta transacción (para auditoría)';
COMMENT ON COLUMN client_balance_transactions.related_credit_id IS 'ID del crédito relacionado (opcional)';
COMMENT ON COLUMN client_balance_transactions.related_order_id IS 'ID del pedido relacionado (opcional)';

-- ============================================================================
-- Información de la migración
-- ============================================================================
COMMENT ON TABLE client_balances IS 'Sistema de saldo a favor de clientes - Migración 001';
COMMENT ON TABLE client_balance_transactions IS 'Historial de transacciones de saldo - Migración 001';

-- ============================================================================
-- Verificación
-- ============================================================================
-- Para verificar que las tablas se crearon correctamente:
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'client_balance%';
