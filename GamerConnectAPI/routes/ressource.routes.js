const express = require("express");
const router = express.Router();
const ressourceController = require("../controllers/ressource.controller");

router.get("/", ressourceController.getResources);

module.exports = router;