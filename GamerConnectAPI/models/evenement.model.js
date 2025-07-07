const db = require("./db");

const getAllEvents = (callback) => {
  db.query("SELECT * FROM Evenements", callback);
};

const getEventById = (id, callback) => {
  db.query("SELECT * FROM Evenements WHERE id_evenement = ?", [id], callback);
};

module.exports = {
  getAllEvents,
  getEventById,
};