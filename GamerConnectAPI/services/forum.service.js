const db = require("../db");

const getAllForums = (callback) => {
    const sql = `
    SELECT f.id_forum, f.jeu, f.description, f.date_creation,
      COUNT(m.id_message) AS message_count
    FROM Forums f
    LEFT JOIN ForumMessages m ON m.id_forum = f.id_forum
    GROUP BY f.id_forum
    ORDER BY message_count DESC, f.jeu
  `;
    db.query(sql, callback);
};

const getForumById = (forumId, callback) => {
    db.query("SELECT * FROM Forums WHERE id_forum = ?", [forumId], callback);
};

const getForumMessages = (forumId, page = 1, limit = 50, callback) => {
    const offset = (page - 1) * limit;
    db.query(
        `SELECT m.id_message, m.id_forum, m.id_utilisateur, m.contenu, m.date_creation,
            u.pseudo, u.prenom, u.nom
     FROM ForumMessages m
     JOIN Utilisateurs u ON u.id_utilisateur = m.id_utilisateur
     WHERE m.id_forum = ?
     ORDER BY m.date_creation DESC
     LIMIT ? OFFSET ?`,
        [forumId, limit, offset],
        callback
    );
};

const createForumMessage = (forumId, userId, content, callback) => {
    const sql = `
    INSERT INTO ForumMessages (id_forum, id_utilisateur, contenu)
    VALUES (?, ?, ?)`;
    db.query(sql, [forumId, userId, content], callback);
};

const getMessageById = (messageId, callback) => {
    db.query("SELECT * FROM ForumMessages WHERE id_message = ?", [messageId], callback);
};

const deleteMessageById = (messageId, callback) => {
    db.query("DELETE FROM ForumMessages WHERE id_message = ?", [messageId], callback);
};

const deleteForumById = (forumId, callback) => {
    db.query("DELETE FROM Forums WHERE id_forum = ?", [forumId], callback);
};

const createForumIfNotExists = (jeu, description, callback) => {
    db.query(
        `INSERT IGNORE INTO Forums (jeu, description)
     VALUES (?, ?)`,
        [jeu, description],
        callback
    );
};

module.exports = {
    getAllForums,
    getForumById,
    getForumMessages,
    createForumMessage,
    getMessageById,
    deleteMessageById,
    deleteForumById,
    createForumIfNotExists,
};
