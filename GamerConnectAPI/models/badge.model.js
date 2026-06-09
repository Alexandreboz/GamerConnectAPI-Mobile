const db = require("./db");

const getAllBadges = (callback) => {
  db.query("SELECT * FROM Badges", callback);
};

const getBadgeStats = (callback) => {
  const sql = `
    SELECT
      b.id_badge,
      b.nom_badge,
      b.description,
      b.conditions,
      COUNT(o.id_obtention) AS obtained_count,
      COUNT(DISTINCT o.id_utilisateur) AS user_count
    FROM Badges b
    LEFT JOIN Obtention_Badges o ON b.id_badge = o.id_badge
    GROUP BY b.id_badge, b.nom_badge, b.description, b.conditions
    ORDER BY obtained_count DESC
  `;
  db.query(sql, callback);
};

const getBadgeStatsByGame = (callback) => {
  const sql = `
    SELECT
      COALESCE(b.jeu, 'Inconnu') AS jeu,
      COUNT(DISTINCT b.id_badge) AS badge_count,
      COUNT(o.id_obtention) AS obtained_count,
      COUNT(DISTINCT o.id_utilisateur) AS user_count
    FROM Badges b
    LEFT JOIN Obtention_Badges o ON b.id_badge = o.id_badge
    GROUP BY b.jeu
    ORDER BY obtained_count DESC
  `;
  db.query(sql, callback);
};

module.exports = { getAllBadges, getBadgeStats, getBadgeStatsByGame };