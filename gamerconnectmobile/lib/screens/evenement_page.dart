import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/design_system.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class EvenementPage extends StatefulWidget {
  @override
  _EvenementPageState createState() => _EvenementPageState();
}

class _EvenementPageState extends State<EvenementPage> {
  List _events = [];
  bool _loading = true;
  int? _userId;
  final Set<int> _joined = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final userId = await AuthService.getUserId();
      final data = await ApiService.getEvenements();
      final joinedEvents =
          userId != null ? await ApiService.getEvenementsInscrits(userId) : [];
      final joinedIds = joinedEvents
          .where((item) => item != null)
          .map<int>((item) {
            if (item is int) return item;
            if (item is Map && item['id_evenement'] != null) {
              return item['id_evenement'] as int;
            }
            return 0;
          })
          .where((id) => id > 0)
          .toSet();
      if (mounted) {
        setState(() {
          _userId = userId;
          _events = data;
          _joined
            ..clear()
            ..addAll(joinedIds);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GAMING EVENTS",
            style: AppStyles.heading.copyWith(fontSize: 18)),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: _load,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : _events.isEmpty
                ? Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        const Icon(Icons.event_busy_rounded,
                            color: Colors.grey, size: 64),
                        const SizedBox(height: 16),
                        Text("Aucun événement disponible",
                            style: AppStyles.subHeading),
                        const SizedBox(height: 8),
                        Text("Reviens plus tard 🎮",
                            style: AppStyles.body.copyWith(fontSize: 12)),
                      ]))
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    itemCount: _events.length,
                    itemBuilder: (_, i) => _card(_events[i], i),
                  ),
      ),
    );
  }

  Widget _card(dynamic e, int index) {
    final id = e['id_evenement'] ?? index;
    final joined = _joined.contains(id);
    final colors = [
      AppColors.primaryGradient,
      AppColors.cyanGradient,
      AppColors.accentGradient
    ];
    final grad = colors[index % colors.length];
    final date = (e['date_evenement'] ?? '').toString();
    final shortDate = date.length >= 10 ? date.substring(0, 10) : date;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: AppStyles.cardDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              height: 130,
              decoration: BoxDecoration(gradient: grad),
              child: Stack(
                children: [
                  Center(
                      child: Icon(Icons.event_available_rounded,
                          color: Colors.white.withOpacity(0.15), size: 100)),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppWidgets.badge(joined ? "✓ INSCRIT" : "UPCOMING",
                            joined ? AppColors.green : Colors.white),
                        const SizedBox(height: 8),
                        Text(
                          e['nom_evenement'] ?? 'Événement',
                          style: AppStyles.heading
                              .copyWith(fontSize: 18, color: Colors.white),
                        ),
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
                  Text(
                    e['description'] ??
                        'Rejoins cet événement pour en savoir plus.',
                    style: AppStyles.body.copyWith(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: AppColors.primary, size: 15),
                      const SizedBox(width: 6),
                      Text(shortDate,
                          style: AppStyles.subHeading.copyWith(fontSize: 12)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          if (_userId == null) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text(
                                  'Connecte-toi pour t’inscrire aux événements'),
                              backgroundColor: Color(0xFFEF5350),
                            ));
                            return;
                          }
                          final nextJoined = !joined;
                          final success = await ApiService.participerEvenement(
                              id, _userId!,
                              join: nextJoined);
                          if (!mounted) return;
                          if (success) {
                            setState(() {
                              if (nextJoined) {
                                _joined.add(id);
                              } else {
                                _joined.remove(id);
                              }
                            });
                          }
                          final snackMessage = success
                              ? (nextJoined
                                  ? "Tu es inscrit ! À bientôt 🎮"
                                  : "Tu t'es désinscrit de l'événement")
                              : "Erreur lors de l'inscription";
                          final snackColor = success
                              ? (nextJoined
                                  ? AppColors.green
                                  : AppColors.accent)
                              : AppColors.accent;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(snackMessage),
                            backgroundColor: snackColor,
                          ));
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: joined ? null : AppColors.primaryGradient,
                            color:
                                joined ? Colors.green.withOpacity(0.15) : null,
                            borderRadius: BorderRadius.circular(12),
                            border: joined
                                ? Border.all(color: AppColors.green)
                                : null,
                          ),
                          child: Text(
                            joined ? "✓ INSCRIT" : "S'INSCRIRE",
                            style: TextStyle(
                              color: joined ? AppColors.green : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
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
