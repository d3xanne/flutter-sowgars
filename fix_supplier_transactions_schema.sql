-- Fix for supplier_transactions table - Add missing archived columns
-- Run this in your Supabase SQL editor

-- Add missing columns to supplier_transactions table
ALTER TABLE supplier_transactions 
ADD COLUMN IF NOT EXISTS archived BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS archived_at TIMESTAMP WITH TIME ZONE;

-- Create index for archived column for better performance
CREATE INDEX IF NOT EXISTS idx_supplier_transactions_archived 
ON supplier_transactions(archived);

-- Update existing records to have archived = false
UPDATE supplier_transactions 
SET archived = FALSE 
WHERE archived IS NULL;

-- Add comment to document the columns
COMMENT ON COLUMN supplier_transactions.archived IS 'Indicates if the transaction is archived (soft delete)';
COMMENT ON COLUMN supplier_transactions.archived_at IS 'Timestamp when the transaction was archived';

-- Verify the table structure
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'supplier_transactions' 
ORDER BY ordinal_position;
