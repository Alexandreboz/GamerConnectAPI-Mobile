import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../theme/design_system.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nomCtrl     = TextEditingController();
  final _prenomCtrl  = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _pseudoCtrl  = TextEditingController();
  final _mdpCtrl     = TextEditingController();
  final _mdpConfCtrl = TextEditingController();
  bool _terms = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;
  int _step = 0; // 0 = identity, 1 = credentials

  String _hash(String s) => sha256.convert(utf8.encode(s)).toString();

  bool _isValidEmail(String e) => RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(e);

  String? _passwordStrength(String p) {
    if (p.length < 8) return 'Au moins 8 caractères';
    if (!RegExp(r'[A-Z]').hasMatch(p)) return 'Une majuscule requise';
    if (!RegExp(r'[0-9]').hasMatch(p)) return 'Un chiffre requis';
    return null; // strong
  }

  Future<void> _submit() async {
    final nom    = _nomCtrl.text.trim();
    final prenom = _prenomCtrl.text.trim();
    final email  = _emailCtrl.text.trim();
    final pseudo = _pseudoCtrl.text.trim();
    final mdp    = _mdpCtrl.text.trim();
    final conf   = _mdpConfCtrl.text.trim();

    if ([nom, prenom, email, pseudo, mdp, conf].any((e) => e.isEmpty)) { _snack("Tous les champs sont requis", error: true); return; }
    if (!_isValidEmail(email)) { _snack("Email invalide", error: true); return; }
    final strength = _passwordStrength(mdp);
    if (strength != null) { _snack(strength, error: true); return; }
    if (mdp != conf) { _snack("Les mots de passe ne correspondent pas", error: true); return; }
    if (!_terms) { _snack("Accepte les conditions", error: true); return; }

    setState(() => _loading = true);
    try {
      final ok = await ApiService.createUser({
        "nom": nom, "prenom": prenom, "pseudo": pseudo,
        "email": email, "mot_de_passe": _hash(mdp), "plateformes_liees": ""
      });
      if (!mounted) return;
      if (ok) {
        _snack("Compte créé ! Connecte-toi 🎮", error: false);
        await Future.delayed(const Duration(milliseconds: 800));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
      } else {
        _snack("Ce pseudo ou email est déjà utilisé", error: true);
      }
    } catch (_) {
      _snack("Impossible de joindre l'API", error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg, {required bool error}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: error ? AppColors.accent : AppColors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CRÉER UN COMPTE", style: AppStyles.heading.copyWith(fontSize: 16)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stepper indicator
            _buildStepper(),
            const SizedBox(height: 32),

            if (_step == 0) ..._buildStep0(),
            if (_step == 1) ..._buildStep1(),

            const SizedBox(height: 32),
            _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _step == 0
                    ? _gradBtn("SUIVANT →", _nextStep)
                    : _gradBtn("CRÉER MON COMPTE", _submit),

            const SizedBox(height: 20),
            if (_step == 1)
              OutlinedButton(
                onPressed: () => setState(() => _step = 0),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("← RETOUR", style: TextStyle(color: Colors.white70)),
              ),

            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("Déjà un compte ?", style: AppStyles.subHeading),
              TextButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage())),
                child: Text("Se connecter", style: AppStyles.subHeading.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Row(
      children: List.generate(2, (i) => Expanded(
        child: Container(
          margin: EdgeInsets.only(left: i == 0 ? 0 : 6),
          height: 5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: i <= _step ? AppColors.primaryGradient : null,
            color: i <= _step ? null : Colors.white.withOpacity(0.1),
          ),
        ),
      )),
    );
  }

  List<Widget> _buildStep0() => [
    Text("Ton identité", style: AppStyles.heading.copyWith(fontSize: 20)).animate().fadeIn(),
    const SizedBox(height: 8),
    Text("Comment t'appellent tes équipiers ?", style: AppStyles.subHeading).animate().fadeIn(delay: const Duration(milliseconds: 100)),
    const SizedBox(height: 28),
    Row(children: [
      Expanded(child: _field("Prénom", _prenomCtrl, Icons.person_outline)),
      const SizedBox(width: 12),
      Expanded(child: _field("Nom", _nomCtrl, Icons.person_outline)),
    ]),
    const SizedBox(height: 14),
    _field("Email", _emailCtrl, Icons.email_outlined, keyboard: TextInputType.emailAddress),
    const SizedBox(height: 14),
    _field("Pseudo (ton nom de jeu)", _pseudoCtrl, Icons.videogame_asset_outlined),
  ];

  List<Widget> _buildStep1() => [
    Text("Sécurise ton compte", style: AppStyles.heading.copyWith(fontSize: 20)).animate().fadeIn(),
    const SizedBox(height: 8),
    Text("Choisis un mot de passe fort", style: AppStyles.subHeading).animate().fadeIn(delay: const Duration(milliseconds: 100)),
    const SizedBox(height: 28),
    _field("Mot de passe", _mdpCtrl, Icons.lock_outline, obscure: _obscure1, onToggle: () => setState(() => _obscure1 = !_obscure1)),
    const SizedBox(height: 8),
    // Password strength bar
    ValueListenableBuilder(
      valueListenable: _mdpCtrl,
      builder: (_, __, ___) {
        final mdp = _mdpCtrl.text;
        double strength = 0;
        if (mdp.length >= 8) strength += 0.33;
        if (RegExp(r'[A-Z]').hasMatch(mdp)) strength += 0.33;
        if (RegExp(r'[0-9!@#\$]').hasMatch(mdp)) strength += 0.34;
        final color = strength < 0.4 ? AppColors.accent : strength < 0.8 ? AppColors.gold : AppColors.green;
        final label = strength < 0.4 ? 'Faible' : strength < 0.8 ? 'Moyen' : 'Fort 💪';
        return Row(children: [
          Expanded(child: AppWidgets.xpBar(strength)),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ]);
      },
    ),
    const SizedBox(height: 14),
    _field("Confirmer le mot de passe", _mdpConfCtrl, Icons.lock_reset_outlined, obscure: _obscure2, onToggle: () => setState(() => _obscure2 = !_obscure2)),
    const SizedBox(height: 20),
    GestureDetector(
      onTap: () => setState(() => _terms = !_terms),
      child: Row(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 22, height: 22,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: _terms ? AppColors.primaryGradient : null,
            border: Border.all(color: _terms ? AppColors.primary : Colors.grey, width: 1.5),
          ),
          child: _terms ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
        ),
        const SizedBox(width: 12),
        Expanded(child: Text("J'accepte les conditions d'utilisation et la charte communautaire", style: AppStyles.subHeading.copyWith(fontSize: 12))),
      ]),
    ),
  ];

  void _nextStep() {
    final prenom = _prenomCtrl.text.trim();
    final nom = _nomCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pseudo = _pseudoCtrl.text.trim();
    if ([prenom, nom, email, pseudo].any((e) => e.isEmpty)) { _snack("Remplis tous les champs", error: true); return; }
    if (!_isValidEmail(email)) { _snack("Email invalide", error: true); return; }
    setState(() => _step = 1);
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon,
      {bool obscure = false, VoidCallback? onToggle, TextInputType? keyboard}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: TextField(
        controller: ctrl, obscureText: obscure, keyboardType: keyboard,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          labelText: label, labelStyle: AppStyles.subHeading,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: onToggle != null
              ? IconButton(
                  icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey, size: 20),
                  onPressed: onToggle)
              : null,
        ),
      ),
    );
  }

  Widget _gradBtn(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Center(child: Text(text, style: AppStyles.heading.copyWith(fontSize: 14, letterSpacing: 1.5, color: Colors.white))),
      ),
    );
  }
}
