const db = require("./db");

const getAllResources = (callback) => {
  db.query("SELECT * FROM Ressources_Educatives", callback);
};

module.exports = { getAllResources };