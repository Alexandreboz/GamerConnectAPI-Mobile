import 'package:flutter/material.dart';

class ProfilPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D071E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // Avatar + Nom + @pseudo
            Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/avatar1.png'), // à adapter selon ton projet
                ),
                const SizedBox(height: 10),
                const Text(
                  "Jamie",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Text(
                  "@jamieg02",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Section jeux préférés
            _buildCardSection(
              title: "Jeux preferes",
              child: SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildGameCard("assets/images/fifa.png", "FIFA\n23"),
                    _buildGameCard("assets/images/dofus.png", "Dofus\nTouch"),
                    _buildGameCard("assets/images/monster.png", "Monster\nHunter"), // Assure-toi que l'image existe
                    _buildGameCard("assets/images/pokemon.png", "Pokemon\nGo"),   // Assure-toi que l'image existe  
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Succès et style
            _buildCardSection(
              title: "",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Succes", style: TextStyle(color: Colors.white)),
                  Text("150", style: TextStyle(color: Colors.white)),
                  Text("Style de jeu", style: TextStyle(color: Colors.white)),
                  Text("Aventure", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Comptes liés
            _buildCardSection(
              title: "Comptes lies",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset("assets/images/ps.png", height: 40), // Playstation
                  Image.asset("assets/images/xbox.png", height: 40), // Xbox
                  Image.asset("assets/images/steam.png", height: 40), // Steam
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(String imagePath, String title) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(imagePath, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1333),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          child,
        ],
      ),
    );
  }
}
