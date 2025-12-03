import 'package:cc/screens/home_screen.dart';
import 'package:cc/screens/splash_screen.dart'; // Ajoutez cet import
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cc/screens/signup_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CampusConnect());
}

class CampusConnect extends StatelessWidget {
  const CampusConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Connect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/signup': (context) => const SignUpScreen(), // Optionnel
      },
      home: const SplashScreen(), // ← Modifié ici
      debugShowCheckedModeBanner: false,
    );
  }
}