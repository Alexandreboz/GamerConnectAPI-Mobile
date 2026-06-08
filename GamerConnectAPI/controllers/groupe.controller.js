const db = require("../db");

// ➕ Ajouter un utilisateur à un groupe
exports.rejoindreGroupe = (req, res) => {
  const id_groupe = req.params.id;
  const { id_utilisateur } = req.body;

  if (!id_groupe || !id_utilisateur)
    return res.status(400).json({ error: "Champs requis manquants" });

  const query = `
    INSERT IGNORE INTO Membres_Groupe (id_utilisateur, id_groupe)
    VALUES (?, ?)
  `;

  db.query(query, [id_utilisateur, id_groupe], (err, result) => {
    if (err) return res.status(500).json({ error: "Erreur SQL" });

    if (result.affectedRows === 0) {
      return res.status(200).json({ message: "Utilisateur déjà membre du groupe" });
    }

    res.status(201).json({ message: "Utilisateur ajouté au groupe" });
  });
};

// 👥 Obtenir les membres d’un groupe
exports.getMembresGroupe = (req, res) => {
  const id_groupe = req.params.id;

  if (!id_groupe) return res.status(400).json({ error: "id_groupe requis" });

  const query = `
    SELECT u.id_utilisateur, u.nom, u.prenom, u.pseudo
    FROM Membres_Groupe mg
    JOIN Utilisateurs u ON u.id_utilisateur = mg.id_utilisateur
    WHERE mg.id_groupe = ?
  `;

  db.query(query, [id_groupe], (err, result) => {
    if (err) return res.status(500).json({ error: "Erreur SQL" });
    res.json(result);
  });
};

// 📋 Obtenir tous les groupes
exports.getAllGroupes = (req, res) => {
  db.query("SELECT * FROM Groupes", (err, result) => {
    if (err) return res.status(500).json({ error: "Erreur SQL" });
    res.json(result);
  });
};

// ➕ Créer un nouveau groupe
exports.createGroupe = (req, res) => {
  const { nom_groupe, description = '', id_utilisateur } = req.body;

  if (!nom_groupe || !id_utilisateur) {
    return res.status(400).json({ error: 'nom_groupe et id_utilisateur sont requis' });
  }

  const query = `
    INSERT INTO Groupes (nom_groupe, description)
    VALUES (?, ?)
  `;

  db.query(query, [nom_groupe, description], (err, result) => {
    if (err) return res.status(500).json({ error: 'Erreur SQL lors de la création du groupe' });

    const groupId = result.insertId;
    const memberQuery = `
      INSERT INTO Membres_Groupe (id_utilisateur, id_groupe)
      VALUES (?, ?)
    `;

    db.query(memberQuery, [id_utilisateur, groupId], (memberErr) => {
      if (memberErr) {
        return res.status(500).json({ error: 'Impossible d’ajouter le créateur au groupe' });
      }

      res.status(201).json({ id_groupe: groupId, nom_groupe, description });
    });
  });
};

// 💬 Obtenir les messages d’un groupe
exports.getMessagesDuGroupe = (req, res) => {
  const id_groupe = req.params.id;

  db.query(
    `SELECT mg.*, u.pseudo
     FROM Messages_Groupes mg
     JOIN Utilisateurs u ON u.id_utilisateur = mg.id_utilisateur
     WHERE mg.id_groupe = ?
     ORDER BY mg.id_message ASC`,
    [id_groupe],
    (err, result) => {
      if (err) return res.status(500).json({ error: "Erreur SQL" });
      res.json(result);
    }
  );
};

// (facultatif) créer un message depuis /groupes/:id/messages (alternatif à /messages)
exports.createMessageDansGroupe = (req, res) => {
  const { contenu, id_utilisateur, id_groupe } = req.body;

  if (!contenu || !id_utilisateur || !id_groupe) {
    return res.status(400).json({ error: "Champs manquants" });
  }

  console.log("📨 Contenu du message :", contenu);
  console.log("👤 Utilisateur :", id_utilisateur);
  console.log("💬 Groupe :", id_groupe);

  const query = `
    INSERT INTO Messages_Groupes (contenu, id_utilisateur, id_groupe)
    VALUES (?, ?, ?)
  `;

  const db = require("../db");
  db.query(query, [id_utilisateur, id_groupe, contenu], (err, result) => {
    if (err) {
      console.error("❌ Erreur SQL lors de la création du message :", err);
      return res.status(500).json({ error: "Erreur SQL" });
    }
    res.status(201).json({ message: "Message envoyé", id_message: result.insertId });
  });
};