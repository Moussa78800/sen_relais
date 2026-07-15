import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/apartment_model.dart';

class RealEstateService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ApartmentModel>> getAvailableApartments() async {
    try {
      final response = await _supabase
          .from('apartments')
          .select()
          .eq('is_available', true)
          .order('created_at', ascending: false);

      return response.map((data) => ApartmentModel.fromMap(data)).toList();
    } catch (e) {
      print('❌ Erreur récupération appartements: $e');
      return [];
    }
  }
}
