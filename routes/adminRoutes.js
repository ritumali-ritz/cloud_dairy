const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');

// GET total milk collected across all collections
router.get('/total-milk', adminController.getTotalMilk);

module.exports = router;
