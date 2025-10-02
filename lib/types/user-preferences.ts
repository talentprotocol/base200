export interface UserPreferences {
  talent_uuid: string;
  email?: string;
  notification_preferences?: Record<string, unknown>;
  callout_prefs?: {
    dismissedIds?: string[];
    permanentlyHiddenIds?: string[];
  };
  rewards_calculated_at?: string;
  created_at?: string;
  updated_at?: string;
}

export interface UserPreferencesResponse {
  callout_prefs: {
    dismissedIds: string[];
    permanentlyHiddenIds: string[];
  };
  updated_at: string;
}

export interface UserPreferencesUpdateRequest {
  talent_uuid: string;
  // Atomic ops for callout preferences (all optional)
  add_dismissed_id?: string;
  add_permanently_hidden_id?: string;
  remove_dismissed_id?: string;
  remove_permanently_hidden_id?: string;
}

export interface UserPreferencesError {
  error: string;
  details?: string;
}

export interface UserPreferencesSuccess {
  success: true;
  data?: Record<string, unknown>;
}
