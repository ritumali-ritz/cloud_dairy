const Farmer = require('../models/Farmer');
const Transaction = require('../models/Transaction');

// Get Wallet Balance
exports.getWallet = async (req, res) => {
    try {
        const farmer = await Farmer.findById(req.params.farmerId);
        if (!farmer) return res.status(404).json({ message: 'Farmer not found' });

        res.json({
            balance: farmer.balance,
            advance: farmer.advance,
            lastPaymentDate: farmer.lastPaymentDate
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Make Payment (Admin to Farmer)
exports.makePayment = async (req, res) => {
    try {
        const { farmerId, amount, mode, description } = req.body;

        const farmer = await Farmer.findById(farmerId);
        if (!farmer) return res.status(404).json({ message: 'Farmer not found' });

        if (farmer.balance < amount) {
            return res.status(400).json({ message: 'Insufficient balance' });
        }

        farmer.balance -= amount;
        farmer.lastPaymentDate = new Date();
        await farmer.save();

        const transaction = new Transaction({
            farmerId,
            type: 'payment',
            amount,
            mode,
            description
        });
        await transaction.save();

        // Emit Realtime Event
        const io = req.app.get('io');
        io.emit('new_payment', { transaction, farmerName: farmer.name });

        res.json(transaction);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Give Advance
exports.giveAdvance = async (req, res) => {
    try {
        const { farmerId, amount, mode } = req.body;

        const farmer = await Farmer.findById(farmerId);
        if (!farmer) return res.status(404).json({ message: 'Farmer not found' });

        farmer.advance += amount;
        // Advance usually doesn't deduct from balance immediately, it's a separate debt
        // But we might want to record the money flow
        await farmer.save();

        const transaction = new Transaction({
            farmerId,
            type: 'advance',
            amount,
            mode, // e.g., 'cash' given as advance
            description: 'Advance Payment'
        });
        await transaction.save();

        res.json(transaction);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Get Transactions
exports.getTransactions = async (req, res) => {
    try {
        const transactions = await Transaction.find({ farmerId: req.params.farmerId }).sort({ date: -1 });
        res.json(transactions);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
