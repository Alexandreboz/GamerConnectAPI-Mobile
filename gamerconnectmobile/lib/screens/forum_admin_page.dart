import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/design_system.dart';
import '../services/api_service.dart';
import 'discussion_forum_page.dart';

class ForumAdminPage extends StatefulWidget {
  const ForumAdminPage({super.key});

  @override
  State<ForumAdminPage> createState() => _ForumAdminPageState();
}

class _ForumAdminPageState extends State<ForumAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _jeuController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  List<dynamic> _forums = [];

  @override
  void initState() {
    super.initState();
    _loadForums();
  }

  Future<void> _loadForums() async {
    setState(() => _loading = true);
    try {
      final forums = await ApiService.getForums();
      if (!mounted) return;
      setState(() {
        _forums = forums;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _forums = [];
        _loading = false;
      });
    }
  }

  Future<void> _createForum() async {
    if (!_formKey.currentState!.validate()) return;
    final jeu = _jeuController.text.trim();
    final description = _descriptionController.text.trim();

    setState(() => _saving = true);
    final result = await ApiService.createForum(jeu, description);
    if (mounted) {
      setState(() => _saving = false);
      if (result['success'] == true) {
        _jeuController.clear();
        _descriptionController.clear();
        await _loadForums();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Forum créé avec succès'),
          backgroundColor: AppColors.green,
        ));
      } else {
        final errorMessage =
            result['error']?.toString() ?? 'Impossible de créer le forum';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.accent,
        ));
      }
    }
  }

  Future<void> _deleteForum(int forumId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Supprimer le forum'),
        content: const Text(
            'Voulez-vous vraiment supprimer ce forum et ses messages ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer')),
        ],
      ),
    );

    if (confirmed != true) return;
    final deleted = await ApiService.deleteForum(forumId);
    if (deleted) {
      await _loadForums();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Forum supprimé'),
        backgroundColor: AppColors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Impossible de supprimer le forum'),
        backgroundColor: AppColors.accent,
      ));
    }
  }

  @override
  void dispose() {
    _jeuController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gestion du forum',
                style: AppStyles.heading.copyWith(fontSize: 18)),
            Text('Créer et gérer les forums de discussion',
                style: AppStyles.subHeading.copyWith(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadForums,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadForums,
        child: ListView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _buildCreateCard(),
            const SizedBox(height: 20),
            _buildForumsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Créer un nouveau forum',
              style: AppStyles.heading.copyWith(fontSize: 16)),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _jeuController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Jeu',
                    labelStyle: AppStyles.subHeading,
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le nom du jeu est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: AppStyles.subHeading,
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _createForum,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Créer le forum'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForumsList() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_forums.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Text('Aucun forum trouvé.', style: AppStyles.subHeading),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Forums existants',
            style: AppStyles.heading.copyWith(fontSize: 16)),
        const SizedBox(height: 12),
        ..._forums.asMap().entries.map((entry) {
          final index = entry.key;
          final forum = entry.value as Map<String, dynamic>;
          return Container(
            margin:
                EdgeInsets.only(bottom: index == _forums.length - 1 ? 0 : 12),
            decoration: AppStyles.cardDecoration,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Text(forum['jeu']?.toString() ?? 'Forum',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(forum['description']?.toString() ?? '',
                  style: AppStyles.subHeading),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined,
                        color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DiscussionForumPage(
                            forumId: forum['id_forum'] as int,
                            gameName: forum['jeu']?.toString() ?? 'Forum',
                            adminMode: true,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.accent),
                    onPressed: () => _deleteForum(forum['id_forum'] as int),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 80 * index));
        }).toList(),
      ],
    );
  }
}
