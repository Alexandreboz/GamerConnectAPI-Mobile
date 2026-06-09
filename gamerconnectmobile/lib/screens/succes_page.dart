import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/design_system.dart';
import '../services/api_service.dart';

class SuccesPage extends StatefulWidget {
  const SuccesPage({super.key});

  @override
  State<SuccesPage> createState() => _SuccesPageState();
}

class _SuccesPageState extends State<SuccesPage> {
  late Future<List<dynamic>> _succesFuture;

  final List<Map<String, String>> _fallbackSucces = [
    {
      'jeu': 'Dofus',
      'titre': 'Maître des familiers',
      'description': 'Atteindre le niveau maximum d’un familier.'
    },
    {
      'jeu': 'Pokémon',
      'titre': 'Dresseur Élite',
      'description': 'Battre la Ligue Pokémon sans perdre un seul combat.'
    },
    {
      'jeu': 'Monster Hunter',
      'titre': 'Chasseur de légende',
      'description': 'Terrasser un dragon ancien en solo.'
    },
    {
      'jeu': 'FIFA',
      'titre': 'Champion FUT',
      'description': 'Gagner 5 matchs consécutifs en mode FUT.'
    },
    {
      'jeu': 'Pokémon',
      'titre': 'Collectionneur',
      'description': 'Attraper 100 Pokémon différents.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _succesFuture = ApiService.getSucces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ACHIEVEMENTS',
            style: AppStyles.heading.copyWith(fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _succesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          final hasError = snapshot.hasError;
          final succes = snapshot.data ?? [];
          final results = hasError || succes.isEmpty ? _fallbackSucces : succes;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final item = results[index] as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: AppStyles.cardDecoration,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.emoji_events_rounded,
                          color: Colors.amber, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['jeu']?.toString().toUpperCase() ?? '',
                            style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1),
                          ),
                          const SizedBox(height: 4),
                          Text(item['titre']?.toString() ?? '',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(item['description']?.toString() ?? '',
                              style:
                                  AppStyles.subHeading.copyWith(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 100 * index))
                  .slideY(begin: 0.2);
            },
          );
        },
      ),
    );
  }
}
