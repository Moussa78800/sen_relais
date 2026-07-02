import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

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
      return 0.0;
    }
  }

  // Récupérer l'historique des transactions
  Future<List<Map<String, dynamic>>> getTransactions(String userId) async {
    try {
      // Récupérer d'abord l'ID du wallet
      final wallet = await _supabase
          .from('wallets')
          .select('id')
          .eq('user_id', userId)
          .single();

      final response = await _supabase
          .from('wallet_transactions')
          .select()
          .eq('wallet_id', wallet['id'])
          .order('created_at', ascending: false)
          .limit(20);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Recharger le wallet (simulation)
  Future<bool> rechargeWallet(String userId, double amount) async {
    try {
      final response = await _supabase.rpc(
        'credit_wallet',
        params: {
          'p_user_id': userId,
          'p_amount': amount,
          'p_description': 'Recharge wallet',
          'p_reference': 'RECH-${DateTime.now().millisecondsSinceEpoch}',
        },
      );
      return response == true;
    } catch (e) {
      return false;
    }
  }

  // Récupérer les réservations de vol
  Future<List<Map<String, dynamic>>> getFlights(String userId) async {
    try {
      final response = await _supabase
          .from('flights')
          .select()
          .eq('user_id', userId)
          .order('departure_time', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}
