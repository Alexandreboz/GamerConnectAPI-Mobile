const express = require("express");
const router = express.Router();
const groupeController = require("../controllers/groupe.controller");

router.get("/", groupeController.getAllGroupes);
router.get("/:id/membres", groupeController.getMembresGroupe);
router.get("/:id/messages", groupeController.getMessagesDuGroupe);
router.post("/:id/rejoindre", groupeController.rejoindreGroupe);

// Facultatif : délègue la création de message via contrôleur
 router.post("/messages", groupeController.createMessageDansGroupe);

module.exports = router;
