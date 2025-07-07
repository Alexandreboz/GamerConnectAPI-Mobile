import 'package:flutter/material.dart';

class SuccesPage extends StatelessWidget {
  final List<Map<String, String>> succes = [
    {
      'jeu': 'Dofus',
      'titre': 'Maître des familiers',
      'description': 'Atteindre le niveau maximum d’un familier.',
    },
    {
      'jeu': 'Pokémon',
      'titre': 'Dresseur Élite',
      'description': 'Battre la Ligue Pokémon sans perdre un seul combat.',
    },
    {
      'jeu': 'Monster Hunter',
      'titre': 'Chasseur de légende',
      'description': 'Terrasser un dragon ancien en solo.',
    },
    {
      'jeu': 'FIFA',
      'titre': 'Champion FUT',
      'description': 'Gagner 5 matchs consécutifs en mode FUT.',
    },
    {
      'jeu': 'Pokémon',
      'titre': 'Collectionneur',
      'description': 'Attraper 100 Pokémon différents.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mes Succès"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF0F0B1E),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: succes.length,
        itemBuilder: (context, index) {
          final item = succes[index];
          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(Icons.emoji_events, color: Colors.amber, size: 30),
              title: Text(item['titre']!, style: TextStyle(color: Colors.white)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['jeu']!, style: TextStyle(color: Colors.purpleAccent)),
                  SizedBox(height: 4),
                  Text(item['description']!, style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
