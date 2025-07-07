const db = require("./db");

const getAllMatchRequests = (callback) => {
  db.query("SELECT * FROM Matchmaking", callback);
};

module.exports = { getAllMatchRequests };