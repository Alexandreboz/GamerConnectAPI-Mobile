const db = require("../db");
const User = require("../models/user.model"); // ✅ Ajouté ici

exports.createUser = (req, res) => {
  const { nom, prenom, pseudo, email, mot_de_passe, plateformes_liees } = req.body;

  if (!nom || !prenom || !pseudo || !email || !mot_de_passe) {
    return res.status(400).json({ error: "Champs requis manquants." });
  }

  // Utilisation du modèle User
  User.createUser({ nom, prenom,pseudo, email, mot_de_passe, plateformes_liees }, (err, result) => {
    if (err) {
      console.error("Erreur lors de la création de l'utilisateur :", err);
      return res.status(500).json({ error: "Erreur serveur lors de la création." });
    }
    res.status(201).json({ message: "Utilisateur créé avec succès", userId: result.insertId });
  });
};

exports.getAllUsers = (req, res) => {
  User.getAllUsers((err, users) => {
    if (err) return res.status(500).json({ error: "Erreur serveur" });
    res.json(users);
  });
};

exports.getUserById = (req, res) => {
  const id = req.params.id;
  User.getUserById(id, (err, result) => {
    if (err) return res.status(500).json({ error: "Erreur serveur" });
    if (result.length === 0) return res.status(404).json({ error: "Utilisateur non trouvé" });
    res.json(result[0]);
  });
};

exports.getUserBypseudo = (req, res) => {
  const pseudo = req.params.pseudo;
  User.getUserBypseudo(pseudo, (err, result) => {
    if (err) return res.status(500).json({ error: "Erreur serveur" });
    if (result.length === 0) return res.status(404).json({ error: "Utilisateur non trouvé" });
    res.json(result[0]);
  });
};

exports.updateUser = (req, res) => {
  const { nom, prenom,  email, plateformes_liees } = req.body;
  db.query(
    "UPDATE Utilisateurs SET nom = ?, prenom = ?, email = ?, plateformes_liees = ? WHERE id_utilisateur = ?",
    [nom, prenom, email, plateformes_liees, req.params.id],
    (err) => {
      if (err) return res.status(500).json({ error: "Erreur serveur" });
      res.json({ message: "Utilisateur mis à jour" });
    }
  );
};

exports.deleteUser = (req, res) => {
  db.query("DELETE FROM Utilisateurs WHERE id_utilisateur = ?", [req.params.id], (err) => {
    if (err) return res.status(500).json({ error: "Erreur serveur" });
    res.json({ message: "Utilisateur supprimé" });
  });
};
