const mysql = require("mysql2");

const db = mysql.createConnection({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'gameruser',
  password: process.env.DB_PASSWORD || 'gamerpass',
  database: process.env.DB_NAME || 'GamerConnect',
  charset: 'utf8mb4',
});

db.connect((err) => {
  if (err) {
    console.error("Erreur de connexion à MySQL :", err.message);
  } else {
    console.log("Connexion à la base MySQL réussie !");
    db.query(
      "ALTER TABLE Evenements ADD COLUMN IF NOT EXISTS jeu VARCHAR(100), ADD COLUMN IF NOT EXISTS lieu VARCHAR(255)",
      (alterErr) => {
        if (alterErr) {
          console.error("Impossible d'ajouter les colonnes jeu/lieu à Evenements :", alterErr.message);
        } else {
          console.log("Colonnes jeu/lieu dans Evenements vérifiées.");
        }
      }
    );
    db.query(
      "ALTER TABLE Participants MODIFY statut ENUM('Confirmé','En attente','Refusé') DEFAULT 'En attente'",
      (alterErr) => {
        if (alterErr) {
          console.error("Impossible de normaliser la colonne statut de Participants :", alterErr.message);
        } else {
          console.log("Colonne statut de Participants normalisée.");
        }
      }
    );
  }
});

module.exports = db;
