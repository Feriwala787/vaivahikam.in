const express = require('express');
const router = express.Router();
const supabase = require('../services/supabase');
const auth = require('../middleware/auth');

// Get scout's credit balance
router.get('/balance', auth, async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('scouts')
      .select('wallet_balance')
      .eq('id', req.user.id)
      .single();

    if (error) throw error;
    res.json({ balance: data.wallet_balance });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Earn credits (called after profile upload)
router.post('/earn', auth, async (req, res) => {
  const EARN_AMOUNT = 3;
  try {
    // Increment wallet
    const { error: updateError } = await supabase.rpc('increment_wallet', {
      scout_id: req.user.id,
      amount: EARN_AMOUNT,
    });
    if (updateError) throw updateError;

    // Log transaction
    await supabase.from('transactions').insert({
      scout_id: req.user.id,
      type: 'earned',
      amount: EARN_AMOUNT,
      description: 'Profile upload reward',
    });

    // Increment upload count
    await supabase.rpc('increment_uploads', { scout_id: req.user.id });

    res.json({ success: true, credited: EARN_AMOUNT });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Spend credit (called on profile unlock)
router.post('/spend', auth, async (req, res) => {
  const SPEND_AMOUNT = 1;
  try {
    // Check balance
    const { data: scout } = await supabase
      .from('scouts')
      .select('wallet_balance')
      .eq('id', req.user.id)
      .single();

    if (scout.wallet_balance < SPEND_AMOUNT) {
      return res.status(400).json({ error: 'Insufficient credits' });
    }

    // Deduct
    const { error } = await supabase.rpc('increment_wallet', {
      scout_id: req.user.id,
      amount: -SPEND_AMOUNT,
    });
    if (error) throw error;

    // Log
    await supabase.from('transactions').insert({
      scout_id: req.user.id,
      type: 'spent',
      amount: -SPEND_AMOUNT,
      description: `Unlocked profile: ${req.body.profile_id}`,
    });

    res.json({ success: true, spent: SPEND_AMOUNT });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Report fake profile (refund reporter, penalize uploader)
router.post('/report', auth, async (req, res) => {
  const PENALTY = 5;
  const REFUND = 1;
  const { profile_id } = req.body;

  try {
    // Get profile's scout
    const { data: profile } = await supabase
      .from('profiles')
      .select('scout_id')
      .eq('id', profile_id)
      .single();

    if (!profile) return res.status(404).json({ error: 'Profile not found' });

    // Refund reporter
    await supabase.rpc('increment_wallet', { scout_id: req.user.id, amount: REFUND });
    await supabase.from('transactions').insert({
      scout_id: req.user.id, type: 'earned', amount: REFUND, description: 'Report refund',
    });

    // Penalize uploader
    await supabase.rpc('increment_wallet', { scout_id: profile.scout_id, amount: -PENALTY });
    await supabase.from('transactions').insert({
      scout_id: profile.scout_id, type: 'penalty', amount: -PENALTY, description: 'Fake profile penalty',
    });

    // Mark profile
    await supabase.from('profiles').update({ status: 'Reported' }).eq('id', profile_id);

    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Transaction history
router.get('/history', auth, async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('transactions')
      .select('*')
      .eq('scout_id', req.user.id)
      .order('timestamp', { ascending: false })
      .limit(50);

    if (error) throw error;
    res.json(data);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = router;
