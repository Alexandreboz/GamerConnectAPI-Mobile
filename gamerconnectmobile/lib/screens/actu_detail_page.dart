import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/design_system.dart';

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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'actu-$titre',
                child: Image.asset(image, fit: BoxFit.cover),
              ),
              title: Text(jeu.toUpperCase(), style: AppStyles.heading.copyWith(fontSize: 14)),
              centerTitle: true,
            ),
            backgroundColor: AppColors.background,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  titre,
                  style: AppStyles.heading.copyWith(fontSize: 22),
                ).animate().fadeIn(duration: const Duration(milliseconds: 600)).slideY(begin: 0.1),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppStyles.glassDecoration,
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text("Published 2 hours ago", style: AppStyles.subHeading),
                    ],
                  ),
                ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
                const SizedBox(height: 24),
                Text(
                  contenu,
                  style: AppStyles.body.copyWith(height: 1.6),
                ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_rounded),
                  label: const Text("SHARE NEWS"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                  ),
                ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
