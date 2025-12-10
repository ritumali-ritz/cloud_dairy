const mongoose = require('mongoose');

const billSchema = new mongoose.Schema({
    farmerId: { type: mongoose.Schema.Types.ObjectId, ref: 'Farmer', required: true },
    startDate: { type: Date, required: true },
    endDate: { type: Date, required: true },
    cycleNumber: { type: Number }, // 1, 2, 3 for month cycles (1-10, 11-20, 21-end)
    totalMilk: { type: Number, required: true },
    avgRate: { type: Number, required: true },
    totalAmount: { type: Number, required: true },
    deductions: { type: Number, default: 0 },
    netPayable: { type: Number, required: true },
    generatedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Bill', billSchema);
