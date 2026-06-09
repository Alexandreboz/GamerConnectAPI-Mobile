const express = require("express");
const router = express.Router();
const evenementController = require("../controllers/evenement.controller");

router.get("/", evenementController.getEvents);
router.post("/", evenementController.createEvent);
router.get("/user/:userId", evenementController.getEventsForUser);
router.get("/:id/participants", evenementController.getParticipants);
router.post("/:id/participer", evenementController.participer);
router.get("/:id", evenementController.getEventById);

module.exports = router;