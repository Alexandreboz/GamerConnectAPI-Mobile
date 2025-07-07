const express = require("express");
const router = express.Router();
const badgeController = require("../controllers/badge.controller");

router.get("/", badgeController.getBadges);

module.exports = router;