const Collection = require('../models/Collection');

// Get total milk collected across all collections
exports.getTotalMilk = async (req, res) => {
    try {
        const result = await Collection.aggregate([
            { $group: { _id: null, totalMilk: { $sum: '$qty' } } }
        ]);
        const totalMilk = result.length ? result[0].totalMilk : 0;
        res.json({ totalMilk });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
