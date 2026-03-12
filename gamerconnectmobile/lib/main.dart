import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/design_system.dart';
import 'services/auth_service.dart';
import 'screens/welcome.dart';
import 'screens/register_page.dart';
import 'screens/login.dart';
import 'screens/home.dart';
import 'screens/profil.dart';
import 'screens/evenement_page.dart';
import 'screens/groupes_page.dart';
import 'screens/actu_page.dart';
import 'screens/succes_page.dart';

void main() {
  runApp(const GamerConnectApp());
}

class GamerConnectApp extends StatelessWidget {
  const GamerConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GamerConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          surface: AppColors.surface,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const _SplashRouter(),
      routes: {
        '/welcome': (context) => WelcomePage(),
        '/register': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/profil': (context) => ProfilPage(),
        '/evenements': (context) => EvenementPage(),
        '/groupes': (context) => GroupesPage(),
        '/actu': (context) => ActuPage(),
        '/succes': (context) => SuccesPage(),
      },
    );
  }
}

/// Splash screen that decides where to go based on auth state
class _SplashRouter extends StatefulWidget {
  const _SplashRouter();
  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final loggedIn = await AuthService.isLoggedIn();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => loggedIn ? HomePage() : WelcomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 30)],
              ),
              child: const Icon(Icons.sports_esports_rounded, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 24),
            Text(
              "GAMERCONNECT",
              style: AppStyles.heading.copyWith(fontSize: 22, letterSpacing: 3),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}
