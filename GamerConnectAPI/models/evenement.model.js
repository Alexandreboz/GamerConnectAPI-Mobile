const db = require("./db");

const getAllEvents = (callback) => {
  const sql = `
    SELECT
      e.*,
      COUNT(p.id_participant) AS participants
    FROM Evenements e
    LEFT JOIN Participants p
      ON e.id_evenement = p.id_evenement AND p.statut = 'Confirmé'
    GROUP BY e.id_evenement
  `;
  db.query(sql, callback);
};

const getEventById = (id, callback) => {
  const sql = `
    SELECT
      e.*,
      COUNT(p.id_participant) AS participants
    FROM Evenements e
    LEFT JOIN Participants p
      ON e.id_evenement = p.id_evenement AND p.statut = 'Confirmé'
    WHERE e.id_evenement = ?
    GROUP BY e.id_evenement
  `;
  db.query(sql, [id], callback);
};

module.exports = {
  getAllEvents,
  getEventById,
};