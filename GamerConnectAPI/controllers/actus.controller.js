const actus = [
    {
        id_actu: 1,
        jeu: 'Dofus',
        titre: 'Serveur Temporis 8 lancé',
        contenu: 'La nouvelle édition de Temporis est lancée avec des récompenses exclusives.',
        image: 'assets/images/dofus.png',
        date_publication: '2026-05-21',
    },
    {
        id_actu: 2,
        jeu: 'Pokémon',
        titre: 'Nouveaux raids dans Écarlate & Violet',
        contenu: 'Les raids Téracristal ajoutent de nouveaux Pokémon événementiels.',
        image: 'assets/images/pokemon.png',
        date_publication: '2026-05-20',
    },
    {
        id_actu: 3,
        jeu: 'Monster Hunter',
        titre: 'Iceborne offert pour une durée limitée',
        contenu: 'Capcom propose l’extension Iceborne gratuitement pour une durée limitée.',
        image: 'assets/images/monster.png',
        date_publication: '2026-05-18',
    },
    {
        id_actu: 4,
        jeu: 'FIFA',
        titre: 'Mises à jour du mode FUT',
        contenu: 'EA Sports annonce un équilibrage des récompenses du mode Ultimate Team.',
        image: 'assets/images/fifa.png',
        date_publication: '2026-05-17',
    },
];

exports.getActualites = (req, res) => {
    res.json(actus);
};

exports.getActualiteById = (req, res) => {
    const id = Number(req.params.id);
    const actu = actus.find((item) => item.id_actu === id);
    if (!actu) return res.status(404).json({ message: 'Actualité non trouvée' });
    res.json(actu);
};
