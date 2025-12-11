const express = require('express');
const router = express.Router();
const bankingController = require('../controllers/bankingController');

router.get('/wallet/:farmerId', bankingController.getWallet);
router.post('/payment', bankingController.makePayment);
router.post('/advance', bankingController.giveAdvance);
router.get('/transactions/:farmerId', bankingController.getTransactions);

module.exports = router;
