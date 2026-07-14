import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_model.dart';

class EmailService {
  // ✅ Lecture sécurisée de la clé
  static const String _accessKey =
      String.fromEnvironment('WEB3FORMS_ACCESS_KEY', defaultValue: '');

  static Future<bool> sendBookingConfirmation(BookingModel booking) async {
    try {
      if (_accessKey.isEmpty || _accessKey.contains('collez_votre')) {
        print('⚠️ WEB3FORMS_ACCESS_KEY manquante dans le fichier .env');
        return false;
      }

      print('📧 Envoi automatique de l\'email à ${booking.passengerEmail}...');

      // 1. Construire le contenu de l'email
      final messageBody = '''
Bonjour ${booking.passengerName},

Merci d'avoir choisi SEN RELAIS pour votre voyage ! 🌍

Votre réservation a été confirmée et votre wallet a été débité avec succès.

📄 RÉCAPITULATIF DE LA RÉSERVATION :
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎫 Référence : ${booking.bookingReference}
✈️ Vol : ${booking.airlineName} (${booking.flightNumber})
🛫 Départ : ${booking.departureCity} (${booking.departureIata}) le ${booking.formattedDepartureTime}
🛬 Arrivée : ${booking.arrivalCity} (${booking.arrivalIata}) le ${booking.formattedArrivalTime}
👤 Passager : ${booking.passengerName}
💺 Classe : ${booking.seatClassLabel}
💰 Montant payé : ${booking.formattedPrice}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Nous vous souhaitons un excellent voyage ! 

Cordialement,
L'équipe SEN RELAIS
https://senrelais.netlify.app
      ''';

      // 2. Préparer la requête HTTP pour Web3Forms
      final url = Uri.parse('https://api.web3forms.com/submit');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'access_key': _accessKey,
          'subject':
              'Confirmation de réservation SEN RELAIS - ${booking.bookingReference}',
          'from_name': 'SEN RELAIS',
          'email': booking.passengerEmail, // L'email du passager
          'message': messageBody, // Le corps du mail
          'replyto':
              'ndiayemoussa7816@gmail.com', // Pour que vous receviez une copie
        }),
      );

      // 3. Vérifier la réponse du serveur
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('✅ Email envoyé automatiquement avec succès !');
          return true;
        }
      }

      print('❌ Échec de l\'envoi Web3Forms: ${response.body}');
      return false;
    } catch (e) {
      print('❌ Erreur lors de l\'envoi de l\'email: $e');
      return false;
    }
  }
}
