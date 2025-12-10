const Farmer = require('../models/Farmer');
const bcrypt = require('bcryptjs');

// Create Farmer (Admin only)
exports.createFarmer = async (req, res) => {
    try {
        const { name, phone, address, password } = req.body;

        // Check if phone exists
        const existing = await Farmer.findOne({ phone });
        if (existing) return res.status(400).json({ message: 'Phone number already registered' });

        const hashedPassword = await bcrypt.hash(password, 10);

        const farmer = new Farmer({
            name,
            phone,
            address,
            password: hashedPassword
        });

        await farmer.save();
        res.status(201).json(farmer);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Get All Farmers
exports.getAllFarmers = async (req, res) => {
    try {
        const farmers = await Farmer.find().select('-password');
        res.json(farmers);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Get Farmer Details
exports.getFarmerById = async (req, res) => {
    try {
        const farmer = await Farmer.findById(req.params.id).select('-password');
        if (!farmer) return res.status(404).json({ message: 'Farmer not found' });
        res.json(farmer);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
