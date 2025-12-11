const Collection = require('../models/Collection');
const Farmer = require('../models/Farmer');
const Transaction = require('../models/Transaction');

// Add Collection
exports.addCollection = async (req, res) => {
    try {
        const { farmerId, date, shift, qty, fat, snf, rate, amount } = req.body;

        // Create Collection
        const collection = new Collection({
            farmerId, date, shift, qty, fat, snf, rate, amount
        });
        await collection.save();

        // Update Farmer Balance
        const farmer = await Farmer.findById(farmerId);
        farmer.balance += amount;
        await farmer.save();

        // Create Transaction Record (Credit)
        const transaction = new Transaction({
            farmerId,
            type: 'collection',
            amount,
            mode: 'system',
            date,
            description: `Milk Collection: ${qty}L @ ${rate}/L`
        });
        await transaction.save();

        // Emit Realtime Event
        const io = req.app.get('io');
        io.emit('new_collection', { collection, farmerName: farmer.name });

        res.status(201).json(collection);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Get Collections by Farmer
exports.getCollectionsByFarmer = async (req, res) => {
    try {
        const collections = await Collection.find({ farmerId: req.params.id }).sort({ date: -1 });
        res.json(collections);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Get Last 10 Days Collections
exports.getLast10Collections = async (req, res) => {
    try {
        const collections = await Collection.find({ farmerId: req.params.id })
            .sort({ date: -1 })
            .limit(20); // 2 shifts/day * 10 days = 20 (roughly)
        res.json(collections);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
