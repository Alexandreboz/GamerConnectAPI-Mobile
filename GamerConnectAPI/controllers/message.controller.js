const Message = require("../models/message.model");

exports.getAllMessages = (req, res) => {
  Message.getAllMessages((err, results) => {
    if (err) return res.status(500).json(err);
    res.json(results);
  });
};

exports.getConversation = (req, res) => {
  const { senderId, receiverId } = req.params;
  Message.getMessagesBetweenUsers(senderId, receiverId, (err, results) => {
    if (err) return res.status(500).json(err);
    res.json(results);
  });
};


