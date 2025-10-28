-- Migration: Add payment_method_id to credit_transactions table
-- Description: Adds foreign key to payment_methods for tracking payment method used in each transaction

-- Add payment_method_id column
ALTER TABLE credit_transactions
ADD COLUMN payment_method_id UUID NULL;

-- Add foreign key constraint
ALTER TABLE credit_transactions
ADD CONSTRAINT fk_credit_transactions_payment_method
FOREIGN KEY (payment_method_id)
REFERENCES payment_methods(id)
ON DELETE SET NULL;

-- Add index for better query performance
CREATE INDEX idx_credit_transactions_payment_method_id
ON credit_transactions(payment_method_id);

-- Add comment to the column
COMMENT ON COLUMN credit_transactions.payment_method_id IS 'Payment method used for this transaction (only applicable for payment type transactions)';
