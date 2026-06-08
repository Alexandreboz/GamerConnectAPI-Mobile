import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_host.dart';

final String _baseUrl = apiBaseUrl;

class ApiService {
  static String get baseUrl => _baseUrl;
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

  static Future<bool> updateUser(
      int userId, Map<String, dynamic> userData) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  static Future<List<dynamic>> getPosts() async {
    final res = await http.get(Uri.parse('$_baseUrl/posts'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<Map<String, dynamic>> createPost(int userId, String content,
      {List<String>? tags}) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_utilisateur': userId,
        'contenu': content,
        'tags': tags ?? [],
      }),
    );

    if (res.statusCode == 201) {
      return {'success': true, 'data': jsonDecode(res.body)};
    }

    final responseBody = res.body.isNotEmpty ? res.body : 'Unknown error';
    try {
      final parsed = jsonDecode(res.body);
      if (parsed is Map<String, dynamic> && parsed.containsKey('error')) {
        return {
          'success': false,
          'status': res.statusCode,
          'error': parsed['error'] ?? responseBody,
        };
      }
    } catch (_) {}

    return {
      'success': false,
      'status': res.statusCode,
      'error': responseBody,
    };
  }

  // ─── Groups ───────────────────────────────────────────────────────────────
  static Future<List<dynamic>> getGroupes() async {
    final res = await http.get(Uri.parse('$_baseUrl/groupes'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load groupes');
  }

  static Future<List<dynamic>> getMembresGroupe(int groupeId) async {
    final res =
        await http.get(Uri.parse('$_baseUrl/groupes/$groupeId/membres'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<List<dynamic>> getMessagesGroupe(int groupeId) async {
    final res =
        await http.get(Uri.parse('$_baseUrl/groupes/$groupeId/messages'));
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

  static Future<bool> participerEvenement(int eventId, int userId,
      {bool join = true}) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/evenements/$eventId/participer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'id_utilisateur': userId, 'action': join ? 'join' : 'leave'}),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  static Future<List<dynamic>> getEvenementsInscrits(int userId) async {
    final res = await http.get(Uri.parse('$_baseUrl/evenements/user/$userId'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  // ─── Actualités ─────────────────────────────────────────────────────────
  static Future<List<dynamic>> getActus() async {
    final res = await http.get(Uri.parse('$_baseUrl/actus'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<Map<String, dynamic>?> getActuById(int id) async {
    final res = await http.get(Uri.parse('$_baseUrl/actus/$id'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }

  // ─── Succès ──────────────────────────────────────────────────────────────
  static Future<List<dynamic>> getSucces() async {
    final res = await http.get(Uri.parse('$_baseUrl/succes'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<Map<String, dynamic>?> getSuccesById(int id) async {
    final res = await http.get(Uri.parse('$_baseUrl/succes/$id'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }

  // ─── Badges / Trophées ──────────────────────────────────────────────────
  static Future<List<dynamic>> getBadges() async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/badges'));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return [];
  }

  static Future<List<dynamic>> getUserBadges(int userId) async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/users/$userId/badges'));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return [];
  }
}
