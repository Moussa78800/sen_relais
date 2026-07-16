import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  // Inscription
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        // ✅ VÉRIFIER d'abord si l'utilisateur existe déjà dans public.users
        final existingUser = await _supabase
            .from('users')
            .select('id')
            .eq('id', response.user!.id)
            .maybeSingle();

        if (existingUser == null) {
          // L'utilisateur n'existe pas dans public.users, on l'insère
          await _supabase.from('users').insert({
            'id': response.user!.id,
            'email': email,
            'full_name': fullName,
            'phone': phone,
            'is_admin': false,
            'is_blocked': false,
          });
        } else {
          // L'utilisateur existe déjà, on met juste à jour les infos
          await _supabase.from('users').update({
            'full_name': fullName,
            'phone': phone,
          }).eq('id', response.user!.id);
        }

        // Vérifier et créer le wallet s'il n'existe pas
        final existingWallet = await _supabase
            .from('wallets')
            .select('id')
            .eq('user_id', response.user!.id)
            .maybeSingle();

        if (existingWallet == null) {
          await _supabase.from('wallets').insert({
            'user_id': response.user!.id,
            'balance': 0,
          });
        }

        return await getUserProfile(response.user!.id);
      }
      return null;
    } catch (e) {
      print('❌ Erreur inscription: $e');
      return null;
    }
  }

  // Connexion
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔵 Connexion de $email...');
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('✅ Connecté: ${response.user!.email}');
        return await getUserProfile(response.user!.id);
      }
      return null;
    } catch (e) {
      print('❌ Erreur connexion: $e');
      return null;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      print('✅ Déconnecté');
    } catch (e) {
      print('❌ Erreur déconnexion: $e');
    }
  }

  // Récupérer le profil utilisateur
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response =
          await _supabase.from('users').select().eq('id', userId).single();

      return UserModel.fromMap(response);
    } catch (e) {
      print('❌ Erreur récupération profil: $e');
      return null;
    }
  }

  // 🆕 METTRE À JOUR LE PROFIL
  Future<bool> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? address,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (address != null) updates['address'] = address;
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase.from('users').update(updates).eq('id', userId);
      return true;
    } catch (e) {
      print('❌ Erreur mise à jour profil: $e');
      return false;
    }
  }

  // 🆕 CHANGER LE MOT DE PASSE
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Vérifier le mot de passe actuel
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Supabase ne permet pas de vérifier l'ancien mot de passe directement
      // On doit d'abord se reconnecter avec l'ancien
      await _supabase.auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );

      // Changer le mot de passe
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      return true;
    } catch (e) {
      print('❌ Erreur changement mot de passe: $e');
      return false;
    }
  }

  // 🆕 METTRE À JOUR LES PRÉFÉRENCES DE NOTIFICATIONS
  Future<bool> updateNotificationPreferences({
    required String userId,
    required bool emailNotifications,
    required bool pushNotifications,
    required bool smsNotifications,
  }) async {
    try {
      await _supabase.from('users').update({
        'email_notifications': emailNotifications,
        'push_notifications': pushNotifications,
        'sms_notifications': smsNotifications,
      }).eq('id', userId);
      return true;
    } catch (e) {
      print('❌ Erreur mise à jour notifications: $e');
      return false;
    }
  }

  // Récupérer les réservations de l'utilisateur
  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erreur récupération réservations: $e');
      return [];
    }
  }
}
