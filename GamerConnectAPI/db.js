const mysql = require("mysql2");

const db = mysql.createConnection({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'gameruser',
  password: process.env.DB_PASSWORD || 'gamerpass',
  database: process.env.DB_NAME || 'GamerConnect',
});

db.connect((err) => {
  if (err) {
    console.error("Erreur de connexion à MySQL :", err.message);
  } else {
    console.log("Connexion à la base MySQL réussie !");
  }
});

module.exports = db;
