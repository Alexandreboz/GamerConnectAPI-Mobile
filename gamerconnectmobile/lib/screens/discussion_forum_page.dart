import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/design_system.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class DiscussionForumPage extends StatefulWidget {
  final int forumId;
  final String gameName;
  final bool adminMode;

  const DiscussionForumPage({
    required this.forumId,
    required this.gameName,
    this.adminMode = false,
    super.key,
  });

  @override
  State<DiscussionForumPage> createState() => _DiscussionForumPageState();
}

class _DiscussionForumPageState extends State<DiscussionForumPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _messages = [];
  bool _loading = true;
  bool _sending = false;
  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _init();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _init() async {
    _userId = await AuthService.getUserId();
    await _loadMessages(refresh: true);
  }

  Future<void> _loadMessages({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    try {
      final messages = await ApiService.getForumMessages(widget.forumId,
          page: _page, limit: _limit);
      if (!mounted) return;

      setState(() {
        if (refresh) {
          _messages = messages;
        } else {
          _messages.addAll(messages);
        }
        _loading = false;
        _hasMore = messages.length == _limit;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 80 &&
        _hasMore) {
      _page += 1;
      _loadMessages();
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _userId == null || _sending) return;

    setState(() => _sending = true);
    _messageController.clear();
    try {
      final newMessage =
          await ApiService.createForumMessage(_userId!, widget.forumId, text);
      if (!mounted) return;
      setState(() {
        _messages.insert(0, newMessage);
      });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _deleteMessage(int messageId) async {
    if (_userId == null) return;
    final deleted = await ApiService.deleteForumMessage(
      messageId,
      _userId!,
      asAdmin: widget.adminMode,
    );
    if (deleted) {
      setState(() {
        _messages.removeWhere((message) => message['id_message'] == messageId);
      });
    }
  }

  String _formatDate(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return timestamp;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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
            Text(widget.gameName,
                style: AppStyles.heading.copyWith(fontSize: 18)),
            Text('Discussions du jeu',
                style: AppStyles.subHeading.copyWith(fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => _loadMessages(refresh: true),
                    child: _messages.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 120),
                              Icon(Icons.forum_outlined,
                                  size: 80, color: Colors.grey[500]),
                              const SizedBox(height: 20),
                              Center(
                                child: Text('Aucun message pour le moment',
                                    style: AppStyles.subHeading),
                              ),
                            ],
                          )
                        : ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length + (_hasMore ? 1 : 0),
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              if (_hasMore && index == _messages.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          color: AppColors.primary)),
                                );
                              }
                              final message =
                                  _messages[index] as Map<String, dynamic>;
                              return _messageCard(message);
                            },
                          ),
                  ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _messageCard(Map<String, dynamic> message) {
    final isMe = message['id_utilisateur'] == _userId;
    final author = message['pseudo']?.toString() ??
        '${message['prenom'] ?? ''} ${message['nom'] ?? ''}'.trim();
    final createdAt = _formatDate(message['date_creation']?.toString());
    final content = message['contenu']?.toString() ?? '';

    return Container(
      decoration: AppStyles.cardDecoration,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Text(
                  author.isNotEmpty ? author[0].toUpperCase() : 'U',
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(author.isNotEmpty ? author : 'Utilisateur',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(createdAt,
                        style: AppStyles.subHeading.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              if (isMe || widget.adminMode)
                IconButton(
                  onPressed: () async {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: const Text('Supprimer le message'),
                        content:
                            const Text('Voulez-vous supprimer ce message ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Supprimer'),
                          ),
                        ],
                      ),
                    );
                    if (shouldDelete == true) {
                      await _deleteMessage(message['id_message'] as int);
                    }
                  },
                  icon:
                      const Icon(Icons.delete_outline, color: AppColors.accent),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(content, style: AppStyles.body.copyWith(fontSize: 14)),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 180))
        .slideY(begin: 0.1);
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: _userId == null
                      ? 'Connectez-vous pour écrire'
                      : 'Écrire un message...',
                  hintStyle: AppStyles.subHeading,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
                enabled: _userId != null,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _userId == null || _sending ? null : _sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _userId == null || _sending
                    ? null
                    : AppColors.primaryGradient,
                color: _userId == null || _sending
                    ? Colors.grey.withOpacity(0.3)
                    : null,
              ),
              child: _sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
