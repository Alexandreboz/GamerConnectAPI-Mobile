import 'package:flutter/material.dart';
import 'profil.dart';
import 'evenement_page.dart';
import 'actu_page.dart';
import 'succes_page.dart';
import 'groupes_page.dart'; // ✅ AJOUT

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilPage()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GroupesPage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0B1E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/logo.png', height: 30),
                    const SizedBox(width: 8),
                    const Text(
                      "GamerConnect",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _menuCard('Actu', 'assets/images/actu.png', Colors.red),
                    _menuCard('Eventments', 'assets/images/event.png', Colors.purple),
                    _menuCard('Succes', 'assets/images/succes.png', Colors.teal),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Alcuestt",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _postCard(
                  avatar: 'assets/images/avatar1.png',
                  username: 'Zelda',
                  handle: '@ZeldaG',
                  text: 'Oh enfin la nouvelle map',
                ),
                const SizedBox(height: 10),
                _postCard(
                  avatar: 'assets/images/avatar1.png',
                  username: 'Goku',
                  handle: '@GokuS',
                  text: 'Une nouvelle mise à jour disponible dès maintenant',
                  image: 'assets/images/city.png',
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1B1530),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: ''), // ✅ redirige vers groupes
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }

  Widget _menuCard(String label, String image, Color color) {
    return GestureDetector(
      onTap: () {
        if (label == 'Eventments') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EvenementPage()),
          );
        } else if (label == 'Actu') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ActuPage()),
          );
        } else if (label == 'Succes') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SuccesPage()),
          );
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Image.asset(image, height: 30),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _postCard({
    required String avatar,
    required String username,
    required String handle,
    required String text,
    String? image,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1530),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundImage: AssetImage(avatar)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(username,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(handle, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: Colors.white)),
          if (image != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(image),
            ),
          ],
          const SizedBox(height: 8),
          const Text("Aluhours", style: TextStyle(color: Colors.purpleAccent)),
        ],
      ),
    );
  }
}
