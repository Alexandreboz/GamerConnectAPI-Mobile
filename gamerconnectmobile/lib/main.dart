import 'package:flutter/material.dart';
import 'screens/welcome.dart';
import 'screens/register_page.dart';
import 'screens/login.dart';
import 'screens/home.dart';
import 'screens/evenement_page.dart';
import 'screens/groupes_page.dart';
import 'screens/discussion_groupe_page.dart';
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
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomePage(),
        '/register-step1': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/evenements': (context) => EvenementPage(),
        '/groupes': (context) => GroupesPage(),
        '/discussion': (context) => DiscussionGroupePage(idGroupe: 1), // Remplacez '' par une valeur par défaut ou gérez dynamiquement l'idGroupe
        '/actu': (context) => ActuPage(),
        '/succes': (context) => SuccesPage(),
      },
    );
  }
}
