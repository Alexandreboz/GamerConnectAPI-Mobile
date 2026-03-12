import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/design_system.dart';
import '../services/auth_service.dart';
import 'home.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _pseudoController = TextEditingController();
  final _mdpController = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _pseudoController.dispose();
    _mdpController.dispose();
    super.dispose();
  }

  String _hash(String s) => sha256.convert(utf8.encode(s)).toString();

  void _login() async {
    final pseudo = _pseudoController.text.trim();
    final mdp = _mdpController.text.trim();
    if (pseudo.isEmpty || mdp.isEmpty) { _snack("Remplis tous les champs", error: true); return; }

    setState(() => _isLoading = true);
    try {
      final res = await http.get(Uri.parse('http://localhost:3005/users'));
      if (!mounted) return;

      if (res.statusCode == 200) {
        final List users = jsonDecode(res.body);
        final user = users.firstWhere(
          (u) => u['pseudo'] == pseudo && u['mot_de_passe'] == _hash(mdp),
          orElse: () => null,
        );
        if (user != null) {
          await AuthService.saveSession(user);
          if (!mounted) return;
          _snack("Bienvenue, ${user['pseudo']} ! 🎮", error: false);
          await Future.delayed(const Duration(milliseconds: 600));
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomePage()), (_) => false);
        } else {
          _snack("Identifiants invalides", error: true);
        }
      } else {
        _snack("Erreur serveur (${res.statusCode})", error: true);
      }
    } catch (_) {
      _snack("Impossible de joindre l'API — vérifie que le serveur tourne", error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg, {required bool error}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: error ? AppColors.accent : AppColors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.5 + _bgController.value, -0.8),
                  radius: 1.5,
                  colors: const [Color(0xFF1A0A3E), Color(0xFF080810)],
                ),
              ),
            ),
          ),
          Positioned(bottom: -100, left: -80, child: Container(
            width: 300, height: 300,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [AppColors.secondary.withOpacity(0.15), Colors.transparent])),
          )),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient,
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 20)]),
                      child: const Icon(Icons.lock_person_rounded, color: Colors.white, size: 38),
                    ).animate().scale(duration: const Duration(milliseconds: 600), curve: Curves.easeOutBack),
                  ),
                  const SizedBox(height: 24),
                  Text("WELCOME BACK", style: AppStyles.heading.copyWith(fontSize: 26), textAlign: TextAlign.center)
                      .animate().fadeIn().slideY(begin: 0.2),
                  const SizedBox(height: 8),
                  Text("Retrouve ta communauté gamer", style: AppStyles.subHeading, textAlign: TextAlign.center)
                      .animate().fadeIn(delay: const Duration(milliseconds: 100)),
                  const SizedBox(height: 48),
                  _field("Pseudo", _pseudoController, Icons.person_outline_rounded, index: 0),
                  const SizedBox(height: 14),
                  _field("Mot de passe", _mdpController, Icons.lock_outline_rounded,
                    obscure: _obscure, onToggle: () => setState(() => _obscure = !_obscure), index: 1),
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerRight,
                    child: TextButton(onPressed: () {},
                      child: Text("Mot de passe oublié ?", style: AppStyles.subHeading.copyWith(color: AppColors.primary)))),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : GestureDetector(
                          onTap: _login,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                            ),
                            child: Center(child: Text("SE CONNECTER", style: AppStyles.heading.copyWith(fontSize: 15, letterSpacing: 2, color: Colors.white))),
                          ),
                        ).animate().slideY(begin: 0.3, duration: const Duration(milliseconds: 500)).fadeIn(),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text("ou", style: AppStyles.subHeading)),
                    Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                  ]),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text("Pas encore de compte ?", style: AppStyles.subHeading),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => RegisterPage())),
                      child: Text("Créer un compte", style: AppStyles.subHeading.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))),
                  ]).animate().fadeIn(delay: const Duration(milliseconds: 400)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon,
      {bool obscure = false, VoidCallback? onToggle, int index = 0}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: TextField(
        controller: ctrl, obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
          labelText: label, labelStyle: AppStyles.subHeading,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          suffixIcon: onToggle != null
              ? IconButton(
                  icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey, size: 20),
                  onPressed: onToggle)
              : null,
        ),
      ),
    ).animate().slideX(begin: -0.1, duration: const Duration(milliseconds: 400), delay: Duration(milliseconds: 100 * index)).fadeIn();
  }
}
