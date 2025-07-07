const db = require("./db");

const getAllGroups = (callback) => {
  db.query("SELECT * FROM Groupes", callback);
};

const getGroupMessages = (groupId, callback) => {
  db.query(
    "SELECT * FROM Messages_Groupes WHERE id_groupe = ? ORDER BY date_envoi",
    [groupId],
    callback
  );
};
// ✅ Ajout de cette méthode
const createMessageDansGroupe = (message, callback) => {
  const { contenu ,id_utilisateur, id_groupe } = message;
  db.query(
    "INSERT INTO Messages_Groupes (contenu, id_utilisateur, id_groupe) VALUES (?, ?, ?)",
    [ contenu , id_utilisateur, id_groupe],
    callback
  );
};
module.exports = { getAllGroups, getGroupMessages,createMessageDansGroupe };
