import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/design_system.dart';
import '../services/api_service.dart';
import 'discussion_forum_page.dart';
import 'forum_admin_page.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  bool _loading = true;
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

  Future<void> _showCreateForumDialog() async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController jeuController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    bool saving = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text('Créer un forum',
                  style: AppStyles.heading.copyWith(fontSize: 18)),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: jeuController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Jeu',
                          labelStyle: AppStyles.subHeading,
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
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
                        controller: descriptionController,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: AppStyles.subHeading,
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          setState(() => saving = true);
                          final result = await ApiService.createForum(
                            jeuController.text.trim(),
                            descriptionController.text.trim(),
                          );
                          setState(() => saving = false);
                          if (result['success'] == true) {
                            await _loadForums();
                            if (!mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text('Forum créé avec succès'),
                                backgroundColor: AppColors.green,
                              ),
                            );
                          } else {
                            final errorMessage = result['error']?.toString() ??
                                'Impossible de créer le forum';
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                backgroundColor: AppColors.accent,
                              ),
                            );
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Créer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Forum', style: AppStyles.heading.copyWith(fontSize: 18)),
            Text('Choisis un jeu pour rejoindre la discussion',
                style: AppStyles.subHeading.copyWith(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Colors.white),
            tooltip: 'Créer un forum',
            onPressed: _showCreateForumDialog,
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined,
                color: Colors.white),
            tooltip: 'Gérer les forums',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForumAdminPage()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadForums,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : _forums.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 120),
                      Icon(Icons.forum_rounded,
                          size: 80, color: Colors.grey[500]),
                      const SizedBox(height: 20),
                      Center(
                        child: Text('Aucun forum disponible',
                            style: AppStyles.subHeading),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _forums.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, index) {
                      final forum = _forums[index] as Map<String, dynamic>;
                      return _forumCard(forum, index);
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateForumDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _forumCard(Map<String, dynamic> forum, int index) {
    final title = forum['jeu']?.toString() ?? 'Jeu inconnu';
    final description = forum['description']?.toString() ?? '';
    final messageCount = forum['message_count'] is int
        ? forum['message_count'] as int
        : int.tryParse(forum['message_count']?.toString() ?? '0') ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DiscussionForumPage(
              forumId: forum['id_forum'] as int,
              gameName: title,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppStyles.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary.withOpacity(0.18),
                  child: Text(title.isNotEmpty ? title[0].toUpperCase() : 'J',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: AppStyles.heading
                              .copyWith(fontSize: 16, letterSpacing: 1.1)),
                      const SizedBox(height: 4),
                      Text(description,
                          style: AppStyles.body.copyWith(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                AppWidgets.badge('$messageCount messages', AppColors.secondary),
                const SizedBox(width: 8),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.grey, size: 18),
              ],
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: Duration(milliseconds: 100 + index * 40))
          .slideY(begin: 0.1),
    );
  }
}
