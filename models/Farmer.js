const mongoose = require('mongoose');

const farmerSchema = new mongoose.Schema({
    name: { type: String, required: true },
    phone: { type: String, required: true, unique: true },
    address: { type: String },
    password: { type: String, required: true }, // For login
    balance: { type: Number, default: 0 },
    totalMilk: { type: Number, default: 0 },
    advance: { type: Number, default: 0 },
    lastPaymentDate: { type: Date },
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Farmer', farmerSchema);
