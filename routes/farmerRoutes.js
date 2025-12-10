const express = require('express');
const router = express.Router();
const farmerController = require('../controllers/farmerController');

// Add middleware to verify admin token in production
router.post('/create', farmerController.createFarmer);
router.get('/all', farmerController.getAllFarmers);
router.get('/:id', farmerController.getFarmerById);

module.exports = router;
