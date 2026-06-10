CREATE DATABASE IF NOT EXISTS GamerConnect CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE GamerConnect;

CREATE TABLE Utilisateurs (
    id_utilisateur INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    pseudo VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    mot_de_passe VARCHAR(255) NOT NULL,
    date_inscription DATETIME DEFAULT CURRENT_TIMESTAMP,
    plateformes_liees TEXT
);

CREATE TABLE Profils (
    id_profil INT AUTO_INCREMENT PRIMARY KEY,
    id_utilisateur INT NOT NULL,
    avatar VARCHAR(255),
    jeux_favoris TEXT,
    succes_obtenus TEXT,
    biographie TEXT,
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateurs(id_utilisateur) ON DELETE CASCADE
);

CREATE TABLE Posts (
    id_post INT AUTO_INCREMENT PRIMARY KEY,
    id_utilisateur INT NOT NULL,
    contenu TEXT NOT NULL,
    tags VARCHAR(255),
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateurs(id_utilisateur) ON DELETE CASCADE
);

CREATE TABLE Messages (
    id_message INT AUTO_INCREMENT PRIMARY KEY,
    id_envoyeur INT NOT NULL,
    id_recepteur INT NOT NULL,
    contenu TEXT NOT NULL,
    date_envoi DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_envoyeur) REFERENCES Utilisateurs(id_utilisateur) ON DELETE CASCADE,
    FOREIGN KEY (id_recepteur) REFERENCES Utilisateurs(id_utilisateur) ON DELETE CASCADE
);

CREATE TABLE Groupes (
    id_groupe INT AUTO_INCREMENT PRIMARY KEY,
    nom_groupe VARCHAR(100) NOT NULL,
    description TEXT,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Membres_Groupe (
    id_membre INT AUTO_INCREMENT PRIMARY KEY,
    id_groupe INT NOT NULL,
    id_utilisateur INT NOT NULL,
    date_adhesion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_groupe) REFERENCES Groupes(id_groupe) ON DELETE CASCADE,
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateurs(id_utilisateur) ON DELETE CASCADE
);

CREATE TABLE Evenements (
    id_evenement INT AUTO_INCREMENT PRIMARY KEY,
    nom_evenement VARCHAR(100) NOT NULL,
    description TEXT,
    date_evenement DATETIME NOT NULL,
    id_organisateur INT NOT NULL,
    FOREIGN KEY (id_organisateur) REFERENCES Utilisateurs(id_utilisateur) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Participants (
    id_participant INT AUTO_INCREMENT PRIMARY KEY,
    id_evenement INT NOT NULL,
    id_utilisateur INT NOT NULL,
    statut ENUM('Confirmé', 'En attente', 'Refusé') DEFAULT 'En attente',
    FOREIGN KEY (id_evenement) REFERENCES Evenements(id_evenement) ON DELETE CASCADE,
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateurs(id_utilisateur) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Ressources_Educatives (
    id_ressource INT AUTO_INCREMENT PRIMARY KEY,
    titre VARCHAR(255) NOT NULL,
    type_ressource ENUM('Article', 'Vidéo', 'Tutoriel') NOT NULL,
    contenu TEXT NOT NULL,
    date_publication DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_auteur INT NOT NULL,
    FOREIGN KEY (id_auteur) REFERENCES Utilisateurs(id_utilisateur) ON DELETE CASCADE
);

CREATE TABLE Badges (
    id_badge INT AUTO_INCREMENT PRIMARY KEY,
    nom_badge VARCHAR(100) NOT NULL,
    jeu VARCHAR(100),
    description TEXT,
    conditions TEXT
);

CREATE TABLE Obtention_Badges (
    id_obtention INT AUTO_INCREMENT PRIMARY KEY,
    id_utilisateur INT NOT NULL,
    id_badge INT NOT NULL,
    date_obtention DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateurs(id_utilisateur) ON DELETE CASCADE,
    FOREIGN KEY (id_badge) REFERENCES Badges(id_badge) ON DELETE CASCADE
);
CREATE TABLE Signalements (
    id_signalement INT AUTO_INCREMENT PRIMARY KEY,
    id_signale INT NOT NULL,
    id_reporter INT NOT NULL,
    motif ENUM('Spam', 'Insulte', 'Triche', 'Autre') NOT NULL,
    commentaire TEXT,
    date_signalement DATETIME DEFAULT CURRENT_TIMESTAMP,
    statut ENUM('En attente', 'En cours', 'Résolu') DEFAULT 'En attente',
    FOREIGN KEY (id_signale) REFERENCES Utilisateurs(id_utilisateur),
    FOREIGN KEY (id_reporter) REFERENCES Utilisateurs(id_utilisateur)
);
CREATE TABLE Messages_Groupes (
  id_message INT AUTO_INCREMENT PRIMARY KEY,
  id_utilisateur INT NOT NULL,
  id_groupe INT NOT NULL,
  contenu TEXT NOT NULL,
  date_envoi DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_utilisateur) REFERENCES Utilisateurs(id_utilisateur) ON DELETE CASCADE,
  FOREIGN KEY (id_groupe) REFERENCES Groupes(id_groupe) ON DELETE CASCADE
);
CREATE TABLE Matchmaking (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_utilisateur INT NOT NULL,
    jeu VARCHAR(100),
    niveau ENUM('Débutant', 'Intermédiaire', 'Avancé'),
    type_recherche ENUM('1v1', 'Team', 'Casual'),
    date_disponibilite DATETIME,
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateurs(id_utilisateur)
);

-- Ajouter des utilisateurs
INSERT INTO Utilisateurs (nom, prenom,pseudo, email, mot_de_passe, plateformes_liees) VALUES
('Dupont', 'Jean','jeand', 'jean.dupont@email.com', 'hashedpassword123', 'Steam,PSN'),
('Martin', 'Claire','clairem', 'claire.martin@email.com', 'hashedpassword456', 'Xbox,Steam');

-- Ajouter un événement
INSERT INTO Evenements (nom_evenement, description, date_evenement, jeu, lieu, id_organisateur) VALUES
('Tournoi FIFA 23', 'Tournoi en ligne pour FIFA 23', '2024-06-15 18:00:00', 'FIFA', 'Paris Arena', 1),
('Soirée Rocket League', 'Session 3v3 pour progresser en équipe.', '2024-07-02 20:00:00', 'Rocket League', 'E-sport Zone', 2),
('Marathon Mario Kart', 'Course non-stop autour des circuits les plus fous.', '2024-07-05 18:30:00', 'Mario Kart', 'Lounge Gamer', 1),
('Nuit Valorant', 'Des matchs compétitifs en 5v5 pour grimper.', '2024-07-10 21:00:00', 'Valorant', 'Cyber Arena', 2),
('Challenge Apex Legends', 'Affrontez des équipes pour décrocher la victoire.', '2024-07-15 19:30:00', 'Apex Legends', 'Gaming House', 1),
('Tournoi League of Legends', 'Brackets éliminatoires 5v5.', '2024-07-20 20:00:00', 'League of Legends', 'Stade Virtuel', 2),
('Camp d’entraînement CS:GO', 'Améliore ton aim et ta stratégie en team.', '2024-07-25 18:00:00', 'CS:GO', 'Arena 5', 1),
('Session Co-op Diablo IV', 'Explorez les donjons ensemble.', '2024-07-28 19:00:00', 'Diablo IV', 'Dark Cellar', 2),
('Soirée Fortnite', 'Battle Royale détendu entre amis.', '2024-08-01 20:30:00', 'Fortnite', 'Rooftop Party', 1),
('Compétition Overwatch 2', 'Des affrontements en escouade serrés.', '2024-08-05 19:00:00', 'Overwatch 2', 'E-Sport Café', 2),
('Tournoi Super Smash Bros.', 'Combattez pour le titre du meilleur joueur.', '2024-08-10 18:00:00', 'Super Smash Bros.', 'Retro Lounge', 1);

INSERT INTO Groupes (nom_groupe, description)
VALUES ('Dofus', 'Groupe de soutiens des nouveaux joueurs sur tous les serveurs');
Insert Into Groupes (nom_groupe, description) 
values ('Monster Hunter', 'Groupe de chasseurs pour solution de chasse a tous niveaux');

CREATE TABLE IF NOT EXISTS Forums (
    id_forum INT AUTO_INCREMENT PRIMARY KEY,
    jeu VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ForumMessages (
    id_message INT AUTO_INCREMENT PRIMARY KEY,
    id_forum INT NOT NULL,
    id_utilisateur INT NOT NULL,
    contenu TEXT NOT NULL,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_forum) REFERENCES Forums(id_forum) ON DELETE CASCADE,
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateurs(id_utilisateur) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO Forums (jeu, description) VALUES
('Dofus', 'Forum de discussion dédié à Dofus'),
('Pokémon', 'Stratégie, échanges et actualités Pokémon'),
('Monster Hunter', 'Chasses, builds et conseils Monster Hunter'),
('FIFA', 'Discussions, compétitions et astuces FIFA'),
('League of Legends', 'Tactiques d’équipe et conseils LoL');