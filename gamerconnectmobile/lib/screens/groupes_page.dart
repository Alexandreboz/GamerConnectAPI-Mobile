import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'discussion_groupe_page.dart';

class GroupesPage extends StatefulWidget {
  @override
  _GroupesPageState createState() => _GroupesPageState();
}

class _GroupesPageState extends State<GroupesPage> {
  List<dynamic> groupes = [];
  bool isLoading = true;
  int? idUtilisateur;

  @override
  void initState() {
    super.initState();
    _initAndFetch();
  }

  Future<void> _initAndFetch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    idUtilisateur = prefs.getInt('id_utilisateur');
    print("🧑 ID utilisateur connecté : $idUtilisateur");
    await _fetchGroupes();
  }

  Future<void> _fetchGroupes() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/groupes'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            groupes = data;
            isLoading = false;
          });
        }
      } else {
        print("❌ Erreur API groupes : ${response.statusCode}");
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      print("❌ Exception lors du chargement des groupes : $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _rejoindreGroupe(int idGroupe) async {
    if (idUtilisateur == null) return;

    final membresUrl = Uri.parse('http://localhost:3000/groupes/$idGroupe/membres');
    try {
      final membresResponse = await http.get(membresUrl);

      if (membresResponse.statusCode == 200) {
        final List membres = json.decode(membresResponse.body);
        final bool dejaMembre = membres.any((m) => m['id_utilisateur'] == idUtilisateur);

        if (dejaMembre) {
          print("ℹ️ L'utilisateur est déjà membre du groupe.");
        } else {
          final url = Uri.parse('http://localhost:3000/groupes/$idGroupe/rejoindre');
          final response = await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'id_utilisateur': idUtilisateur}),
          );

          if (response.statusCode == 201 || response.statusCode == 200) {
            print("✅ Ajout utilisateur au groupe");
          } else {
            print("❌ Erreur lors de l'ajout au groupe : ${response.body}");
          }
        }

        // Naviguer vers la discussion même si déjà membre
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiscussionGroupePage(idGroupe: idGroupe),
            ),
          );
        }
      } else {
        print("❌ Erreur récupération membres : ${membresResponse.statusCode}");
      }
    } catch (e) {
      print("❌ Exception rejoindreGroupe : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Groupes")),
      backgroundColor: Color(0xFF1E1E1E),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: groupes.length,
              itemBuilder: (context, index) {
                final groupe = groupes[index];
                return Card(
                  color: Color(0xFF292929),
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(
                      groupe['nom_groupe'],
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      groupe['description'] ?? '',
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                    onTap: () => _rejoindreGroupe(groupe['id_groupe']),
                  ),
                );
              },
            ),
    );
  }
}
