const RateChart = require('../models/RateChart');

// Set or Update a Rate
exports.updateRate = async (req, res) => {
    try {
        const { type, fat, snf, rate } = req.body;

        // Upsert: Update if exists, Insert if new
        const rateEntry = await RateChart.findOneAndUpdate(
            { type, fat, snf },
            { rate, updatedAt: Date.now() },
            { new: true, upsert: true }
        );

        res.json({ message: 'Rate updated successfully', data: rateEntry });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Get Rate for specific params (Used during collection)
exports.getRate = async (req, res) => {
    try {
        const { type, fat, snf } = req.query;
        // Parse numbers to match schema types exactly if needed, though Mongoose handles casting mostly
        const rateEntry = await RateChart.findOne({ type, fat, snf });

        if (!rateEntry) {
            return res.status(404).json({ message: 'Rate not found for these parameters', rate: 0 });
        }
        res.json({ rate: rateEntry.rate });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Get All Rates (For Admin View)
exports.getAllRates = async (req, res) => {
    try {
        const { type } = req.query;
        const filter = type ? { type } : {};
        const rates = await RateChart.find(filter).sort({ fat: 1, snf: 1 });
        res.json(rates);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
