const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema({
    farmerId: { type: mongoose.Schema.Types.ObjectId, ref: 'Farmer', required: true },
    type: { type: String, enum: ['payment', 'advance', 'collection'], required: true },
    amount: { type: Number, required: true },
    mode: { type: String, enum: ['cash', 'bank', 'upi', 'system'], default: 'cash' }, // 'system' for auto-deductions etc
    date: { type: Date, default: Date.now },
    description: { type: String }
});

module.exports = mongoose.model('Transaction', transactionSchema);
