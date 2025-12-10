const Bill = require('../models/Bill');
const Collection = require('../models/Collection');
const Farmer = require('../models/Farmer');

// Generate Bill for a specific cycle
exports.generateBill = async (req, res) => {
    try {
        const { farmerId, startDate, endDate, cycleNumber } = req.body;

        // Fetch collections in range
        const collections = await Collection.find({
            farmerId,
            date: { $gte: new Date(startDate), $lte: new Date(endDate) }
        });

        if (collections.length === 0) {
            return res.status(400).json({ message: 'No collections found for this period' });
        }

        let totalMilk = 0;
        let totalAmount = 0;

        collections.forEach(col => {
            totalMilk += col.qty;
            totalAmount += col.amount;
        });

        const avgRate = totalMilk > 0 ? (totalAmount / totalMilk) : 0;

        // Simple Logic: Deductions could be advanced, but for now 0 or passed in body
        const deductions = req.body.deductions || 0;
        const netPayable = totalAmount - deductions;

        const bill = new Bill({
            farmerId,
            startDate,
            endDate,
            cycleNumber,
            totalMilk,
            avgRate,
            totalAmount,
            deductions,
            netPayable
        });

        await bill.save();
        res.status(201).json(bill);

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Get Bills
exports.getBills = async (req, res) => {
    try {
        const bills = await Bill.find({ farmerId: req.params.farmerId }).sort({ generatedAt: -1 });
        res.json(bills);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
