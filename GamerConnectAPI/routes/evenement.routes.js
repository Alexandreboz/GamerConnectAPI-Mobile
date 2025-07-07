const express = require("express");
const router = express.Router();
const evenementController = require("../controllers/evenement.controller");

router.get("/", evenementController.getEvents);
router.get("/:id", evenementController.getEventById);

module.exports = router;