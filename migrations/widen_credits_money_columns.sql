-- Migration: Amplía columnas de dinero del módulo de Créditos
-- Date: 2026-09-21
-- Purpose: numeric(10,2) tiene un tope matemático de $99.999.999,99. Un
--          cliente cuya deuda se acercó a ese límite sufrió un
--          desbordamiento numérico silencioso al intentar superarlo: la
--          transacción quedó registrada en el historial, pero el total
--          real del crédito nunca se actualizó (ver credits.service.ts,
--          addAmountToCredit). Esto pudo pasar con cualquier cliente, en
--          cualquier operación (aumento de deuda, pago, saldo a favor).
--
--          numeric(15,2) sube el tope a ~$9.99 billones de pesos,
--          eliminando el límite en la práctica. 100% seguro: solo amplía
--          la capacidad de la columna, no toca ni un solo valor existente.

ALTER TABLE credits ALTER COLUMN "totalAmount" TYPE numeric(15,2);
ALTER TABLE credits ALTER COLUMN "paidAmount" TYPE numeric(15,2);
ALTER TABLE credit_transactions ALTER COLUMN amount TYPE numeric(15,2);
ALTER TABLE credit_transactions ALTER COLUMN balance_after TYPE numeric(15,2);
ALTER TABLE payments ALTER COLUMN amount TYPE numeric(15,2);
ALTER TABLE client_balances ALTER COLUMN balance TYPE numeric(15,2);
ALTER TABLE client_balance_transactions ALTER COLUMN amount TYPE numeric(15,2);
ALTER TABLE client_balance_transactions ALTER COLUMN "balanceAfter" TYPE numeric(15,2);
