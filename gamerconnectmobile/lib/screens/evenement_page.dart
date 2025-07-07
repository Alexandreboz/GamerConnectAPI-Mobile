import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EvenementPage extends StatefulWidget {
  @override
  _EvenementPageState createState() => _EvenementPageState();
}

class _EvenementPageState extends State<EvenementPage> {
  List events = [];

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final apiUrl = 'http://localhost:3000/evenements'; // adapte si besoin
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          events = jsonDecode(response.body);
        });
      } else {
        print("Erreur API: ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur de connexion: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Événements GamerConnect"), backgroundColor: Colors.black),
      backgroundColor: Color(0xFF1E1E1E),
      body: events.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final e = events[index];
                return Card(
                  color: Colors.grey[900],
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(e['nom_evenement'], style: TextStyle(color: Colors.white)),
                    subtitle: Text(e['description'] ?? '', style: TextStyle(color: Colors.white70)),
                    trailing: Text(e['date_evenement'].toString(), style: TextStyle(color: Colors.grey)),
                    onTap: () {
                      // ici tu pourrais aller à une page détail
                    },
                  ),
                );
              },
            ),
    );
  }
}
