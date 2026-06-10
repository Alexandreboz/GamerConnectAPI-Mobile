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
    db.query(
      `CREATE TABLE IF NOT EXISTS Forums (
         id_forum INT AUTO_INCREMENT PRIMARY KEY,
         jeu VARCHAR(100) NOT NULL UNIQUE,
         description TEXT,
         date_creation DATETIME DEFAULT CURRENT_TIMESTAMP
       ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;`,
      (forumErr) => {
        if (forumErr) {
          console.error("Impossible de créer la table Forums :", forumErr.message);
        } else {
          console.log("Table Forums vérifiée.");
        }
      }
    );

    db.query(
      `CREATE TABLE IF NOT EXISTS ForumMessages (
         id_message INT AUTO_INCREMENT PRIMARY KEY,
         id_forum INT NOT NULL,
         id_utilisateur INT NOT NULL,
         contenu TEXT NOT NULL,
         date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
         FOREIGN KEY (id_forum) REFERENCES Forums(id_forum) ON DELETE CASCADE,
         FOREIGN KEY (id_utilisateur) REFERENCES Utilisateurs(id_utilisateur) ON DELETE CASCADE
       ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;`,
      (msgErr) => {
        if (msgErr) {
          console.error("Impossible de créer la table ForumMessages :", msgErr.message);
        } else {
          console.log("Table ForumMessages vérifiée.");
        }
      }
    );

    db.query(
      `INSERT IGNORE INTO Forums (jeu, description) VALUES ?`,
      [
        [
          ['Dofus', 'Forum de discussion dédié à Dofus'],
          ['Pokémon', 'Stratégie, échanges et actualités Pokémon'],
          ['Monster Hunter', 'Chasses, builds et conseils Monster Hunter'],
          ['FIFA', 'Discussions, compétitions et astuces FIFA'],
          ['League of Legends', 'Tactiques d’équipe et conseils LoL'],
        ],
      ],
      (seedErr) => {
        if (seedErr) {
          console.error("Impossible de semer les forums par défaut :", seedErr.message);
        } else {
          console.log("Forums par défaut semés.");
        }
      }
    );
  }
});

module.exports = db;
