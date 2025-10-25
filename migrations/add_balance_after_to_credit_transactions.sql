-- =====================================================
-- Migration: Add balance_after column to credit_transactions
-- Purpose: Track balance after each credit transaction
-- Date: 2025-10-25
-- =====================================================

-- Add balance_after column if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'credit_transactions'
        AND column_name = 'balance_after'
    ) THEN
        ALTER TABLE credit_transactions
        ADD COLUMN balance_after DECIMAL(10, 2) NULL;

        RAISE NOTICE 'Column balance_after added to credit_transactions';
    ELSE
        RAISE NOTICE 'Column balance_after already exists in credit_transactions';
    END IF;
END $$;

-- Optional: Populate balance_after for existing transactions
-- This calculates the balance retroactively based on transaction history
-- WARNING: This is a complex operation and may take time on large datasets

-- Uncomment if you want to populate historical data:
/*
DO $$
DECLARE
    credit_rec RECORD;
    trans_rec RECORD;
    running_balance DECIMAL(10, 2);
BEGIN
    -- For each credit
    FOR credit_rec IN SELECT id, total_amount FROM credits ORDER BY created_at
    LOOP
        running_balance := 0;

        -- For each transaction in this credit (ordered by creation time)
        FOR trans_rec IN
            SELECT id, type, amount
            FROM credit_transactions
            WHERE credit_id = credit_rec.id
            ORDER BY created_at ASC
        LOOP
            -- Calculate balance based on transaction type
            CASE trans_rec.type
                WHEN 'charge' THEN running_balance := running_balance + trans_rec.amount;
                WHEN 'debt_increase' THEN running_balance := running_balance + trans_rec.amount;
                WHEN 'payment' THEN running_balance := running_balance - trans_rec.amount;
            END CASE;

            -- Update the transaction with the calculated balance
            UPDATE credit_transactions
            SET balance_after = running_balance
            WHERE id = trans_rec.id;
        END LOOP;
    END LOOP;

    RAISE NOTICE 'Historical balances populated successfully';
END $$;
*/

-- Verify the column was added
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'credit_transactions'
AND column_name = 'balance_after';
