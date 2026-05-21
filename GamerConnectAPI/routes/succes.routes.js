const express = require('express');
const router = express.Router();
const succesController = require('../controllers/succes.controller');

router.get('/', succesController.getSucces);
router.get('/:id', succesController.getSuccesById);

module.exports = router;
