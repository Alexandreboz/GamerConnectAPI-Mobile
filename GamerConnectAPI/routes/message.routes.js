const express = require("express");
const router = express.Router();
const messageController = require("../controllers/message.controller");

router.get("/", messageController.getAllMessages);
router.get("/:senderId/:receiverId", messageController.getConversation);

// ✅ Ajoute cette ligne
//router.post("/", messageController.createMessage);

module.exports = router;
