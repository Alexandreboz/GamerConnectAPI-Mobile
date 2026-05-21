const express = require('express');
const router = express.Router();
const actuController = require('../controllers/actus.controller');

router.get('/', actuController.getActualites);
router.get('/:id', actuController.getActualiteById);

module.exports = router;
