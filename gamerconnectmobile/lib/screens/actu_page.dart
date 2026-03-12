import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/design_system.dart';
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
      'titre': 'Monster Hunter - Iceborne Promo',
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
        title: Text('GAMING NEWS', style: AppStyles.heading.copyWith(fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(12),
              decoration: AppStyles.cardDecoration,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(actu['image']!, width: 70, height: 70, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          actu['jeu']!.toUpperCase(),
                          style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          actu['titre']!,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
                ],
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.1),
          );
        },
      ),
    );
  }
}
