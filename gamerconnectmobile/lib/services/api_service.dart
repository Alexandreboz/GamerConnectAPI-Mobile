import 'dart:convert';
import 'package:http/http.dart' as http;

const String _baseUrl = 'http://localhost:3005';

class ApiService {
  // ─── Users ────────────────────────────────────────────────────────────────
  static Future<List<dynamic>> getUsers() async {
    final res = await http.get(Uri.parse('$_baseUrl/users'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load users');
  }

  static Future<Map<String, dynamic>?> getUserById(int id) async {
    final res = await http.get(Uri.parse('$_baseUrl/users/id/$id'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }

  static Future<bool> createUser(Map<String, dynamic> userData) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
    return res.statusCode == 201;
  }

  // ─── Groups ───────────────────────────────────────────────────────────────
  static Future<List<dynamic>> getGroupes() async {
    final res = await http.get(Uri.parse('$_baseUrl/groupes'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load groupes');
  }

  static Future<List<dynamic>> getMembresGroupe(int groupeId) async {
    final res = await http.get(Uri.parse('$_baseUrl/groupes/$groupeId/membres'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<List<dynamic>> getMessagesGroupe(int groupeId) async {
    final res = await http.get(Uri.parse('$_baseUrl/groupes/$groupeId/messages'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<bool> rejoindreGroupe(int groupeId, int userId) async {
    // Check membership first
    final membres = await getMembresGroupe(groupeId);
    final alreadyMember = membres.any((m) => m['id_utilisateur'] == userId);
    if (alreadyMember) return true;

    final res = await http.post(
      Uri.parse('$_baseUrl/groupes/$groupeId/rejoindre'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_utilisateur': userId}),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  static Future<Map<String, dynamic>?> sendMessage(
      int userId, int groupeId, String content) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_utilisateur': userId,
        'id_groupe': groupeId,
        'contenu': content,
      }),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    return null;
  }

  // ─── Events ───────────────────────────────────────────────────────────────
  static Future<List<dynamic>> getEvenements() async {
    final res = await http.get(Uri.parse('$_baseUrl/evenements'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<Map<String, dynamic>?> getEvenementById(int id) async {
    final res = await http.get(Uri.parse('$_baseUrl/evenements/$id'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }
}
