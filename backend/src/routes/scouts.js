const express = require('express');
const router = express.Router();
const supabase = require('../services/supabase');
const auth = require('../middleware/auth');

// Register scout (called after first OTP login)
router.post('/register', auth, async (req, res) => {
  const { name, phone, territory } = req.body;

  try {
    // Check if already exists
    const { data: existing } = await supabase
      .from('scouts')
      .select('id')
      .eq('id', req.user.id)
      .maybeSingle();

    if (existing) return res.json({ already_registered: true, scout: existing });

    const { data, error } = await supabase
      .from('scouts')
      .insert({ id: req.user.id, name, phone, territory })
      .select()
      .single();

    if (error) throw error;
    res.json({ success: true, scout: data });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get scout profile
router.get('/me', auth, async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('scouts')
      .select('*')
      .eq('id', req.user.id)
      .single();

    if (error) throw error;
    res.json(data);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Update scout profile
router.patch('/me', auth, async (req, res) => {
  const { name, territory } = req.body;

  try {
    const { data, error } = await supabase
      .from('scouts')
      .update({ name, territory })
      .eq('id', req.user.id)
      .select()
      .single();

    if (error) throw error;
    res.json(data);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = router;
