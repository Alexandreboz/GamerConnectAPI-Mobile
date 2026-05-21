import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/design_system.dart';

class JoueursPage extends StatefulWidget {
  const JoueursPage({super.key});

  @override
  State<JoueursPage> createState() => _JoueursPageState();
}

class _JoueursPageState extends State<JoueursPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _players = [];
  List<dynamic> _filteredPlayers = [];
  bool _loading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
    _searchController.addListener(_updateFilter);
  }

  Future<void> _loadPlayers() async {
    _currentUserId = await AuthService.getUserId();
    try {
      final data = await ApiService.getUsers();
      final players = data.where((user) {
        return user['id_utilisateur'] != _currentUserId;
      }).toList();
      if (mounted) {
        setState(() {
          _players = players;
          _filteredPlayers = List.from(players);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _players = [];
          _filteredPlayers = [];
          _loading = false;
        });
      }
    }
  }

  void _updateFilter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredPlayers = query.isEmpty
          ? List.from(_players)
          : _players.where((player) {
              final pseudo = (player['pseudo'] ?? '').toString().toLowerCase();
              final prenom = (player['prenom'] ?? '').toString().toLowerCase();
              final nom = (player['nom'] ?? '').toString().toLowerCase();
              final email = (player['email'] ?? '').toString().toLowerCase();
              return pseudo.contains(query) ||
                  prenom.contains(query) ||
                  nom.contains(query) ||
                  email.contains(query);
            }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_updateFilter);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recherche de joueurs',
            style: AppStyles.heading.copyWith(fontSize: 18)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Rechercher un joueur...',
                  hintStyle: AppStyles.subHeading,
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.primary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: Colors.grey, size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: _loadPlayers,
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary))
                  : _filteredPlayers.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.search_off_rounded,
                                    color: Colors.grey, size: 60),
                                const SizedBox(height: 12),
                                Text('Aucun joueur trouvé',
                                    style: AppStyles.subHeading),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          itemCount: _filteredPlayers.length,
                          itemBuilder: (_, index) =>
                              _playerCard(_filteredPlayers[index], index),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _playerCard(dynamic player, int index) {
    final pseudo = player['pseudo'] ?? 'Joueur';
    final prenom = player['prenom'] ?? '';
    final nom = player['nom'] ?? '';
    final email = player['email'] ?? '';
    final fullname = [prenom, nom].where((p) => p.isNotEmpty).join(' ').trim();

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Profil de $pseudo sélectionné'),
              duration: const Duration(seconds: 1)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: AppStyles.cardDecoration,
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  pseudo.isNotEmpty ? pseudo[0].toUpperCase() : 'J',
                  style: AppStyles.heading
                      .copyWith(fontSize: 20, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pseudo,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    fullname.isNotEmpty ? fullname : 'Pseudo only',
                    style: AppStyles.subHeading.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(email,
                        style: AppStyles.subHeading
                            .copyWith(fontSize: 11, color: Colors.grey)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Voir',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8)),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: Duration(milliseconds: 80 * index))
          .slideX(begin: 0.1),
    );
  }
}
