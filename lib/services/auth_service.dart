import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      print('🔵 Début inscription pour: $email');

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      print('🟢 User créé: ${response.user?.email}');
      print('🟢 User ID: ${response.user?.id}');

      if (response.user != null) {
        // Utiliser la fonction sécurisée pour créer le profil
        try {
          await _supabase.rpc(
            'create_user_profile',
            params: {
              'p_id': response.user!.id,
              'p_email': email,
              'p_full_name': fullName,
              'p_phone': phone,
              'p_country': 'SN',
            },
          );
          print('✅ Profil créé via fonction sécurisée');
        } catch (e) {
          print('⚠️ Erreur création profil: $e');
        }

        await Future.delayed(const Duration(seconds: 1));

        final userProfile = await getUserProfile(response.user!.id);
        print('✅ Profil récupéré: ${userProfile?.email}');

        return userProfile;
      }
      return null;
    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message}');
      throw Exception(_getAuthErrorMessage(e.message));
    } catch (e) {
      print('❌ Erreur générale: $e');
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔵 Tentative connexion pour: $email');

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('🟢 Connecté: ${response.user?.email}');

      if (response.user != null) {
        return await getUserProfile(response.user!.id);
      }
      return null;
    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message}');
      throw Exception(_getAuthErrorMessage(e.message));
    }
  }

  Future<void> signOut() async {
    print('🔴 Déconnexion en cours...');
    await _supabase.auth.signOut();
    print('✅ Déconnecté');
  }

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromMap(response);
    } catch (e) {
      print('⚠️ Erreur getUserProfile: $e');
      return null;
    }
  }

  Future<UserModel?> updateProfile({String? fullName, String? phone}) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) return null;

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;

      await _supabase.from('users').update(updates).eq('id', userId);

      return await getUserProfile(userId);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil');
    }
  }

  String _getAuthErrorMessage(String message) {
    switch (message) {
      case 'Invalid login credentials':
        return 'Email ou mot de passe incorrect';
      case 'Email not confirmed':
        return 'Email non confirmé';
      case 'User already registered':
        return 'Cet email est déjà utilisé';
      case 'Password should be at least 6 characters':
        return 'Le mot de passe doit contenir au moins 6 caractères';
      default:
        return message;
    }
  }
}
