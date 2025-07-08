import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController pseudoController = TextEditingController();
  final TextEditingController mdpController = TextEditingController();

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _login() async {
    final pseudo = pseudoController.text.trim();
    final mdp = mdpController.text.trim();

    if (pseudo.isEmpty || mdp.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    final hashedPassword = hashPassword(mdp);
    final apiUrl = 'http://localhost:3000/users'; // adapte selon ton environnement

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final List users = jsonDecode(response.body);
        final user = users.firstWhere(
          (u) => u['pseudo'] == pseudo && u['mot_de_passe'] == hashedPassword,
          orElse: () => null,
        );

        if (user != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('id_utilisateur', user['id_utilisateur']);

          // Log terminal
          print("Connexion réussie. Utilisateur : $user");

          if (!mounted) return;
          Future.microtask(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          });
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Identifiants invalides")),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de récupération des utilisateurs")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de connexion à l'API")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black, title: Text("GamerConnect")),
      backgroundColor: Color(0xFF1E1E1E),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "SE CONNECTER",
              style: TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _buildField("Pseudo", pseudoController),
            _buildField("Mot de passe", mdpController, obscure: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF3B5AFE)),
              child: Text("Se connecter"),
            ),
            SizedBox(height: 10),
            Text(
              "J'ai besoin d'aide pour me connecter",
              style: TextStyle(color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              "C'est gratuit et facile...",
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool obscure = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[300]),
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
