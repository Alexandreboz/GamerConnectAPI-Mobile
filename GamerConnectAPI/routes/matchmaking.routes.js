const express = require("express");
const router = express.Router();
const matchmakingController = require("../controllers/matchmaking.controller");

router.get("/", matchmakingController.getAll);

module.exports = router;