import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pseudoController = TextEditingController();
  final TextEditingController mdpController = TextEditingController();
  final TextEditingController mdpConfirmController = TextEditingController();
  bool conditionsAccepted = false;

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool isStrongPassword(String mdp) {
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
    return passwordRegex.hasMatch(mdp);
  }

  Future<void> _submitForm() async {
    final nom = nomController.text.trim();
    final prenom = prenomController.text.trim();
    final email = emailController.text.trim();
    final pseudo = pseudoController.text.trim();
    final mdp = mdpController.text.trim();
    final mdpConfirm = mdpConfirmController.text.trim();

    if (!isValidEmail(email)) {
      showDialog(context: context, builder: (_) => AlertDialog(
        title: Text('Email invalide'),
        content: Text('Veuillez entrer une adresse email valide.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
      ));
      return;
    }

    if (!isStrongPassword(mdp)) {
      showDialog(context: context, builder: (_) => AlertDialog(
        title: Text('Mot de passe trop faible'),
        content: Text('Le mot de passe doit contenir au moins 8 caractères, une majuscule, une minuscule, un chiffre et un caractère spécial.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
      ));
      return;
    }
    String hashPassword(String mdp) {
  final bytes = utf8.encode(mdp);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
    if (mdp != mdpConfirm) {
      showDialog(context: context, builder: (_) => AlertDialog(
        title: Text('Mots de passe différents'),
        content: Text('Les deux mots de passe ne correspondent pas.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
      ));
      return;
    }

    if (!conditionsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez accepter les conditions")),
      );
      return;
    }

    if ([nom, prenom, email, pseudo, mdp, mdpConfirm].any((e) => e.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tous les champs sont requis")),
      );
      return;
    }

    final apiUrl = kIsWeb
        ? 'http://localhost:3000/users'
        : 'http://gamerconnect-api:3000/users';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nom": nom,
          "prenom": prenom,
          "pseudo": pseudo,
          "email": email,
          "mot_de_passe": hashPassword(mdp),
          "plateformes_liees": ""
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Compte créé avec succès")),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : ${error['message'] ?? 'Inscription échouée'}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de connexion à l’API")),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black, title: Text("GamerConnect")),
      backgroundColor: Color(0xFF1E1E1E),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("INSCRIPTION", style: TextStyle(color: Colors.white, fontSize: 20), textAlign: TextAlign.center),
            SizedBox(height: 20),
            _buildField("Nom", nomController),
            _buildField("Prénom", prenomController),
            _buildField("Adresse e-mail", emailController),
            _buildField("Pseudo", pseudoController),
            _buildField("Mot de passe", mdpController, obscure: true),
            _buildField("Confirmer le mot de passe", mdpConfirmController, obscure: true),
            Row(
              children: [
                Checkbox(
                  value: conditionsAccepted,
                  onChanged: (value) {
                    setState(() => conditionsAccepted = value ?? false);
                  },
                ),
                Expanded(
                  child: Text("J'accepte les conditions de souscription Steam", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF3B5AFE)),
              child: Text("Créer mon compte"),
            ),
          ],
        ),
      ),
    );
  }
}
