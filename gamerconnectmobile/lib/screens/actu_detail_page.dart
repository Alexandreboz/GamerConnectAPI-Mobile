import 'package:flutter/material.dart';

class ActuDetailPage extends StatelessWidget {
  final String jeu;
  final String titre;
  final String contenu;
  final String image;

  const ActuDetailPage({
    required this.jeu,
    required this.titre,
    required this.contenu,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(jeu),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Color(0xFF0F0B1E),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset(image, height: 180),
            SizedBox(height: 20),
            Text(titre, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text(contenu, style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
