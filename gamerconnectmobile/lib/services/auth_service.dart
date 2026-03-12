import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyId = 'id_utilisateur';
  static const _keyPseudo = 'pseudo';
  static const _keyNom = 'nom';
  static const _keyPrenom = 'prenom';
  static const _keyEmail = 'email';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyId);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyId);
  }

  static Future<String> getPseudo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPseudo) ?? 'Legend';
  }

  static Future<Map<String, String>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'pseudo': prefs.getString(_keyPseudo) ?? '',
      'nom': prefs.getString(_keyNom) ?? '',
      'prenom': prefs.getString(_keyPrenom) ?? '',
      'email': prefs.getString(_keyEmail) ?? '',
    };
  }

  static Future<void> saveSession(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyId, user['id_utilisateur']);
    await prefs.setString(_keyPseudo, user['pseudo'] ?? '');
    await prefs.setString(_keyNom, user['nom'] ?? '');
    await prefs.setString(_keyPrenom, user['prenom'] ?? '');
    await prefs.setString(_keyEmail, user['email'] ?? '');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
