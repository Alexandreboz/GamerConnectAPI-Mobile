import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/design_system.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'discussion_groupe_page.dart';

class GroupesPage extends StatefulWidget {
  @override
  _GroupesPageState createState() => _GroupesPageState();
}

class _GroupesPageState extends State<GroupesPage> {
  List<dynamic> _groupes = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  int? _userId;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(() {
      final q = _search.text.toLowerCase();
      setState(() {
        _filtered = q.isEmpty
            ? List.from(_groupes)
            : _groupes.where((g) => (g['nom_groupe'] ?? '').toLowerCase().contains(q)).toList();
      });
    });
  }

  Future<void> _load() async {
    _userId = await AuthService.getUserId();
    try {
      final data = await ApiService.getGroupes();
      if (mounted) setState(() { _groupes = data; _filtered = List.from(data); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _join(Map<String, dynamic> groupe) async {
    if (_userId == null) return;
    final id = groupe['id_groupe'] as int;
    try {
      await ApiService.rejoindreGroupe(id, _userId!);
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => DiscussionGroupePage(idGroupe: id, nomGroupe: groupe['nom_groupe']),
        ));
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur de connexion")));
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GAMING GROUPS", style: AppStyles.heading.copyWith(fontSize: 18)),
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
                controller: _search,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Recherche un groupe...",
                  hintStyle: AppStyles.subHeading,
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  suffixIcon: _search.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear, color: Colors.grey, size: 18), onPressed: () => _search.clear())
                      : null,
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: _load,
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _filtered.isEmpty
                      ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.search_off_rounded, color: Colors.grey, size: 60),
                          const SizedBox(height: 12),
                          Text("Aucun groupe trouvé", style: AppStyles.subHeading),
                        ]))
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) => _groupCard(_filtered[i], i),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupCard(dynamic groupe, int index) {
    final name = groupe['nom_groupe'] ?? 'Groupe';
    final desc = groupe['description'] ?? 'Rejoins la discussion !';
    final colors = [AppColors.primary, AppColors.secondary, AppColors.orange, AppColors.accent];
    final color = colors[index % colors.length];
    return GestureDetector(
      onTap: () => _join(groupe),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: AppStyles.glowDecoration(color),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color.withOpacity(0.3), color.withOpacity(0.05)]),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(name[0].toUpperCase(),
                    style: AppStyles.heading.copyWith(fontSize: 20, color: color)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(desc, style: AppStyles.subHeading.copyWith(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
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
              child: const Text("REJOINDRE", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
            ),
          ],
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: 80 * index)).slideX(begin: 0.1),
    );
  }
}
