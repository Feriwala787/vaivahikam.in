const express = require('express');
const router = express.Router();
const supabase = require('../services/supabase');
const auth = require('../middleware/auth');

// Upload profile + earn 3 credits
router.post('/upload', auth, async (req, res) => {
  const EARN_AMOUNT = 3;
  const scout_id = req.user.id;

  try {
    // Insert profile
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .insert({ ...req.body, scout_id })
      .select()
      .single();

    if (profileError) throw profileError;

    // Earn credits
    await supabase.rpc('increment_wallet', { scout_id, amount: EARN_AMOUNT });
    await supabase.rpc('increment_uploads', { scout_id });

    // Log transaction
    await supabase.from('transactions').insert({
      scout_id,
      type: 'earned',
      amount: EARN_AMOUNT,
      description: `Uploaded profile: ${profile.id}`,
    });

    res.json({ success: true, profile_id: profile.id, credits_earned: EARN_AMOUNT });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get scout's uploaded profiles
router.get('/my-uploads', auth, async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('scout_id', req.user.id)
      .order('created_at', { ascending: false });

    if (error) throw error;
    res.json(data);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Report a profile as fake
router.post('/report/:id', auth, async (req, res) => {
  const profile_id = req.params.id;
  const reporter_id = req.user.id;
  const PENALTY = 5;
  const REFUND = 1;

  try {
    // Get profile owner
    const { data: profile } = await supabase
      .from('profiles')
      .select('scout_id')
      .eq('id', profile_id)
      .single();

    if (!profile) return res.status(404).json({ error: 'Profile not found' });
    if (profile.scout_id === reporter_id) return res.status(400).json({ error: 'Cannot report own profile' });

    // Refund reporter
    await supabase.rpc('increment_wallet', { scout_id: reporter_id, amount: REFUND });
    await supabase.from('transactions').insert({
      scout_id: reporter_id, type: 'earned', amount: REFUND, description: 'Report refund',
    });

    // Penalize uploader
    await supabase.rpc('increment_wallet', { scout_id: profile.scout_id, amount: -PENALTY });
    await supabase.from('transactions').insert({
      scout_id: profile.scout_id, type: 'penalty', amount: -PENALTY, description: `Fake report on profile ${profile_id}`,
    });

    // Mark profile as reported
    await supabase.from('profiles').update({ status: 'Reported' }).eq('id', profile_id);

    res.json({ success: true, message: 'Profile reported. Credit refunded.' });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = router;
