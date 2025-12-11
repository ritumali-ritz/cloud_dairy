const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

router.get('/admin/check', authController.checkAdminExists);
router.post('/admin/reset', authController.resetPassword);
router.post('/admin/login', authController.adminLogin);
router.post('/admin/register', authController.adminRegister); // Protect this in production!
router.post('/login', authController.farmerLogin); // Farmer login

module.exports = router;
