-- Create storage bucket for profile photos
INSERT INTO storage.buckets (id, name, public) VALUES ('profile-photos', 'profile-photos', true)
ON CONFLICT (id) DO NOTHING;

-- Allow authenticated users to upload photos
CREATE POLICY "Authenticated upload" ON storage.objects FOR INSERT
TO authenticated WITH CHECK (bucket_id = 'profile-photos');

-- Allow public read access to photos
CREATE POLICY "Public read photos" ON storage.objects FOR SELECT
TO public USING (bucket_id = 'profile-photos');

-- Allow users to delete their own uploads
CREATE POLICY "Delete own photos" ON storage.objects FOR DELETE
TO authenticated USING (bucket_id = 'profile-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
