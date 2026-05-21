const Event = require("../models/evenement.model");
const db = require("../db");

exports.getEvents = (req, res) => {
  Event.getAllEvents((err, results) => {
    if (err) return res.status(500).json(err);
    res.json(results);
  });
};

exports.getEventById = (req, res) => {
  Event.getEventById(req.params.id, (err, results) => {
    if (err) return res.status(500).json(err);
    if (results.length === 0) return res.status(404).json({ message: "Événement non trouvé" });
    res.json(results[0]);
  });
};

exports.getParticipants = (req, res) => {
  const id_evenement = req.params.id;
  db.query(
    `SELECT p.id_participant, p.id_utilisateur, p.statut, u.pseudo
     FROM Participants p
     JOIN Utilisateurs u ON u.id_utilisateur = p.id_utilisateur
     WHERE p.id_evenement = ?`,
    [id_evenement],
    (err, results) => {
      if (err) return res.status(500).json({ error: "Erreur SQL" });
      res.json(results);
    }
  );
};

exports.getEventsForUser = (req, res) => {
  const id_utilisateur = req.params.userId;
  db.query(
    "SELECT id_evenement FROM Participants WHERE id_utilisateur = ? AND statut = 'Confirmé'",
    [id_utilisateur],
    (err, results) => {
      if (err) return res.status(500).json({ error: "Erreur SQL" });
      res.json(results);
    }
  );
};

exports.participer = (req, res) => {
  const id_evenement = req.params.id;
  const { id_utilisateur, action = 'join' } = req.body;
  if (!id_utilisateur) return res.status(400).json({ error: "id_utilisateur requis" });
  if (!['join', 'leave'].includes(action)) return res.status(400).json({ error: "Action invalide" });

  db.query("SELECT id_evenement FROM Evenements WHERE id_evenement = ?", [id_evenement], (err, eventRows) => {
    if (err) return res.status(500).json({ error: "Erreur SQL" });
    if (eventRows.length === 0) return res.status(404).json({ error: "Événement non trouvé" });

    if (action === 'leave') {
      db.query(
        "DELETE FROM Participants WHERE id_evenement = ? AND id_utilisateur = ?",
        [id_evenement, id_utilisateur],
        (err2) => {
          if (err2) return res.status(500).json({ error: "Erreur SQL" });
          return res.status(200).json({ message: "Désinscription enregistrée" });
        }
      );
      return;
    }

    db.query(
      "SELECT id_participant FROM Participants WHERE id_evenement = ? AND id_utilisateur = ?",
      [id_evenement, id_utilisateur],
      (err2, existingRows) => {
        if (err2) return res.status(500).json({ error: "Erreur SQL" });
        if (existingRows.length > 0) {
          db.query(
            "UPDATE Participants SET statut = 'Confirmé' WHERE id_participant = ?",
            [existingRows[0].id_participant],
            (err3) => {
              if (err3) return res.status(500).json({ error: "Erreur SQL" });
              return res.status(200).json({ message: "Inscription confirmée" });
            }
          );
          return;
        }

        db.query(
          "INSERT INTO Participants (id_evenement, id_utilisateur, statut) VALUES (?, ?, 'Confirmé')",
          [id_evenement, id_utilisateur],
          (err3, result) => {
            if (err3) return res.status(500).json({ error: "Erreur SQL" });
            res.status(201).json({ message: "Inscription enregistrée", id_participant: result.insertId });
          }
        );
      }
    );
  });
};