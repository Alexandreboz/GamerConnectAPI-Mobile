import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Core palette
  static const Color background = Color(0xFF080810);
  static const Color surface = Color(0xFF12121A);
  static const Color surfaceElevated = Color(0xFF1A1A28);
  static const Color cardBg = Color(0xFF1C1C2E);

  // Brand colors
  static const Color primary = Color(0xFF7C4DFF);
  static const Color primaryLight = Color(0xFFB388FF);
  static const Color secondary = Color(0xFF00E5FF);
  static const Color accent = Color(0xFFFF4081);
  static const Color gold = Color(0xFFFFD700);
  static const Color orange = Color(0xFFFF6B35);
  static const Color green = Color(0xFF00E676);

  // Glass
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF9C6FFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF0099BB), secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF2060), accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFAB00), gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [background, Color(0xFF0D0D1E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient cardGradient(Color color) => LinearGradient(
    colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppStyles {
  static TextStyle heading = GoogleFonts.orbitron(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 1.5,
  );

  static TextStyle body = GoogleFonts.inter(
    fontSize: 15,
    color: Colors.white70,
    height: 1.5,
  );

  static TextStyle subHeading = GoogleFonts.inter(
    fontSize: 13,
    color: Colors.grey,
    fontWeight: FontWeight.w500,
  );

  static TextStyle label = GoogleFonts.inter(
    fontSize: 11,
    color: Colors.white,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );

  static BoxDecoration glassDecoration = BoxDecoration(
    color: AppColors.glassWhite,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.glassBorder),
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.cardBg,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.4),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration glowDecoration(Color color) => BoxDecoration(
    color: AppColors.cardBg,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: color.withOpacity(0.3), width: 1),
    boxShadow: [
      BoxShadow(
        color: color.withOpacity(0.2),
        blurRadius: 20,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.4),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

class AppWidgets {
  /// Chip badge with colored background
  static Widget badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  /// Section header with divider
  static Widget sectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.orbitron(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'SEE ALL',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
      ],
    );
  }

  /// Online status dot
  static Widget onlineDot({bool online = true}) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: online ? AppColors.green : Colors.grey,
        shape: BoxShape.circle,
        boxShadow: online
            ? [BoxShadow(color: AppColors.green.withOpacity(0.6), blurRadius: 6)]
            : null,
      ),
    );
  }

  /// XP Progress bar
  static Widget xpBar(double progress, {String? label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label, style: AppStyles.label),
          ),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress.clamp(0, 1),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
