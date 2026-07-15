import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/insurance_model.dart';

class InsuranceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- TARIFS ET CALCULS (inchangés) ---
  static const Map<String, double> _basePrices = {
    'voyage': 15000,
    'sante': 25000,
    'auto': 45000,
  };

  static const Map<String, double> _coverageMultipliers = {
    'basique': 1.0,
    'standard': 1.5,
    'premium': 2.2,
  };

  double calculateVoyagePrice(
      {required String coverage,
      required int duration,
      required String destination}) {
    double basePrice = _basePrices['voyage']!;
    double multiplier = _coverageMultipliers[coverage] ?? 1.0;
    double extraDays = max(0, duration - 7) * 1500;
    double zoneMultiplier = 1.0;
    if (destination.toLowerCase().contains('europe') ||
        destination.toLowerCase().contains('france'))
      zoneMultiplier = 1.3;
    else if (destination.toLowerCase().contains('usa') ||
        destination.toLowerCase().contains('asie')) zoneMultiplier = 1.6;
    return (basePrice * multiplier + extraDays) * zoneMultiplier;
  }

  double calculateSantePrice(
      {required String coverage,
      required int age,
      required bool hasChronicDisease}) {
    double basePrice = _basePrices['sante']!;
    double multiplier = _coverageMultipliers[coverage] ?? 1.0;
    double ageFactor = age > 60 ? 1.5 : (age > 45 ? 1.2 : 1.0);
    double diseaseFactor = hasChronicDisease ? 1.4 : 1.0;
    return basePrice * multiplier * ageFactor * diseaseFactor;
  }

  double calculateAutoPrice(
      {required String coverage,
      required int vehicleAge,
      required String vehicleType}) {
    double basePrice = _basePrices['auto']!;
    double multiplier = _coverageMultipliers[coverage] ?? 1.0;
    Map<String, double> vehicleFactors = {
      'citadine': 0.9,
      'berline': 1.0,
      'suv': 1.3,
      'utilitaire': 1.4
    };
    double vehicleFactor = vehicleFactors[vehicleType] ?? 1.0;
    double ageFactor = max(0.7, 1.0 - (vehicleAge * 0.03));
    return basePrice * multiplier * vehicleFactor * ageFactor;
  }

  String generateReference() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'ASS-$timestamp-$random';
  }

  // --- SOUSCRIPTION RÉELLE DANS SUPABASE ---
  Future<InsuranceModel> subscribeInsurance({
    required String userId, // ✅ AJOUTÉ
    required String type,
    required String clientName,
    required String clientEmail,
    required String clientPhone,
    required double price,
    required String coverage,
    required DateTime startDate,
    required DateTime endDate,
    required Map<String, dynamic> details,
  }) async {
    final reference = generateReference();

    // 1. Préparer les données
    final insuranceData = {
      'user_id': userId,
      'type': type,
      'reference': reference,
      'client_name': clientName,
      'client_email': clientEmail,
      'client_phone': clientPhone,
      'price': price,
      'coverage': coverage,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'details': details,
      'status': 'active',
    };

    // 2. Insérer dans Supabase et récupérer la ligne créée
    final response = await _supabase
        .from('insurances')
        .insert(insuranceData)
        .select()
        .single();

    print('✅ Assurance sauvegardée en base : $reference');

    // 3. Retourner le modèle
    return InsuranceModel.fromMap(response);
  }

  // Récupérer les assurances d'un utilisateur
  Future<List<InsuranceModel>> getUserInsurances(String userId) async {
    try {
      final response = await _supabase
          .from('insurances')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map((data) => InsuranceModel.fromMap(data)).toList();
    } catch (e) {
      print('❌ Erreur récupération assurances: $e');
      return [];
    }
  }
}
