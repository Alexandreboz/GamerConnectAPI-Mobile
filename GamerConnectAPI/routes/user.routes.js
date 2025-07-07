const express = require("express");
const router = express.Router();
const userController = require("../controllers/user.controller");

router.get("/", userController.getAllUsers);
router.get("/id/:id", userController.getUserById);              // ✅ 
router.get("/pseudo/:pseudo", userController.getUserBypseudo);  // ✅
router.post("/", userController.createUser);
router.put("/:id", userController.updateUser);
router.delete("/:id", userController.deleteUser);

module.exports = router;
