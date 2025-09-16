-- Rollback Migration: Restore rewards-related columns to user_preferences table
-- Date: 2025-09-16
-- Purpose: Rollback script in case the column removal needs to be reverted
-- 
-- WARNING: This will restore the columns but NOT restore the data that was in them
-- The data was already migrated to leaderboard_snapshots table

-- Add back the columns (without data)
ALTER TABLE user_preferences 
ADD COLUMN IF NOT EXISTS rewards_decision TEXT DEFAULT NULL;

ALTER TABLE user_preferences 
ADD COLUMN IF NOT EXISTS rewards_calculated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NULL;

ALTER TABLE user_preferences 
ADD COLUMN IF NOT EXISTS rewards_optout BOOLEAN DEFAULT NULL;

ALTER TABLE user_preferences 
ADD COLUMN IF NOT EXISTS decision_made_at TIMESTAMP WITH TIME ZONE DEFAULT NULL;

ALTER TABLE user_preferences 
ADD COLUMN IF NOT EXISTS future_pool_contribution NUMERIC DEFAULT NULL;

ALTER TABLE user_preferences 
ADD COLUMN IF NOT EXISTS rewards_amount NUMERIC DEFAULT NULL;

-- Add back the index
CREATE INDEX IF NOT EXISTS idx_user_preferences_rewards_optout_amount 
ON user_preferences(rewards_optout, rewards_amount);

-- Add back the comments
COMMENT ON COLUMN user_preferences.rewards_decision IS 'User decision for rewards opt-in/opt-out: opted_in, opted_out, or null for undecided';
COMMENT ON COLUMN user_preferences.rewards_calculated_at IS 'Timestamp when rewards amount was last calculated for this user';
COMMENT ON COLUMN user_preferences.rewards_optout IS 'Boolean flag indicating if user opted out of rewards (true) or opted in (false)';
COMMENT ON COLUMN user_preferences.decision_made_at IS 'Timestamp when user made their rewards decision';
COMMENT ON COLUMN user_preferences.future_pool_contribution IS 'Amount user contributed to future rewards pool';
COMMENT ON COLUMN user_preferences.rewards_amount IS 'Calculated rewards amount for this user in USD';

-- Verify rollback was successful
SELECT 
  'Rollback completed successfully' as status,
  COUNT(*) as restored_columns
FROM information_schema.columns 
WHERE table_name = 'user_preferences' 
  AND column_name IN (
    'rewards_decision',
    'rewards_calculated_at', 
    'rewards_optout',
    'decision_made_at',
    'future_pool_contribution',
    'rewards_amount'
  );
