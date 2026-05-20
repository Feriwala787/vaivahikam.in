const express = require('express');
const router = express.Router();
const supabase = require('../services/supabase');
const auth = require('../middleware/auth');

// Unlock a profile
router.post('/', auth, async (req, res) => {
  const { profile_id } = req.body;
  const scout_id = req.user.id;

  try {
    // Check if already unlocked
    const { data: existing } = await supabase
      .from('unlocks')
      .select('id')
      .eq('scout_id', scout_id)
      .eq('profile_id', profile_id)
      .maybeSingle();

    if (existing) return res.json({ already_unlocked: true });

    // Check balance
    const { data: scout } = await supabase
      .from('scouts')
      .select('wallet_balance')
      .eq('id', scout_id)
      .single();

    if (scout.wallet_balance < 1) {
      return res.status(400).json({ error: 'Insufficient credits. Buy more credits to unlock.' });
    }

    // Deduct credit
    await supabase.rpc('increment_wallet', { scout_id, amount: -1 });

    // Record unlock
    await supabase.from('unlocks').insert({ scout_id, profile_id });

    // Log transaction
    await supabase.from('transactions').insert({
      scout_id,
      type: 'spent',
      amount: -1,
      description: `Unlocked profile ${profile_id}`,
    });

    res.json({ success: true, remaining_credits: scout.wallet_balance - 1 });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get all unlocked profiles for a scout
router.get('/my', auth, async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('unlocks')
      .select('profile_id, timestamp, profiles(*)')
      .eq('scout_id', req.user.id)
      .order('timestamp', { ascending: false });

    if (error) throw error;
    res.json(data);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = router;
