require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const creditRoutes = require('./routes/credits');
const unlockRoutes = require('./routes/unlocks');
const paymentRoutes = require('./routes/payments');

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(rateLimit({ windowMs: 15 * 60 * 1000, max: 100 }));

// Routes
app.use('/api/credits', creditRoutes);
app.use('/api/unlocks', unlockRoutes);
app.use('/api/payments', paymentRoutes);

app.get('/health', (_, res) => res.json({ status: 'ok' }));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
