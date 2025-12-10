const mongoose = require('mongoose');

const adminSchema = new mongoose.Schema({
    username: { type: String, required: true }, // Can be name
    phone: { type: String, required: true, unique: true }, // Mobile number for login
    password: { type: String, required: true },
    dairyName: { type: String, required: true },
    role: { type: String, default: 'admin' },
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Admin', adminSchema);
