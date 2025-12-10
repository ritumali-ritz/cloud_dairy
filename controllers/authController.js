const Admin = require('../models/Admin');
const Farmer = require('../models/Farmer');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'secret';

// Check if Admin Exists (For App Startup)
exports.checkAdminExists = async (req, res) => {
    try {
        const adminCount = await Admin.countDocuments();
        res.json({ exists: adminCount > 0 });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Admin Login
exports.adminLogin = async (req, res) => {
    try {
        const { username, password } = req.body;
        // Search by phone or username
        const admin = await Admin.findOne({
            $or: [{ phone: username }, { username: username }]
        });

        if (!admin) return res.status(404).json({ message: 'Admin not found' });

        const isMatch = await bcrypt.compare(password, admin.password);
        if (!isMatch) return res.status(400).json({ message: 'Invalid credentials' });

        const token = jwt.sign({ id: admin._id, role: 'admin' }, JWT_SECRET, { expiresIn: '1d' });
        res.json({
            token,
            admin: {
                id: admin._id,
                username: admin.username,
                phone: admin.phone,
                dairyName: admin.dairyName
            }
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Admin Register (Setup Dairy)
exports.adminRegister = async (req, res) => {
    try {
        const { username, phone, password, dairyName } = req.body;

        // Prevent multiple admins for this simple app version if needed, or allow multiple.
        // User asked to "make dairy", implying one owner.
        const existingAdmin = await Admin.findOne({ phone });
        if (existingAdmin) return res.status(400).json({ message: 'Admin with this phone already exists' });

        const hashedPassword = await bcrypt.hash(password, 10);
        const newAdmin = new Admin({
            username,
            phone,
            password: hashedPassword,
            dairyName
        });
        await newAdmin.save();

        // Return token so they are logged in immediately
        const token = jwt.sign({ id: newAdmin._id, role: 'admin' }, JWT_SECRET, { expiresIn: '1d' });

        res.status(201).json({
            message: 'Dairy Setup Successfully',
            token,
            admin: {
                id: newAdmin._id,
                username: newAdmin.username,
                phone: newAdmin.phone,
                dairyName: newAdmin.dairyName
            }
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Reset Password
exports.resetPassword = async (req, res) => {
    try {
        const { username, phone, newPassword } = req.body;

        // Find admin by both username AND phone for security
        const admin = await Admin.findOne({ username, phone });
        if (!admin) {
            return res.status(404).json({ message: 'Invalid Username or Phone combination' });
        }

        const hashedPassword = await bcrypt.hash(newPassword, 10);
        admin.password = hashedPassword;
        await admin.save();

        res.json({ message: 'Password reset successful' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Farmer Login
exports.farmerLogin = async (req, res) => {
    try {
        const { phone, password } = req.body;
        const farmer = await Farmer.findOne({ phone });
        if (!farmer) return res.status(404).json({ message: 'Farmer not found' });

        // For simplicity, we can use simple password check or hashed. 
        // Assuming hashed for security as per plan.
        const isMatch = await bcrypt.compare(password, farmer.password);
        if (!isMatch) return res.status(400).json({ message: 'Invalid credentials' });

        const token = jwt.sign({ id: farmer._id, role: 'farmer' }, JWT_SECRET, { expiresIn: '7d' });
        res.json({ token, farmer: { id: farmer._id, name: farmer.name, phone: farmer.phone } });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
