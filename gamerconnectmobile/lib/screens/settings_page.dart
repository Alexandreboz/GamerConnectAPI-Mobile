import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/design_system.dart';
import 'edit_profile_page.dart';
import 'welcome.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, String> _profile = {
    'pseudo': '',
    'nom': '',
    'prenom': '',
    'email': '',
  };

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.getProfile();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => WelcomePage()),
      (_) => false,
    );
  }

  Future<void> _openEditProfile() async {
    final result = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(builder: (_) => const EditProfilePage()),
    );
    if (result == true) {
      await _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Paramètres', style: AppStyles.heading.copyWith(fontSize: 18)),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('Compte', style: AppStyles.heading.copyWith(fontSize: 16)),
                const SizedBox(height: 16),
                _infoTile('Pseudo', _profile['pseudo'] ?? ''),
                const SizedBox(height: 12),
                _infoTile('Prénom', _profile['prenom'] ?? ''),
                const SizedBox(height: 12),
                _infoTile('Nom', _profile['nom'] ?? ''),
                const SizedBox(height: 12),
                _infoTile('Email', _profile['email'] ?? ''),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _openEditProfile,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Modifier mes informations'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _logout,
                  icon:
                      const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  label: const Text('Déconnexion',
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  AppStyles.label.copyWith(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value.isNotEmpty ? value : '-', style: AppStyles.subHeading),
        ],
      ),
    );
  }
}
