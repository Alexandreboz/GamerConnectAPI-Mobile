const express = require("express");
const router = express.Router();
const forumController = require("../controllers/forum.controller");

router.get("/", forumController.getAllForums);
router.post("/", forumController.createForum);
router.get("/:forumId/messages", forumController.getForumMessages);
router.post("/:forumId/messages", forumController.createMessage);
router.delete("/messages/:messageId", forumController.deleteMessage);
router.delete("/:forumId", forumController.deleteForum);

module.exports = router;
