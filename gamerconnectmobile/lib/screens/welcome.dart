import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/design_system.dart';
import 'register_page.dart';
import 'login.dart';

class WelcomePage extends StatefulWidget {
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      -0.5 + _bgController.value,
                      -0.5 + _bgController.value * 0.5,
                    ),
                    radius: 1.5,
                    colors: const [
                      Color(0xFF1A0A3E),
                      Color(0xFF080810),
                      Color(0xFF0A0A20),
                    ],
                  ),
                ),
              );
            },
          ),

          // Glowing orbs
          Positioned(
            top: -100,
            left: -80,
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (_, __) => Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.25 + _bgController.value * 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -60,
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (_, __) => Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withOpacity(0.2 + (1 - _bgController.value) * 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating gaming icons
          ..._buildFloatingIcons(size),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Logo + glow
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, child) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3 + _pulseController.value * 0.2),
                            blurRadius: 60 + _pulseController.value * 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Icon(Icons.sports_esports_rounded, color: Colors.white, size: 55),
                    ),
                  ).animate().scale(duration: const Duration(milliseconds: 700), curve: Curves.easeOutBack).fadeIn(),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    "GAMER",
                    style: AppStyles.heading.copyWith(fontSize: 42, letterSpacing: 4),
                  ).animate().slideY(begin: 0.3, duration: const Duration(milliseconds: 500)).fadeIn(),
                  ShaderMask(
                    shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                    child: Text(
                      "CONNECT",
                      style: AppStyles.heading.copyWith(fontSize: 42, letterSpacing: 4, color: Colors.white),
                    ),
                  ).animate().slideY(begin: 0.3, duration: const Duration(milliseconds: 500), delay: const Duration(milliseconds: 100)).fadeIn(),

                  const SizedBox(height: 16),
                  Text(
                    "Talk. Play. Dominate.\nWhere legends are born.",
                    textAlign: TextAlign.center,
                    style: AppStyles.body.copyWith(fontSize: 15, color: Colors.white54, height: 1.7),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 400)),

                  const Spacer(flex: 3),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statChip("10K+", "PLAYERS"),
                      _statChip("500+", "GROUPS"),
                      _statChip("20+", "GAMES"),
                    ],
                  ).animate().fadeIn(delay: const Duration(milliseconds: 500)).slideY(begin: 0.2),

                  const SizedBox(height: 40),

                  // CTA buttons
                  _buildGradientButton(
                    "GET STARTED",
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage())),
                  ).animate().slideY(begin: 1, duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 300)).fadeIn(),

                  const SizedBox(height: 16),

                  OutlinedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage())),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                    child: const Text("I ALREADY HAVE AN ACCOUNT", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 13)),
                  ).animate().slideY(begin: 1, duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 400)).fadeIn(),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String value, String label) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
          child: Text(
            value,
            style: AppStyles.heading.copyWith(fontSize: 22, color: Colors.white),
          ),
        ),
        Text(label, style: AppStyles.label.copyWith(color: Colors.white38, fontSize: 9)),
      ],
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Center(
          child: Text(text, style: AppStyles.heading.copyWith(fontSize: 15, letterSpacing: 2, color: Colors.white)),
        ),
      ),
    );
  }

  List<Widget> _buildFloatingIcons(Size size) {
    final icons = [
      Icons.videogame_asset_rounded,
      Icons.emoji_events_rounded,
      Icons.flash_on_rounded,
      Icons.groups_rounded,
      Icons.star_rounded,
      Icons.gamepad_rounded,
    ];
    final rng = Random(42);
    return List.generate(6, (i) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final iconColor = [AppColors.primary, AppColors.secondary, AppColors.accent][i % 3];
      return Positioned(
        left: x,
        top: y,
        child: Icon(icons[i], color: iconColor.withOpacity(0.08), size: 40 + rng.nextDouble() * 30)
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: Duration(milliseconds: 2000 + i * 500))
            .moveY(begin: 0, end: -10, duration: Duration(milliseconds: 2000 + i * 300)),
      );
    });
  }
}