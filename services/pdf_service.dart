import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import '../models/booking_model.dart';

class PdfService {
  static Future<Uint8List> generateBoardingPass(BookingModel booking) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // En-tête
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [PdfColor.fromInt(0xFFE30613), PdfColor.fromInt(0xFFB80000)],
                  ),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'SEN RELAIS',
                      style: pw.TextStyle(
                        fontSize: 32,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Billet d\'avion',
                      style: pw.TextStyle(
                        fontSize: 18,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Numéro de réservation
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColor.fromInt(0xFFE30613), width: 2),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Numéro de réservation',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      booking.bookingReference,
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFFE30613),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // QR Code
              pw.Container(
                width: 150,
                height: 150,
                child: pw.QrCodeWidget(
                  data: booking.bookingReference,
                  version: QrVersions.auto,
                  size: 150,
                ),
              ),

              pw.SizedBox(height: 30),

              // Détails du vol
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Détails du vol',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFFE30613),
                      ),
                    ),
                    pw.SizedBox(height: 15),
                    _buildDetailRow('Compagnie', booking.airlineName),
                    _buildDetailRow('Vol', booking.flightNumber),
                    _buildDetailRow('Passager', booking.passengerName),
                    _buildDetailRow('Classe', booking.seatClassLabel),
                    pw.SizedBox(height: 15),
                    pw.Divider(color: PdfColors.grey300),
                    pw.SizedBox(height: 15),
                    _buildDetailRow('Départ', '${booking.departureIata} - ${booking.formattedDepartureTime}'),
                    _buildDetailRow('Arrivée', '${booking.arrivalIata} - ${booking.formattedArrivalTime}'),
                    pw.SizedBox(height: 15),
                    pw.Divider(color: PdfColors.grey300),
                    pw.SizedBox(height: 15),
                    _buildDetailRow('Montant payé', booking.formattedPrice),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Text(
                'Merci d\'avoir choisi SEN RELAIS',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey,
                ),
              ),
              pw.Text(
                'www.senrelais.com',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}