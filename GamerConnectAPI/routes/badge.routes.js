const express = require("express");
const router = express.Router();
const badgeController = require("../controllers/badge.controller");

router.get("/", badgeController.getBadges);
router.get("/stats", badgeController.getBadgeStats);
router.get("/stats/game", badgeController.getBadgeStatsByGame);

module.exports = router;