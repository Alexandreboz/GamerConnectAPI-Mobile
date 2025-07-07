const db = require("./db");

const getAllMessages = (callback) => {
  db.query("SELECT * FROM Messages", callback);
};

const getMessagesBetweenUsers = (senderId, receiverId, callback) => {
  db.query(
    `SELECT * FROM Messages 
     WHERE (id_envoyeur = ? AND id_recepteur = ?) 
        OR (id_envoyeur = ? AND id_recepteur = ?)
     ORDER BY date_envoi`,
    [senderId, receiverId, receiverId, senderId],
    callback
  );
};



module.exports = {
  getAllMessages,
  getMessagesBetweenUsers
};
