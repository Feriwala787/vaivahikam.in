const express = require('express');
const router = express.Router();
const Razorpay = require('razorpay');
const crypto = require('crypto');
const supabase = require('../services/supabase');
const auth = require('../middleware/auth');

const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});

const CREDIT_PACKS = {
  pack_10: { credits: 10, amount: 99900 },   // ₹999 in paise
  pack_25: { credits: 25, amount: 224900 },  // ₹2,249
  pack_50: { credits: 50, amount: 399900 },  // ₹3,999
};

// Create order
router.post('/create-order', auth, async (req, res) => {
  const { pack_id } = req.body;
  const pack = CREDIT_PACKS[pack_id];

  if (!pack) return res.status(400).json({ error: 'Invalid pack' });

  try {
    const order = await razorpay.orders.create({
      amount: pack.amount,
      currency: 'INR',
      receipt: `${req.user.id}_${pack_id}_${Date.now()}`,
      notes: { scout_id: req.user.id, pack_id, credits: pack.credits },
    });

    res.json({ order_id: order.id, amount: order.amount, currency: order.currency });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Verify payment & credit wallet
router.post('/verify', auth, async (req, res) => {
  const { razorpay_order_id, razorpay_payment_id, razorpay_signature, pack_id } = req.body;

  // Verify signature
  const body = razorpay_order_id + '|' + razorpay_payment_id;
  const expectedSignature = crypto
    .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
    .update(body)
    .digest('hex');

  if (expectedSignature !== razorpay_signature) {
    return res.status(400).json({ error: 'Payment verification failed' });
  }

  const pack = CREDIT_PACKS[pack_id];
  if (!pack) return res.status(400).json({ error: 'Invalid pack' });

  try {
    // Add credits
    await supabase.rpc('increment_wallet', { scout_id: req.user.id, amount: pack.credits });

    // Log transaction
    await supabase.from('transactions').insert({
      scout_id: req.user.id,
      type: 'purchased',
      amount: pack.credits,
      description: `Purchased ${pack.credits} credits (${pack_id})`,
    });

    res.json({ success: true, credits_added: pack.credits });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = router;
