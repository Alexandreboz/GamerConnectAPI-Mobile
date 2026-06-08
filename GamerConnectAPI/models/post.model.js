const db = require("./db");

const getAllPosts = (callback) => {
    const sql = `
    SELECT p.id_post, p.contenu, p.tags, p.date_creation,
           u.id_utilisateur, u.pseudo, u.prenom, u.nom
    FROM Posts p
    JOIN Utilisateurs u ON p.id_utilisateur = u.id_utilisateur
    ORDER BY p.date_creation DESC`;
    db.query(sql, callback);
};

const createPost = (post, callback) => {
    const { id_utilisateur, contenu, tags } = post;
    const sql = `INSERT INTO Posts (id_utilisateur, contenu, tags) VALUES (?, ?, ?)`;
    db.query(sql, [id_utilisateur, contenu, tags], callback);
};

module.exports = {
    getAllPosts,
    createPost,
};
