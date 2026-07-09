import '../models/booking_model.dart';

class EmailService {
  static Future<bool> sendBookingConfirmation(BookingModel booking) async {
    try {
      // Pour l'instant, on désactive l'envoi d'email car il faut configurer Gmail
      print('⚠️ Email désactivé - Configuration Gmail requise');
      print('📧 Email de confirmation pour: ${booking.passengerEmail}');
      return false;
    } catch (e) {
      print('❌ Erreur envoi email: $e');
      return false;
    }
  }
}
