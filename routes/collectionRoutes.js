const express = require('express');
const router = express.Router();
const collectionController = require('../controllers/collectionController');

router.post('/add', collectionController.addCollection);
router.get('/by-farmer/:id', collectionController.getCollectionsByFarmer);
router.get('/last10/:id', collectionController.getLast10Collections);

module.exports = router;
