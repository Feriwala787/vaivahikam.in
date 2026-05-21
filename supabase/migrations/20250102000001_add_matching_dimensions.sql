-- Add multi-dimensional matching fields to profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS family_wealth TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS property_owned TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS family_income TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS social_status TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS family_values TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS living_preference TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS social_circle TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS personality TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS temperament TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS life_goals TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS communication_style TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS political_view TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS religious_level TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS exercise_habit TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS smoking_habit TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS drinking_habit TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS disability TEXT DEFAULT 'None';

-- Partner preferences
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS pref_age_min INTEGER;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS pref_age_max INTEGER;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS pref_height_min INTEGER;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS pref_height_max INTEGER;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS pref_religion TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS pref_caste TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS pref_education TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS pref_income TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS pref_city TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS pref_state TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS pref_manglik TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS pref_diet TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS pref_family_type TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS pref_complexion TEXT;

-- Additional indexes for new filter dimensions
CREATE INDEX IF NOT EXISTS idx_profiles_personality ON profiles(personality);
CREATE INDEX IF NOT EXISTS idx_profiles_family_values ON profiles(family_values);
CREATE INDEX IF NOT EXISTS idx_profiles_social_circle ON profiles(social_circle);
CREATE INDEX IF NOT EXISTS idx_profiles_living_pref ON profiles(living_preference);
CREATE INDEX IF NOT EXISTS idx_profiles_political ON profiles(political_view);
CREATE INDEX IF NOT EXISTS idx_profiles_religious_level ON profiles(religious_level);
CREATE INDEX IF NOT EXISTS idx_profiles_family_wealth ON profiles(family_wealth);
