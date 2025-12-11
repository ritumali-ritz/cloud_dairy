const express = require('express');
const router = express.Router();
const rateController = require('../controllers/rateController');

router.post('/update', rateController.updateRate);
router.get('/get', rateController.getRate); // ?type=Cow&fat=3.5&snf=8.5
router.get('/all', rateController.getAllRates);

module.exports = router;
