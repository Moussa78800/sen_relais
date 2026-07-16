import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:universal_html/html.dart' as html;

class AdminService {
  final SupabaseClient _supabase = Supabase.instance.client;

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
        'averageBasket': averageBasket
      };
    } catch (e) {
      print('❌ Erreur stats avancées: $e');
      return {'totalBookings': 0, 'totalRevenue': 0.0, 'averageBasket': 0.0};
    }
  }

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
      return {};
    }
  }

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
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _supabase.rpc('get_all_users_for_admin');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<bool> toggleUserBlock(String userId, bool isBlocked) async {
    try {
      await _supabase
          .from('users')
          .update({'is_blocked': isBlocked}).eq('id', userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await _supabase.from('users').delete().eq('id', userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _supabase
          .from('bookings')
          .update({'status': 'cancelled'}).eq('id', bookingId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> refundBooking(String bookingId, double amount) async {
    try {
      final response = await _supabase.rpc('refund_booking',
          params: {'booking_id': bookingId, 'refund_amount': amount});
      return response == true;
    } catch (e) {
      return false;
    }
  }

  void exportUsersToCSV(List<Map<String, dynamic>> users) {
    print('📥 Début de l\'export CSV...');
    print('📊 Nombre d\'utilisateurs à exporter : ${users.length}');

    if (users.isEmpty) {
      print('⚠️ Liste vide, rien à exporter');
      return;
    }

    // 1. Générer le contenu CSV
    List<String> rows = [
      'ID,Nom,Email,Téléphone,Admin,Bloqué,Date inscription'
    ];

    for (var user in users) {
      String row = [
        user['id']?.toString() ?? '',
        _escapeCSV(user['full_name'] ?? 'Inconnu'),
        _escapeCSV(user['email'] ?? 'Inconnu'),
        _escapeCSV(user['phone'] ?? ''),
        user['is_admin'] == true ? 'Oui' : 'Non',
        user['is_blocked'] == true ? 'Oui' : 'Non',
        user['created_at']?.toString().substring(0, 10) ?? '',
      ].join(',');
      rows.add(row);
    }

    String csv = rows.join('\n');
    print('✅ CSV généré (${csv.length} caractères)');

    // 2. Télécharger le fichier (version simplifiée pour Flutter Web)
    try {
      // Créer un Blob
      final bytes = utf8.encode(csv);
      final blob = html.Blob([bytes], 'text/csv;charset=utf-8;');

      // Créer une URL temporaire
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Créer un lien de téléchargement
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download =
            'utilisateurs_sen_relais_${DateTime.now().millisecondsSinceEpoch}.csv';

      // Ajouter au DOM, cliquer, puis supprimer
      html.document.body?.children.add(anchor);
      anchor.click();

      // Nettoyage
      Future.delayed(const Duration(milliseconds: 100), () {
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
      });

      print('✅ Téléchargement déclenché avec succès');
    } catch (e) {
      print('❌ Erreur lors du téléchargement: $e');
      // Solution de secours : ouvrir dans un nouvel onglet
      try {
        final dataUri =
            'data:text/csv;charset=utf-8,${Uri.encodeComponent(csv)}';
        html.window.open(dataUri, '_blank');
        print('✅ Ouverture dans un nouvel onglet (solution de secours)');
      } catch (e2) {
        print('❌ Même la solution de secours a échoué: $e2');
      }
    }
  }

  String _escapeCSV(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  Future<List<Map<String, dynamic>>> getAllInsurances() async {
    try {
      final response = await _supabase
          .from('insurances')
          .select('*, users(full_name, email)')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getInsuranceStats() async {
    try {
      final insurances =
          await _supabase.from('insurances').select('type, price, status');
      final totalInsurances = insurances.length;
      final totalRevenue = insurances.fold<double>(
          0.0, (sum, i) => sum + ((i['price'] as num?)?.toDouble() ?? 0.0));
      Map<String, int> byType = {};
      for (var insurance in insurances) {
        String type = insurance['type'] ?? 'inconnu';
        byType[type] = (byType[type] ?? 0) + 1;
      }
      return {
        'totalInsurances': totalInsurances,
        'totalRevenue': totalRevenue,
        'byType': byType
      };
    } catch (e) {
      return {'totalInsurances': 0, 'totalRevenue': 0.0, 'byType': {}};
    }
  }

  // 🏠 NOUVEAU : Statistiques Immobilières (CA et Nombre de locations)
  Future<Map<String, dynamic>> getRealEstateStats() async {
    try {
      // On prend uniquement les réservations confirmées pour le CA réel
      final bookings = await _supabase
          .from('apartment_bookings')
          .select('total_price, caution_amount, status')
          .eq('status', 'confirmed');

      final totalBookings = bookings.length;

      // Le CA inclut le loyer total + la caution encaissée
      final totalRevenue = bookings.fold<double>(
        0.0,
        (sum, b) {
          double price = (b['total_price'] as num?)?.toDouble() ?? 0.0;
          double caution = (b['caution_amount'] as num?)?.toDouble() ?? 0.0;
          return sum + price + caution;
        },
      );

      return {
        'totalBookings': totalBookings,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      print('❌ Erreur stats immobilier: $e');
      return {'totalBookings': 0, 'totalRevenue': 0.0};
    }
  }

  Future<List<Map<String, dynamic>>> getAllApartments() async {
    try {
      final response = await _supabase
          .from('apartments')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateApartment(
      String apartmentId, Map<String, dynamic> updates) async {
    try {
      await _supabase.from('apartments').update(updates).eq('id', apartmentId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleApartmentAvailability(
      String apartmentId, bool isAvailable) async {
    try {
      await _supabase
          .from('apartments')
          .update({'is_available': isAvailable}).eq('id', apartmentId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteApartment(String apartmentId) async {
    try {
      await _supabase.from('apartments').delete().eq('id', apartmentId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
