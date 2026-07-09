// ignore_for_file: avoid_print

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';
import '../models/flight_model.dart';

class BookingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String _generateBookingReference() {
    final timestamp =
        DateTime.now().millisecondsSinceEpoch.toString().substring(5);
    final random = (DateTime.now().millisecond % 9000 + 1000).toString();
    return 'SR-$timestamp-$random';
  }

  Future<BookingModel?> createBooking({
    required String userId,
    required FlightModel flight,
    required String passengerName,
    required String passengerEmail,
    String? passengerPhone,
    String seatClass = 'economy',
  }) async {
    try {
      print('🔵 Création de la réservation...');

      final debitResult = await _supabase.rpc('debit_wallet', params: {
        'p_user_id': userId,
        'p_amount': flight.price?.toDouble() ?? 0,
        'p_description': 'Réservation vol ${flight.flightNumber}',
        'p_reference': 'BOOK-${DateTime.now().millisecondsSinceEpoch}',
      });

      if (debitResult != true) {
        throw Exception('Échec du paiement. Solde insuffisant.');
      }

      print('✅ Wallet débité');

      final bookingRef = _generateBookingReference();

      final response = await _supabase
          .from('bookings')
          .insert({
            'user_id': userId,
            'booking_reference': bookingRef,
            'flight_number': flight.flightNumber,
            'airline_name': flight.airlineName,
            'airline_iata': flight.airlineIATA,
            'departure_airport': flight.departureAirport,
            'departure_iata': flight.departureIATA,
            'departure_city': flight.departureCity,
            'departure_time': flight.departureScheduled,
            'arrival_airport': flight.arrivalAirport,
            'arrival_iata': flight.arrivalIATA,
            'arrival_city': flight.arrivalCity,
            'arrival_time': flight.arrivalScheduled,
            'passenger_name': passengerName,
            'passenger_email': passengerEmail,
            'passenger_phone': passengerPhone,
            'seat_class': seatClass,
            'price': flight.price?.toDouble() ?? 0,
            'currency': 'XOF',
            'status': 'confirmed',
            'payment_method': 'wallet',
          })
          .select()
          .single();

      print('✅ Réservation créée: $bookingRef');

      return BookingModel.fromMap(response);
    } catch (e) {
      print('❌ Erreur création réservation: $e');
      throw Exception('Erreur lors de la réservation: $e');
    }
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('user_id', userId)
          .order('departure_time', ascending: false);

      return response.map((map) => BookingModel.fromMap(map)).toList();
    } catch (e) {
      print('❌ Erreur récupération réservations: $e');
      return [];
    }
  }
}
