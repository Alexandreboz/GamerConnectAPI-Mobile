import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/design_system.dart';

class EvenementDetailPage extends StatefulWidget {
  final Map<String, dynamic> event;
  final bool initialJoined;

  const EvenementDetailPage(
      {super.key, required this.event, this.initialJoined = false});

  @override
  State<EvenementDetailPage> createState() => _EvenementDetailPageState();
}

class _EvenementDetailPageState extends State<EvenementDetailPage> {
  late bool _joined;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _joined = widget.initialJoined;
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userId = await AuthService.getUserId();
    if (mounted) {
      setState(() {
        _userId = userId;
      });
    }
  }

  bool get _isApiEvent =>
      widget.event['id_evenement'] is int && widget.event['id_evenement'] > 0;
  int? get _eventId => _isApiEvent ? widget.event['id_evenement'] as int : null;

  String get _name => widget.event['nom_evenement']?.toString() ?? 'Événement';
  String get _description => widget.event['description']?.toString() ?? '';
  String get _game => widget.event['jeu']?.toString() ?? 'Jeu inconnu';
  String get _location =>
      widget.event['lieu']?.toString() ?? 'Lieu non précisé';
  String get _dateString => widget.event['date_evenement']?.toString() ?? '';
  String get _participantsLabel =>
      '${widget.event['participants'] ?? 0} participants';

  void _updateParticipants(int delta) {
    if (widget.event['participants'] is int) {
      final current = widget.event['participants'] as int;
      widget.event['participants'] = (current + delta).clamp(0, 9999);
    }
  }

  Future<void> _toggleRegistration() async {
    if (!_isApiEvent) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Cet événement ne peut pas être modifié en mode démo.'),
        backgroundColor: AppColors.accent,
      ));
      return;
    }

    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Connecte-toi pour t’inscrire aux événements'),
        backgroundColor: Color(0xFFEF5350),
      ));
      return;
    }

    final nextJoined = !_joined;
    final success = await ApiService.participerEvenement(_eventId!, _userId!,
        join: nextJoined);
    if (!mounted) return;

    if (success) {
      setState(() {
        _joined = nextJoined;
        _updateParticipants(nextJoined ? 1 : -1);
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success
          ? (nextJoined
              ? 'Inscription confirmée !'
              : 'Désinscription enregistrée.')
          : 'Erreur lors de l’action.'),
      backgroundColor: success ? AppColors.green : AppColors.accent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(_dateString);
    final formattedDate = date != null
        ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
        : _dateString;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: const BackButton(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_game.toUpperCase(),
                  style: AppStyles.heading.copyWith(fontSize: 14)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.event_available_rounded,
                      size: 120, color: Colors.white.withOpacity(0.18)),
                ),
              ),
              centerTitle: true,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(_name, style: AppStyles.heading.copyWith(fontSize: 26)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    AppWidgets.badge(_game, AppColors.accent),
                    const SizedBox(width: 10),
                    AppWidgets.badge(_participantsLabel, AppColors.primary),
                  ],
                ),
                const SizedBox(height: 20),
                _detailRow(Icons.calendar_today_rounded, 'Date', formattedDate),
                const SizedBox(height: 12),
                _detailRow(Icons.location_on_rounded, 'Lieu', _location),
                const SizedBox(height: 12),
                _detailRow(Icons.info_outline_rounded, 'Statut',
                    _joined ? 'Inscrit' : 'Ouvert aux inscriptions'),
                const SizedBox(height: 24),
                Text('Description',
                    style: AppStyles.heading.copyWith(fontSize: 18)),
                const SizedBox(height: 12),
                Text(_description, style: AppStyles.body.copyWith(height: 1.6)),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _toggleRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _joined ? AppColors.green : AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    _isApiEvent
                        ? (_joined
                            ? 'SE DÉSINSCRIRE'
                            : 'S’INSCRIRE À CET ÉVÉNEMENT')
                        : 'MODE DÉMO',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ).animate().fadeIn(delay: const Duration(milliseconds: 100)),
                const SizedBox(height: 12),
                if (!_isApiEvent)
                  Text(
                    'Cet événement est un exemple de présentation. L’inscription n’est pas disponible.',
                    style: AppStyles.subHeading
                        .copyWith(fontSize: 12, color: Colors.grey),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: AppStyles.cardDecoration,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppStyles.label
                        .copyWith(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                Text(value, style: AppStyles.subHeading),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
