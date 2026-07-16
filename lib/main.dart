// ignore_for_file: deprecated_member_use
import 'screens/dashboard_admin_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';

//  Lecture des variables sécurisées (avec valeurs par défaut pour le dev)
const String supabaseUrl = String.fromEnvironment('SUPABASE_URL',
    defaultValue: 'https://gljuzugelkoneyqnhhjq.supabase.co');
const String supabaseAnonKey =
    String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (supabaseAnonKey.isEmpty) {
    print(
        '⚠️ Attention: SUPABASE_ANON_KEY n\'est pas définie dans le fichier .env');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const SenRelaisApp());
}

class SenRelaisApp extends StatelessWidget {
  const SenRelaisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SEN RELAIS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(), //
        primaryColor: const Color(0xFFE30613),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFE30613),
          secondary: Color(0xFFB80000),
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black87,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE30613),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE30613),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      // StreamBuilder pour gérer l'état d'authentification
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          // En cours de chargement
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFE30613),
                ),
              ),
            );
          }

          // Utilisateur connecté → Home
          if (snapshot.hasData && snapshot.data?.session != null) {
            return const HomeScreen();
          }

          // Utilisateur non connecté → Login
          return const LoginScreen();
        },
      ),
      // Routes nommées
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/admin': (context) =>
            const DashboardAdminScreen(), // ← Ajouter cette ligne
      },
    );
  }
}
