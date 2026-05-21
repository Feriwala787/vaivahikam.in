-- Shortlist folders (CRM for scouts)
CREATE TABLE IF NOT EXISTS shortlist_folders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scout_id UUID REFERENCES scouts(id) NOT NULL,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Shortlist items (profiles in folders)
CREATE TABLE IF NOT EXISTS shortlist_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  folder_id UUID REFERENCES shortlist_folders(id) ON DELETE CASCADE NOT NULL,
  profile_id UUID REFERENCES profiles(id) NOT NULL,
  notes TEXT,
  added_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(folder_id, profile_id)
);

-- RLS
ALTER TABLE shortlist_folders ENABLE ROW LEVEL SECURITY;
ALTER TABLE shortlist_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Own folders" ON shortlist_folders FOR ALL USING (auth.uid() = scout_id);
CREATE POLICY "Own items" ON shortlist_items FOR ALL USING (
  folder_id IN (SELECT id FROM shortlist_folders WHERE scout_id = auth.uid())
);
