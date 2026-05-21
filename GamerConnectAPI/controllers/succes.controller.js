const succes = [
    {
        id_succes: 1,
        jeu: 'Dofus',
        titre: 'Maître des familiers',
        description: 'Atteindre le niveau maximum d’un familier.',
    },
    {
        id_succes: 2,
        jeu: 'Pokémon',
        titre: 'Dresseur Élite',
        description: 'Battre la Ligue Pokémon sans perdre un seul combat.',
    },
    {
        id_succes: 3,
        jeu: 'Monster Hunter',
        titre: 'Chasseur de légende',
        description: 'Terrasser un dragon ancien en solo.',
    },
    {
        id_succes: 4,
        jeu: 'FIFA',
        titre: 'Champion FUT',
        description: 'Gagner 5 matchs consécutifs en mode FUT.',
    },
    {
        id_succes: 5,
        jeu: 'Pokémon',
        titre: 'Collectionneur',
        description: 'Attraper 100 Pokémon différents.',
    },
];

exports.getSucces = (req, res) => {
    res.json(succes);
};

exports.getSuccesById = (req, res) => {
    const id = Number(req.params.id);
    const item = succes.find((entry) => entry.id_succes === id);
    if (!item) return res.status(404).json({ message: 'Succès non trouvé' });
    res.json(item);
};
