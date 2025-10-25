-- =====================================================
-- Migration: Add 'charge' value to credit_transactions_type_enum
-- Purpose: Allow creation of initial credit transactions with 'charge' type
-- Date: 2025-10-25
-- =====================================================

-- Add 'charge' value to the enum if it doesn't exist
DO $$
BEGIN
    -- Check if 'charge' value exists in the enum
    IF NOT EXISTS (
        SELECT 1
        FROM pg_enum
        WHERE enumlabel = 'charge'
        AND enumtypid = 'credit_transactions_type_enum'::regtype
    ) THEN
        -- Add 'charge' as the first value in the enum (before 'debt_increase')
        ALTER TYPE credit_transactions_type_enum ADD VALUE 'charge' BEFORE 'debt_increase';
        RAISE NOTICE 'Value ''charge'' added to credit_transactions_type_enum';
    ELSE
        RAISE NOTICE 'Value ''charge'' already exists in credit_transactions_type_enum';
    END IF;
END $$;

-- Verify the enum values
SELECT enumlabel, enumsortorder
FROM pg_enum
WHERE enumtypid = 'credit_transactions_type_enum'::regtype
ORDER BY enumsortorder;
