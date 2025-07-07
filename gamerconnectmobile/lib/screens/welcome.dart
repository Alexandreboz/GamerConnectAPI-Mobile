import 'package:flutter/material.dart';
import 'register_page.dart';
import 'login.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to GamerConect",
              style: TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Image.asset('assets/images/logo.png', height: 200),
            SizedBox(height: 20),
            Text(
              "Join over 100 million people who use GamerConnect to talk with communities and friends.",
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage())),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF3B5AFE)),
              child: Text("Register"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage())),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}