import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../models/booking_model.dart';
import '../services/pdf_service.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final BookingModel booking;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _isGenerating = false;

  Future<void> _downloadBoardingPass() async {
    setState(() => _isGenerating = true);

    try {
      final pdfBytes = await PdfService.generateBoardingPass(widget.booking);

      // Créer un blob et télécharger
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute(
            "download", "billet_${widget.booking.bookingReference}.pdf")
        ..click();
      html.Url.revokeObjectUrl(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Billet téléchargé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: const Color(0xFFE30613),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE30613),
        foregroundColor: Colors.white,
        title: const Text(
          'Confirmation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check,
                size: 60,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Réservation confirmée !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE30613),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Votre vol a été réservé avec succès',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE30613), Color(0xFFB80000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Numéro de réservation',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.booking.bookingReference,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Détails du vol',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Compagnie', widget.booking.airlineName),
                  const SizedBox(height: 8),
                  _buildDetailRow('Vol', widget.booking.flightNumber),
                  const SizedBox(height: 8),
                  _buildDetailRow('Départ',
                      '${widget.booking.departureIata} - ${widget.booking.departureCity}'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Arrivée',
                      '${widget.booking.arrivalIata} - ${widget.booking.arrivalCity}'),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                      'Date départ', widget.booking.formattedDepartureTime),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                      'Date arrivée', widget.booking.formattedArrivalTime),
                  const SizedBox(height: 8),
                  _buildDetailRow('Passager', widget.booking.passengerName),
                  const SizedBox(height: 8),
                  _buildDetailRow('Classe', widget.booking.seatClassLabel),
                  const Divider(height: 24),
                  _buildDetailRow('Montant payé', widget.booking.formattedPrice,
                      isHighlighted: true),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Bouton télécharger le billet
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _downloadBoardingPass,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.download, size: 24),
                label: Text(
                  _isGenerating ? 'Génération...' : 'Télécharger le billet PDF',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE30613),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Bouton retour à l'accueil
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                icon: const Icon(Icons.home, size: 24),
                label: const Text(
                  'Retour à l\'accueil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE30613),
                  side: const BorderSide(color: Color(0xFFE30613), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isHighlighted = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            color: isHighlighted ? const Color(0xFFE30613) : Colors.black87,
          ),
        ),
      ],
    );
  }
}
