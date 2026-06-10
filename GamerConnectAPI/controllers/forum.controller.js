const ForumService = require("../services/forum.service");
const db = require("../db");

exports.getAllForums = (req, res) => {
    ForumService.getAllForums((err, results) => {
        if (err) return res.status(500).json({ error: "Erreur SQL lors de la récupération des forums" });
        const forums = results.map((row) => ({
            id_forum: row.id_forum,
            jeu: row.jeu,
            description: row.description,
            date_creation: row.date_creation,
            message_count: row.message_count || 0,
        }));
        res.json(forums);
    });
};

exports.getForumMessages = (req, res) => {
    const forumId = parseInt(req.params.forumId, 10);
    const page = parseInt(req.query.page, 10) || 1;
    const limit = parseInt(req.query.limit, 10) || 50;

    if (!forumId) {
        return res.status(400).json({ error: "Identifiant de forum invalide" });
    }

    ForumService.getForumById(forumId, (err, forums) => {
        if (err) return res.status(500).json({ error: "Erreur SQL lors de la recherche du forum" });
        if (!forums || forums.length === 0) {
            return res.status(404).json({ error: "Forum introuvable" });
        }

        ForumService.getForumMessages(forumId, page, limit, (msgErr, messages) => {
            if (msgErr) return res.status(500).json({ error: "Erreur SQL lors de la récupération des messages" });
            res.json(messages.map((row) => ({
                id_message: row.id_message,
                id_forum: row.id_forum,
                id_utilisateur: row.id_utilisateur,
                pseudo: row.pseudo,
                prenom: row.prenom,
                nom: row.nom,
                contenu: row.contenu,
                date_creation: row.date_creation,
            })));
        });
    });
};

exports.createMessage = (req, res) => {
    const forumId = parseInt(req.params.forumId, 10);
    const { id_utilisateur, contenu } = req.body;

    if (!forumId || !id_utilisateur || !contenu) {
        return res.status(400).json({ error: "id_utilisateur, id_forum et contenu sont requis" });
    }

    ForumService.getForumById(forumId, (err, forums) => {
        if (err) return res.status(500).json({ error: "Erreur SQL lors de la recherche du forum" });
        if (!forums || forums.length === 0) {
            return res.status(404).json({ error: "Forum introuvable" });
        }

        ForumService.createForumMessage(forumId, id_utilisateur, contenu, (createErr, result) => {
            if (createErr) return res.status(500).json({ error: "Erreur SQL lors de la création du message" });

            db.query(
                `SELECT m.id_message, m.id_forum, m.id_utilisateur, m.contenu, m.date_creation,
                u.pseudo, u.prenom, u.nom
         FROM ForumMessages m
         JOIN Utilisateurs u ON u.id_utilisateur = m.id_utilisateur
         WHERE m.id_message = ?`,
                [result.insertId],
                (err2, rows) => {
                    if (err2) return res.status(500).json({ error: "Erreur SQL lors de la récupération du message" });
                    if (!rows || rows.length === 0) {
                        return res.status(500).json({ error: "Impossible de récupérer le message créé" });
                    }
                    const message = rows[0];
                    res.status(201).json({
                        id_message: message.id_message,
                        id_forum: message.id_forum,
                        id_utilisateur: message.id_utilisateur,
                        pseudo: message.pseudo,
                        prenom: message.prenom,
                        nom: message.nom,
                        contenu: message.contenu,
                        date_creation: message.date_creation,
                    });
                }
            );
        });
    });
};

exports.deleteMessage = (req, res) => {
    const messageId = parseInt(req.params.messageId, 10);
    const requesterId = parseInt(req.query.id_utilisateur, 10);
    const isAdmin = req.query.admin === 'true';

    if (!messageId || !requesterId) {
        return res.status(400).json({ error: "id_message et id_utilisateur sont requis" });
    }

    ForumService.getMessageById(messageId, (err, messages) => {
        if (err) return res.status(500).json({ error: "Erreur SQL lors de la recherche du message" });
        if (!messages || messages.length === 0) {
            return res.status(404).json({ error: "Message introuvable" });
        }

        const message = messages[0];
        if (message.id_utilisateur !== requesterId && !isAdmin) {
            return res.status(403).json({ error: "Seul l'auteur ou un administrateur peut supprimer ce message" });
        }

        ForumService.deleteMessageById(messageId, (deleteErr) => {
            if (deleteErr) return res.status(500).json({ error: "Erreur SQL lors de la suppression du message" });
            res.json({ success: true, id_message: messageId });
        });
    });
};

exports.deleteForum = (req, res) => {
    const forumId = parseInt(req.params.forumId, 10);
    const isAdmin = req.query.admin === 'true';

    if (!forumId) {
        return res.status(400).json({ error: "Identifiant de forum invalide" });
    }

    if (!isAdmin) {
        return res.status(403).json({ error: "Seul un administrateur peut supprimer un forum" });
    }

    ForumService.deleteForumById(forumId, (err) => {
        if (err) return res.status(500).json({ error: "Erreur SQL lors de la suppression du forum" });
        res.json({ success: true, id_forum: forumId });
    });
};

exports.createForum = (req, res) => {
    const { jeu, description } = req.body;
    if (!jeu) {
        return res.status(400).json({ error: "Le nom du forum est requis" });
    }

    ForumService.createForumIfNotExists(jeu, description || "", (err, result) => {
        if (err) return res.status(500).json({ error: "Erreur SQL lors de la création du forum" });
        res.status(201).json({ id_forum: result.insertId || null, jeu, description: description || "" });
    });
};
