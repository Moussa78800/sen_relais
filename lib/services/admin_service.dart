import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:universal_html/html.dart' as html;

class AdminService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Vérifier si l'utilisateur est admin
  Future<bool> isAdmin(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('is_admin')
          .eq('id', userId)
          .single();
      return response['is_admin'] == true;
    } catch (e) {
      return false;
    }
  }

  // 2. Statistiques avancées (Revenus, Réservations, Panier Moyen)
  Future<Map<String, dynamic>> getAdvancedStats() async {
    try {
      final bookings = await _supabase
          .from('bookings')
          .select('price, status')
          .eq('status', 'confirmed');
      final totalBookings = bookings.length;
      final totalRevenue = bookings.fold<double>(
          0.0, (sum, b) => sum + ((b['price'] as num?)?.toDouble() ?? 0.0));
      final averageBasket =
          totalBookings > 0 ? (totalRevenue / totalBookings) : 0.0;

      return {
        'totalBookings': totalBookings,
        'totalRevenue': totalRevenue,
        'averageBasket': averageBasket,
      };
    } catch (e) {
      print('❌ Erreur stats avancées: $e');
      return {'totalBookings': 0, 'totalRevenue': 0.0, 'averageBasket': 0.0};
    }
  }

  // 3. Répartition des réservations par classe de siège
  Future<Map<String, int>> getSeatClassDistribution() async {
    try {
      final bookings = await _supabase
          .from('bookings')
          .select('seat_class')
          .eq('status', 'confirmed');
      Map<String, int> distribution = {};
      for (var b in bookings) {
        String seatClass = (b['seat_class'] ?? 'Économique').toString();
        distribution[seatClass] = (distribution[seatClass] ?? 0) + 1;
      }
      return distribution;
    } catch (e) {
      print('❌ Erreur répartition sièges: $e');
      return {};
    }
  }

  // 4. Récupérer les réservations récentes
  Future<List<Map<String, dynamic>>> getRecentBookingsForManagement(
      {int limit = 10}) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select(
              'id, booking_reference, departure_iata, arrival_iata, price, status, created_at, users(full_name, email)')
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erreur réservations récentes: $e');
      return [];
    }
  }

  // 5. Récupérer tous les utilisateurs
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _supabase.rpc('get_all_users_for_admin');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erreur récupération utilisateurs: $e');
      return [];
    }
  }

  // 6. Bloquer / Débloquer un utilisateur
  Future<bool> toggleUserBlock(String userId, bool isBlocked) async {
    try {
      await _supabase
          .from('users')
          .update({'is_blocked': isBlocked}).eq('id', userId);
      return true;
    } catch (e) {
      print('❌ Erreur blocage: $e');
      return false;
    }
  }

  // 7. Supprimer un utilisateur
  Future<bool> deleteUser(String userId) async {
    try {
      await _supabase.from('users').delete().eq('id', userId);
      return true;
    } catch (e) {
      print('❌ Erreur suppression: $e');
      return false;
    }
  }

  // 8. Annuler une réservation
  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _supabase
          .from('bookings')
          .update({'status': 'cancelled'}).eq('id', bookingId);
      return true;
    } catch (e) {
      print('❌ Erreur annulation: $e');
      return false;
    }
  }

  // 9. Rembourser une réservation
  Future<bool> refundBooking(String bookingId, double amount) async {
    try {
      final response = await _supabase.rpc('refund_booking', params: {
        'booking_id': bookingId,
        'refund_amount': amount,
      });
      return response == true;
    } catch (e) {
      print('❌ Erreur remboursement: $e');
      return false;
    }
  }

  // 10. Exporter les utilisateurs en CSV
  void exportUsersToCSV(List<Map<String, dynamic>> users) {
    if (users.isEmpty) {
      print('⚠️ Aucun utilisateur à exporter');
      return;
    }

    List<String> rows = [];
    rows.add('ID,Nom,Email,Admin,Bloqué,Date inscription');

    for (var user in users) {
      String row = [
        user['id']?.toString() ?? '',
        _escapeCSV(user['full_name'] ?? 'Inconnu'),
        _escapeCSV(user['email'] ?? 'Inconnu'),
        user['is_admin'] == true ? 'Oui' : 'Non',
        user['is_blocked'] == true ? 'Oui' : 'Non',
        user['created_at']?.toString().substring(0, 10) ?? '',
      ].join(',');
      rows.add(row);
    }

    String csv = rows.join('\n');

    try {
      final blob = html.Blob([csv], 'text/csv;charset=utf-8;');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download =
            'utilisateurs_sen_relais_${DateTime.now().millisecondsSinceEpoch}.csv';

      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
      print('✅ CSV exporté avec succès (${users.length} utilisateurs)');
    } catch (e) {
      print('❌ Erreur export CSV: $e');
    }
  }

  String _escapeCSV(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  // 11. Récupérer toutes les assurances (pour admin)
  Future<List<Map<String, dynamic>>> getAllInsurances() async {
    try {
      final response = await _supabase
          .from('insurances')
          .select('*, users(full_name, email)')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erreur récupération assurances: $e');
      return [];
    }
  }

  // 12. Statistiques des assurances
  Future<Map<String, dynamic>> getInsuranceStats() async {
    try {
      final insurances =
          await _supabase.from('insurances').select('type, price, status');

      final totalInsurances = insurances.length;
      final totalRevenue = insurances.fold<double>(
        0.0,
        (sum, i) => sum + ((i['price'] as num?)?.toDouble() ?? 0.0),
      );

      Map<String, int> byType = {};
      for (var insurance in insurances) {
        String type = insurance['type'] ?? 'inconnu';
        byType[type] = (byType[type] ?? 0) + 1;
      }

      return {
        'totalInsurances': totalInsurances,
        'totalRevenue': totalRevenue,
        'byType': byType,
      };
    } catch (e) {
      print('❌ Erreur stats assurances: $e');
      return {'totalInsurances': 0, 'totalRevenue': 0.0, 'byType': {}};
    }
  }
}
