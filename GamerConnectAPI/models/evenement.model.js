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

const createEvent = (eventData, callback) => {
  const sql = `
    INSERT INTO Evenements
      (nom_evenement, description, date_evenement, jeu, lieu, id_organisateur)
    VALUES (?, ?, ?, ?, ?, ?)
  `;
  db.query(
    sql,
    [
      eventData.nom_evenement,
      eventData.description,
      eventData.date_evenement,
      eventData.jeu,
      eventData.lieu,
      eventData.id_organisateur,
    ],
    callback
  );
};

module.exports = {
  getAllEvents,
  getEventById,
  createEvent,
};