import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/design_system.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class TrophiesPage extends StatefulWidget {
  const TrophiesPage({super.key});

  @override
  State<TrophiesPage> createState() => _TrophiesPageState();
}

class _TrophiesPageState extends State<TrophiesPage> {
  final List<Map<String, dynamic>> _sampleTrophies = [
    {
      'nom_badge': 'Maître du Battle Royale',
      'description': 'Atteindre le top 1 dans un tournoi public.',
      'jeu': 'Fortnite',
      'etat': 'Obtenu',
    },
    {
      'nom_badge': 'Champion du Clan',
      'description': 'Gagner 10 matchs d’équipe consécutifs.',
      'jeu': 'League of Legends',
      'etat': 'Obtenu',
    },
    {
      'nom_badge': 'Collectionneur Légendaire',
      'description': 'Débloquer 50 objets rares dans le jeu.',
      'jeu': 'Apex Legends',
      'etat': 'Obtenu',
    },
  ];

  List<dynamic> _trophies = [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTrophies();
  }

  Future<void> _loadTrophies() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final userId = await AuthService.getUserId();
      final badges =
          userId != null ? await ApiService.getUserBadges(userId) : <dynamic>[];

      if (mounted) {
        setState(() {
          _trophies = badges.isNotEmpty ? badges : _sampleTrophies;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Impossible de charger les trophées.';
          _trophies = _sampleTrophies;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('TROPHÉES', style: AppStyles.heading.copyWith(fontSize: 18)),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: _loadTrophies,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: _buildContent(),
              ),
      ),
    );
  }

  Widget _buildContent() {
    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!, style: AppStyles.subHeading),
      );
    }

    if (_trophies.isEmpty) {
      return Center(
        child: Text('Aucun trophée trouvé pour le moment.',
            style: AppStyles.subHeading),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: _trophies.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final trophy = _trophies[index] as Map<String, dynamic>;
        return _buildTrophyCard(trophy, index);
      },
    );
  }

  Widget _buildTrophyCard(Map<String, dynamic> trophy, int index) {
    final colors = [
      AppColors.goldGradient,
      AppColors.primaryGradient,
      AppColors.cyanGradient,
    ];
    final gradient = colors[index % colors.length];
    final title = trophy['nom_badge']?.toString() ??
        trophy['titre']?.toString() ??
        'Trophée inconnu';
    final description = trophy['description']?.toString() ??
        'Trophée débloqué dans votre profil.';
    final game = trophy['jeu']?.toString() ??
        trophy['categorie']?.toString() ??
        'GAMING';
    final status = trophy['etat']?.toString() ?? 'Débloqué';

    return Container(
      decoration: AppStyles.cardDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(gradient: gradient),
              child: Stack(
                children: [
                  Center(
                    child: Icon(Icons.emoji_events_rounded,
                        color: Colors.white.withOpacity(0.12), size: 96),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppWidgets.badge(status.toUpperCase(), Colors.white),
                        const SizedBox(height: 10),
                        Text(title,
                            style: AppStyles.heading
                                .copyWith(fontSize: 18, color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.videogame_asset_rounded,
                          color: AppColors.accent, size: 16),
                      const SizedBox(width: 8),
                      Text(game,
                          style: AppStyles.subHeading.copyWith(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(description,
                      style: AppStyles.body.copyWith(fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.gold, size: 16),
                      const SizedBox(width: 8),
                      Text('Trophée utilisateur',
                          style: AppStyles.subHeading.copyWith(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 80 * index))
        .slideY(begin: 0.1);
  }
}
