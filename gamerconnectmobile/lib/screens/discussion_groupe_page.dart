import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../theme/design_system.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class DiscussionGroupePage extends StatefulWidget {
  final int idGroupe;
  final String? nomGroupe;

  const DiscussionGroupePage({required this.idGroupe, this.nomGroupe});

  @override
  _DiscussionGroupePageState createState() => _DiscussionGroupePageState();
}

class _DiscussionGroupePageState extends State<DiscussionGroupePage> {
  List messages = [];
  List membres = [];
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  io.Socket? socket;
  int? _userId;
  String _pseudo = '';
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _userId = await AuthService.getUserId();
    _pseudo = await AuthService.getPseudo();
    await _fetchMessages();
    await _fetchMembres();
    _connectSocket();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _fetchMessages() async {
    final data = await ApiService.getMessagesGroupe(widget.idGroupe);
    if (mounted) {
      setState(() => messages = data);
      _scrollBottom();
    }
  }

  Future<void> _fetchMembres() async {
    final data = await ApiService.getMembresGroupe(widget.idGroupe);
    if (mounted) setState(() => membres = data);
  }

  void _connectSocket() {
    socket = io.io('http://localhost:3005', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket!.connect();
    socket!.onConnect((_) => socket!.emit('joinGroup', widget.idGroupe));
    socket!.on('newMessage', (data) {
      if (mounted && data['id_groupe'] == widget.idGroupe) {
        setState(() => messages.add(data));
        _scrollBottom();
      }
    });
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _userId == null || _sending) return;
    setState(() => _sending = true);
    _msgCtrl.clear();
    try {
      final msg = await ApiService.sendMessage(_userId!, widget.idGroupe, text);
      if (msg != null && mounted) {
        // Server emit via WebSocket will add to list; but add locally as fallback
        final already = messages.any((m) => m['id_message'] == msg['id_message']);
        if (!already) setState(() => messages.add(msg));
        _scrollBottom();
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    socket?.disconnect();
    _scrollCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: Column(
          children: [
            Text(widget.nomGroupe ?? "DISCUSSION", style: AppStyles.heading.copyWith(fontSize: 16)),
            Text("${membres.length} membre${membres.length != 1 ? 's' : ''}",
                style: AppStyles.subHeading.copyWith(fontSize: 10, color: AppColors.secondary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline_rounded, color: Colors.white),
            onPressed: _showMembres,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                const Divider(height: 1, color: AppColors.glassWhite),
                _membresAvatarBar(),
                Expanded(
                  child: messages.isEmpty
                      ? _emptyState()
                      : ListView.builder(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          itemCount: messages.length,
                          itemBuilder: (_, i) => _bubble(messages[i]),
                        ),
                ),
                _inputBar(),
              ],
            ),
    );
  }

  Widget _membresAvatarBar() {
    return Container(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: membres.length,
        itemBuilder: (_, i) {
          final m = membres[i];
          final name = m['pseudo'] ?? m['prenom'] ?? '?';
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Tooltip(
              message: name,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: Text(name[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                  Positioned(right: 0, bottom: 0, child: AppWidgets.onlineDot(online: i % 3 != 0)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline_rounded, color: Colors.grey, size: 60),
          const SizedBox(height: 16),
          Text("Sois le premier à écrire !", style: AppStyles.subHeading),
          const SizedBox(height: 8),
          Text("Lance la conversation 🎮", style: AppStyles.body.copyWith(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _bubble(dynamic msg) {
    final isMe = msg['id_utilisateur'] == _userId;
    final name = msg['pseudo'] ?? 'User';
    final content = msg['contenu'] ?? '';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe) Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Text(name, style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isMe ? AppColors.primaryGradient : null,
                color: isMe ? null : AppColors.surfaceElevated,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 2),
                  bottomRight: Radius.circular(isMe ? 2 : 18),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Text(content, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
            ),
          ],
        ),
      ).animate().fadeIn(duration: const Duration(milliseconds: 200)).slideY(begin: 0.1),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + MediaQuery.of(context).padding.bottom),
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
                controller: _msgCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: "Écris un message...",
                  hintStyle: AppStyles.subHeading,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey, size: 20),
                    onPressed: () {},
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sending ? null : _send,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                gradient: _sending ? null : AppColors.primaryGradient,
                color: _sending ? Colors.grey.withOpacity(0.3) : null,
                shape: BoxShape.circle,
                boxShadow: _sending ? null : [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 10)],
              ),
              child: _sending
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showMembres() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Membres (${membres.length})", style: AppStyles.heading.copyWith(fontSize: 16)),
            const SizedBox(height: 16),
            ...membres.map((m) {
              final name = m['pseudo'] ?? '${m['prenom']} ${m['nom']}';
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  child: Text(name[0].toUpperCase(), style: const TextStyle(color: AppColors.primary)),
                ),
                title: Text(name, style: const TextStyle(color: Colors.white)),
                trailing: AppWidgets.onlineDot(),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
