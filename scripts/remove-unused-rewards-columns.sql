-- Migration: Remove unused rewards-related columns from user_preferences table
-- Date: 2025-09-16
-- Purpose: Clean up user_preferences table after opt-in/opt-out deadline has passed
-- 
-- These columns are no longer used since the system now uses leaderboard_snapshots
-- as the source of truth for rewards decisions and amounts.

-- Verify current state before deletion
SELECT 
  column_name, 
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'user_preferences' 
  AND column_name IN (
    'rewards_decision',
    'rewards_calculated_at', 
    'rewards_optout',
    'decision_made_at',
    'future_pool_contribution',
    'rewards_amount'
  )
ORDER BY ordinal_position;

-- Count records with non-null values in these columns (for verification)
SELECT 
  COUNT(*) as total_records,
  COUNT(rewards_decision) as rewards_decision_count,
  COUNT(rewards_calculated_at) as rewards_calculated_at_count,
  COUNT(rewards_optout) as rewards_optout_count,
  COUNT(decision_made_at) as decision_made_at_count,
  COUNT(future_pool_contribution) as future_pool_contribution_count,
  COUNT(rewards_amount) as rewards_amount_count
FROM user_preferences;

-- Drop the unused columns
-- Note: rewards_amount is kept in leaderboard_snapshots where it belongs

-- Drop rewards_decision column
ALTER TABLE user_preferences 
DROP COLUMN IF EXISTS rewards_decision;

-- Drop rewards_calculated_at column  
ALTER TABLE user_preferences 
DROP COLUMN IF EXISTS rewards_calculated_at;

-- Drop rewards_optout column
ALTER TABLE user_preferences 
DROP COLUMN IF EXISTS rewards_optout;

-- Drop decision_made_at column
ALTER TABLE user_preferences 
DROP COLUMN IF EXISTS decision_made_at;

-- Drop future_pool_contribution column
ALTER TABLE user_preferences 
DROP COLUMN IF EXISTS future_pool_contribution;

-- Drop rewards_amount column (moved to leaderboard_snapshots)
ALTER TABLE user_preferences 
DROP COLUMN IF EXISTS rewards_amount;

-- Verify columns were removed
SELECT 
  column_name, 
  data_type
FROM information_schema.columns 
WHERE table_name = 'user_preferences' 
ORDER BY ordinal_position;

-- Add comment to document the cleanup
COMMENT ON TABLE user_preferences IS 'User preferences table - rewards-related columns removed after opt-in/opt-out deadline. Rewards data now sourced from leaderboard_snapshots table.';

-- Verify the cleanup was successful
SELECT 
  'Migration completed successfully' as status,
  COUNT(*) as remaining_columns
FROM information_schema.columns 
WHERE table_name = 'user_preferences';
