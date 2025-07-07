import 'package:flutter/material.dart';
import 'actu_detail_page.dart';

class ActuPage extends StatelessWidget {
  final List<Map<String, String>> actus = [
    {
      'titre': 'Dofus - Serveur Temporis 8 lancé',
      'image': 'assets/images/dofus.png',
      'jeu': 'Dofus',
      'contenu': 'La nouvelle édition de Temporis est lancée avec des récompenses exclusives.',
    },
    {
      'titre': 'Pokémon - Nouveaux raids dans Écarlate & Violet',
      'image': 'assets/images/pokemon.png',
      'jeu': 'Pokémon',
      'contenu': 'Les raids Téracristal ajoutent de nouveaux Pokémon événementiels.',
    },
    {
      'titre': 'Monster Hunter - Extension Iceborne gratuite',
      'image': 'assets/images/monster.png',
      'jeu': 'Monster Hunter',
      'contenu': 'Capcom offre l\'extension Iceborne gratuitement pour une durée limitée.',
    },
    {
      'titre': 'FIFA - Mises à jour du mode FUT',
      'image': 'assets/images/fifa.png',
      'jeu': 'FIFA',
      'contenu': 'EA Sports annonce un équilibrage des récompenses du mode Ultimate Team.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actus récentes'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Color(0xFF0F0B1E),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: actus.length,
        itemBuilder: (context, index) {
          final actu = actus[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ActuDetailPage(
                    jeu: actu['jeu']!,
                    titre: actu['titre']!,
                    contenu: actu['contenu']!,
                    image: actu['image']!,
                  ),
                ),
              );
            },
            child: Card(
              color: Colors.grey[900],
              margin: EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Image.asset(actu['image']!, width: 48, height: 48),
                title: Text(actu['titre']!, style: TextStyle(color: Colors.white)),
                subtitle: Text(actu['jeu']!, style: TextStyle(color: Colors.grey)),
                trailing: Icon(Icons.chevron_right, color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}
