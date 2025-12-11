const express = require('express');
const router = express.Router();
const billController = require('../controllers/billController');

router.post('/generate', billController.generateBill);
router.get('/farmer/:farmerId', billController.getBills);

module.exports = router;
