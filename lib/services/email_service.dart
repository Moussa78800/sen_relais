import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/booking_model.dart';

class EmailService {
  // Envoyer un email de confirmation de réservation
  static Future<bool> sendBookingConfirmation(BookingModel booking) async {
    try {
      final username = dotenv.env['EMAIL_USERNAME'] ?? '';
      final password = dotenv.env['EMAIL_PASSWORD'] ?? '';

      if (username.isEmpty || password.isEmpty) {
        print('⚠️ Configuration email manquante dans .env');
        return false;
      }

      final smtpServer = gmail(username, password);

      final message = Message()
        ..from = Address(username, 'SEN RELAIS')
        ..recipients.add(booking.passengerEmail)
        ..subject = 'Confirmation de réservation - ${booking.bookingReference}'
        ..html = _buildEmailTemplate(booking);

      await send(message, smtpServer);
      print('✅ Email de confirmation envoyé à ${booking.passengerEmail}');
      return true;
    } catch (e) {
      print('❌ Erreur envoi email: $e');
      return false;
    }
  }

  static String _buildEmailTemplate(BookingModel booking) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background: linear-gradient(135deg, #E30613, #B80000); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
    .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
    .booking-ref { background: white; padding: 20px; border-radius: 8px; margin: 20px 0; text-align: center; }
    .booking-ref h2 { color: #E30613; margin: 0; font-size: 28px; letter-spacing: 2px; }
    .flight-details { background: white; padding: 20px; border-radius: 8px; margin: 20px 0; }
    .flight-row { display: flex; justify-content: space-between; margin: 15px 0; }
    .flight-info { text-align: center; }
    .flight-info h3 { color: #E30613; margin: 0; font-size: 24px; }
    .footer { text-align: center; margin-top: 30px; color: #666; font-size: 12px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>🎉 Réservation Confirmée !</h1>
      <p>Votre vol a été réservé avec succès</p>
    </div>
    
    <div class="content">
      <div class="booking-ref">
        <p style="margin: 0; color: #666;">Numéro de réservation</p>
        <h2>${booking.bookingReference}</h2>
      </div>

      <div class="flight-details">
        <h3 style="color: #E30613; margin-top: 0;">Détails du vol</h3>
        
        <div class="flight-row">
          <div class="flight-info">
            <p style="margin: 0; color: #666; font-size: 12px;">Départ</p>
            <h3>${booking.departureIata}</h3>
            <p style="margin: 5px 0;">${booking.formattedDepartureTime}</p>
          </div>
          
          <div style="align-self: center; font-size: 32px;">✈️</div>
          
          <div class="flight-info">
            <p style="margin: 0; color: #666; font-size: 12px;">Arrivée</p>
            <h3>${booking.arrivalIata}</h3>
            <p style="margin: 5px 0;">${booking.formattedArrivalTime}</p>
          </div>
        </div>

        <hr style="margin: 20px 0; border: none; border-top: 1px solid #ddd;">
        
        <p><strong>Compagnie :</strong> ${booking.airlineName}</p>
        <p><strong>Vol :</strong> ${booking.flightNumber}</p>
        <p><strong>Passager :</strong> ${booking.passengerName}</p>
        <p><strong>Classe :</strong> ${booking.seatClassLabel}</p>
        <p><strong>Montant payé :</strong> <span style="color: #E30613; font-weight: bold;">${booking.formattedPrice}</span></p>
      </div>

      <p style="text-align: center; margin-top: 30px;">
        Merci d'avoir choisi SEN RELAIS !<br>
        <a href="https://senrelais.vercel.app" style="color: #E30613; text-decoration: none;">www.senrelais.com</a>
      </p>
    </div>

    <div class="footer">
      <p>Cet email a été envoyé automatiquement. Veuillez ne pas y répondre.</p>
      <p>© 2026 SEN RELAIS - Tous droits réservés</p>
    </div>
  </div>
</body>
</html>
''';
  }
}