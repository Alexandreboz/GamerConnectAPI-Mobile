import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class DiscussionGroupePage extends StatefulWidget {
  final int idGroupe;

  DiscussionGroupePage({required this.idGroupe});

  @override
  _DiscussionGroupePageState createState() => _DiscussionGroupePageState();
}

class _DiscussionGroupePageState extends State<DiscussionGroupePage> {
  List messages = [];
  List membres = [];
  TextEditingController messageController = TextEditingController();
  io.Socket? socket;
  int? idUtilisateur;

  @override
  void initState() {
    super.initState();
    _initUserAndSocket();
    _fetchMessages();
    _fetchMembres();
  }

  Future<void> _initUserAndSocket() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    idUtilisateur = prefs.getInt('id_utilisateur');

    socket = io.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();

    socket!.onConnect((_) {
      print('🔌 Connecté au WebSocket');
      socket!.emit('joinGroup', widget.idGroupe);
    });

    socket!.on('newMessage', (data) {
      if (data['id_groupe'] == widget.idGroupe) {
        setState(() {
          messages.add(data);
        });
      }
    });

    socket!.onDisconnect((_) => print('🛑 Déconnecté du WebSocket'));
  }

  Future<void> _fetchMessages() async {
    final apiUrl = 'http://localhost:3000/groupes/${widget.idGroupe}/messages';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          messages = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print("❌ Erreur chargement messages : $e");
    }
  }

  Future<void> _fetchMembres() async {
    final apiUrl = 'http://localhost:3000/groupes/${widget.idGroupe}/membres';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          membres = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print("❌ Erreur chargement membres : $e");
    }
  }

  Future<void> _envoyerMessage() async {
    if (messageController.text.trim().isEmpty || idUtilisateur == null) return;

    final apiUrl = 'http://localhost:3000/messages';
    final messageText = messageController.text.trim();

    final body = {
      "id_utilisateur": idUtilisateur,
      "id_groupe": widget.idGroupe,
      "contenu": messageText,
    };

    print("📨 Contenu du message envoyé : $messageText");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final messageEnvoye = jsonDecode(response.body);

        setState(() {
          messages.add(messageEnvoye);
        });

        socket?.emit('newMessage', messageEnvoye);
        messageController.clear();

        print("✅ Message envoyé avec succès");
      } else {
        print("❌ Échec de l'envoi du message : ${response.body}");
      }
    } catch (e) {
      print("❌ Exception lors de l'envoi du message : $e");
    }
  }

  @override
  void dispose() {
    socket?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Discussion"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Color(0xFF0F0B1E),
      body: Column(
        children: [
          Container(
            color: Colors.black54,
            padding: EdgeInsets.all(12),
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              children: membres.map((m) {
                return Chip(
                  label: Text(
                    "${m['prenom']} ${m['nom']}",
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.grey[700],
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: msg['id_utilisateur'] == idUtilisateur
                        ? Colors.blueAccent
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    msg['contenu'],
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Écrire un message...",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _envoyerMessage,
                  icon: Icon(Icons.send, color: Colors.blueAccent),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
