const express = require('express');
const router = express.Router();
const feedController = require('../controllers/feedController');

router.post('/send', feedController.sendFeed);
router.get('/farmer/:id', feedController.getFeeds);

module.exports = router;
