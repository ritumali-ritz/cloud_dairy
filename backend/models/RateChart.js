const mongoose = require('mongoose');

const rateChartSchema = new mongoose.Schema({
    type: { type: String, required: true, enum: ['Cow', 'Buffalo'] }, // Animal Type
    fat: { type: Number, required: true },
    snf: { type: Number, required: true },
    rate: { type: Number, required: true },
    updatedAt: { type: Date, default: Date.now }
});

// Compound index to ensure unique rate for a specific type+fat+snf combination
rateChartSchema.index({ type: 1, fat: 1, snf: 1 }, { unique: true });

module.exports = mongoose.model('RateChart', rateChartSchema);
