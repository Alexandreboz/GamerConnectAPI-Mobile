const Post = require("../models/post.model");
const db = require("../db");

exports.getAllPosts = (req, res) => {
    Post.getAllPosts((err, results) => {
        if (err) return res.status(500).json(err);
        const posts = results.map((row) => ({
            id_post: row.id_post,
            contenu: row.contenu,
            tags: row.tags ? row.tags.split(",").map((tag) => tag.trim()) : [],
            date_creation: row.date_creation,
            id_utilisateur: row.id_utilisateur,
            pseudo: row.pseudo,
            prenom: row.prenom,
            nom: row.nom,
        }));
        res.json(posts);
    });
};

exports.createPost = (req, res) => {
    const { id_utilisateur, contenu, tags } = req.body;
    if (!id_utilisateur || !contenu) {
        return res.status(400).json({ error: "id_utilisateur et contenu sont requis" });
    }

    const tagsString = Array.isArray(tags)
        ? tags.join(",")
        : typeof tags === "string"
            ? tags
            : "";

    Post.createPost({ id_utilisateur, contenu, tags: tagsString }, (err, result) => {
        if (err) return res.status(500).json({ error: "Erreur SQL lors de la création du post" });

        db.query(
            "SELECT pseudo, prenom, nom FROM Utilisateurs WHERE id_utilisateur = ?",
            [id_utilisateur],
            (err2, rows) => {
                if (err2) return res.status(500).json({ error: "Erreur SQL lors de la récupération de l'utilisateur" });
                const user = rows[0] || {};
                res.status(201).json({
                    id_post: result.insertId,
                    id_utilisateur,
                    contenu,
                    tags: tagsString
                        .split(",")
                        .map((tag) => tag.trim())
                        .filter((tag) => tag !== ""),
                    date_creation: new Date(),
                    pseudo: user.pseudo || "Utilisateur",
                    prenom: user.prenom || "",
                    nom: user.nom || "",
                });
            }
        );
    });
};
