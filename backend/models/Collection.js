const mongoose = require('mongoose');

const collectionSchema = new mongoose.Schema({
    farmerId: { type: mongoose.Schema.Types.ObjectId, ref: 'Farmer', required: true },
    date: { type: Date, default: Date.now },
    shift: { type: String, enum: ['Morning', 'Evening'], default: 'Morning' },
    qty: { type: Number, required: true },
    fat: { type: Number, required: true },
    snf: { type: Number, required: true },
    rate: { type: Number, required: true },
    amount: { type: Number, required: true },
    synced: { type: Boolean, default: true } // Helpful for debugging sync
});

module.exports = mongoose.model('Collection', collectionSchema);
