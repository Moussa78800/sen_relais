import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final DatabaseService _dbService = DatabaseService();

  User? get currentUser => _supabase.auth.currentUser;

  // Inscription
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      print('🔵 Inscription de ...');

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('✅ Utilisateur créé dans Supabase Auth');

        // Créer le profil utilisateur
        await _dbService.createUserProfile(
          userId: response.user!.id,
          email: email,
          fullName: fullName,
          phone: phone,
        );

        print('✅ Profil créé');

        // Créer le wallet
        await _dbService.createWallet(response.user!.id);
        print('✅ Wallet créé');
      }

      return response;
    } catch (e) {
      print('❌ Erreur inscription: ');
      rethrow;
    }
  }

  // Connexion
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔵 Connexion de ...');
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print('✅ Connecté: ');
      return response;
    } catch (e) {
      print('❌ Erreur connexion: ');
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      print('🔵 Déconnexion...');
      await _supabase.auth.signOut();
      print('✅ Déconnecté');
    } catch (e) {
      print('❌ Erreur déconnexion: ');
      rethrow;
    }
  }

  // Récupérer le profil utilisateur - CORRIGÉ pour retourner UserModel
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response =
          await _supabase.from('users').select().eq('id', userId).single();

      // CORRECTION : Convertir le Map en UserModel
      return UserModel.fromMap(response);
    } catch (e) {
      print('❌ Erreur récupération profil: ');
      return null;
    }
  }
}
