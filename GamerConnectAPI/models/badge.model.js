const db = require("./db");

const getAllBadges = (callback) => {
  db.query("SELECT * FROM Badges", callback);
};

module.exports = { getAllBadges };