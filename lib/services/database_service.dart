import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Créer un profil utilisateur
  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    String? phone,
  }) async {
    try {
      await _supabase.from('users').insert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'phone': phone,
      });
    } catch (e) {
      print('❌ Erreur création profil: ');
      rethrow;
    }
  }

  // Créer un wallet
  Future<void> createWallet(String userId) async {
    try {
      await _supabase.from('wallets').insert({
        'user_id': userId,
        'balance': 0.0,
      });
    } catch (e) {
      print('❌ Erreur création wallet: ');
      rethrow;
    }
  }

  // Récupérer le solde du wallet
  Future<double> getWalletBalance(String userId) async {
    try {
      final response = await _supabase
          .from('wallets')
          .select('balance')
          .eq('user_id', userId)
          .single();
      return (response['balance'] as num).toDouble();
    } catch (e) {
      print('❌ Erreur récupération solde: ');
      return 0.0;
    }
  }

  // Recharger le wallet
  Future<bool> rechargeWallet(String userId, double amount) async {
    try {
      final result = await _supabase.rpc('credit_wallet', params: {
        'p_user_id': userId,
        'p_amount': amount,
        'p_description': 'Recharge wallet',
        'p_reference': 'RECHARGE-',
      });
      return result == true;
    } catch (e) {
      print('❌ Erreur recharge: ');
      return false;
    }
  }
}
