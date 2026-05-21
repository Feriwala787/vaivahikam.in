-- ============================================
-- VAIVAHIKAM DATABASE SCHEMA
-- Run this in Supabase SQL Editor
-- ============================================

-- Scouts (Users/Matchmakers)
CREATE TABLE scouts (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  name TEXT NOT NULL,
  phone TEXT UNIQUE NOT NULL,
  territory TEXT,
  wallet_balance INTEGER DEFAULT 0,
  total_uploads INTEGER DEFAULT 0,
  trust_score INTEGER DEFAULT 100,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Profiles (Bachelors uploaded by scouts)
CREATE TABLE profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scout_id UUID REFERENCES scouts(id) NOT NULL,
  name TEXT NOT NULL,
  gender TEXT NOT NULL,
  age INTEGER NOT NULL,
  height INTEGER NOT NULL,
  religion TEXT NOT NULL,
  caste TEXT NOT NULL,
  sub_caste TEXT,
  gotra TEXT,
  manglik TEXT NOT NULL,
  education TEXT NOT NULL,
  profession TEXT NOT NULL,
  income TEXT NOT NULL,
  diet TEXT NOT NULL,
  marital_status TEXT NOT NULL DEFAULT 'Never Married',
  family_type TEXT NOT NULL DEFAULT 'Nuclear',
  father_occupation TEXT,
  siblings INTEGER,
  city TEXT NOT NULL,
  state TEXT NOT NULL,
  complexion TEXT,
  body_type TEXT,
  photos_url TEXT[] DEFAULT '{}',
  status TEXT DEFAULT 'Active' CHECK (status IN ('Active', 'Married', 'Reported')),
  bio TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Transactions (Credit ledger)
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scout_id UUID REFERENCES scouts(id) NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('earned', 'spent', 'purchased', 'penalty')),
  amount INTEGER NOT NULL,
  description TEXT,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- Unlocks (Which scout unlocked which profile)
CREATE TABLE unlocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scout_id UUID REFERENCES scouts(id) NOT NULL,
  profile_id UUID REFERENCES profiles(id) NOT NULL,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(scout_id, profile_id)
);

-- Vendor Leads
CREATE TABLE vendor_leads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scout_id UUID REFERENCES scouts(id) NOT NULL,
  parent_phone TEXT NOT NULL,
  budget TEXT,
  wedding_date DATE,
  status TEXT DEFAULT 'Pending' CHECK (status IN ('Pending', 'Contacted', 'Booked', 'Paid')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- INDEXES (Critical for match filtering speed)
-- ============================================
CREATE INDEX idx_profiles_gender ON profiles(gender);
CREATE INDEX idx_profiles_religion ON profiles(religion);
CREATE INDEX idx_profiles_caste ON profiles(caste);
CREATE INDEX idx_profiles_age ON profiles(age);
CREATE INDEX idx_profiles_city ON profiles(city);
CREATE INDEX idx_profiles_state ON profiles(state);
CREATE INDEX idx_profiles_income ON profiles(income);
CREATE INDEX idx_profiles_status ON profiles(status);
CREATE INDEX idx_profiles_manglik ON profiles(manglik);

-- Composite index for the most common filter combo
CREATE INDEX idx_profiles_search ON profiles(gender, religion, caste, age, city, status);

-- ============================================
-- RPC FUNCTIONS (Called by backend)
-- ============================================

-- Increment/decrement wallet balance
CREATE OR REPLACE FUNCTION increment_wallet(scout_id UUID, amount INTEGER)
RETURNS VOID AS $$
BEGIN
  UPDATE scouts SET wallet_balance = wallet_balance + amount WHERE id = scout_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Increment upload count
CREATE OR REPLACE FUNCTION increment_uploads(scout_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE scouts SET total_uploads = total_uploads + 1 WHERE id = scout_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================
ALTER TABLE scouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE unlocks ENABLE ROW LEVEL SECURITY;

-- Scouts can read their own data
CREATE POLICY "Scouts read own" ON scouts FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Scouts update own" ON scouts FOR UPDATE USING (auth.uid() = id);

-- All authenticated scouts can search active profiles
CREATE POLICY "Read active profiles" ON profiles FOR SELECT USING (status = 'Active');
-- Scouts can insert their own profiles
CREATE POLICY "Insert own profiles" ON profiles FOR INSERT WITH CHECK (auth.uid() = scout_id);
-- Scouts can update their own profiles
CREATE POLICY "Update own profiles" ON profiles FOR UPDATE USING (auth.uid() = scout_id);

-- Transactions: scouts see their own
CREATE POLICY "Own transactions" ON transactions FOR SELECT USING (auth.uid() = scout_id);

-- Unlocks: scouts see their own
CREATE POLICY "Own unlocks" ON unlocks FOR SELECT USING (auth.uid() = scout_id);
