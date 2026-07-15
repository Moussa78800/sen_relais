import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/insurance_service.dart';
import '../models/insurance_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ✅ AJOUTEZ CECI

class InsuranceSummaryScreen extends StatefulWidget {
  final String insuranceType;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final double price;
  final String coverage;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> details;

  const InsuranceSummaryScreen({
    super.key,
    required this.insuranceType,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.price,
    required this.coverage,
    required this.startDate,
    required this.endDate,
    required this.details,
  });

  @override
  State<InsuranceSummaryScreen> createState() => _InsuranceSummaryScreenState();
}

class _InsuranceSummaryScreenState extends State<InsuranceSummaryScreen> {
  final _insuranceService = InsuranceService();
  bool _isSubscribing = false;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE30613),
        elevation: 0,
        title: const Text(
          'Récapitulatif',
          style: TextStyle(
            color: Color(0xFFE30613),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE30613), Color(0xFFB80000)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(_getTypeIcon(), color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    _getTypeTitle(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Couverture ${widget.coverage}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Informations client
            _buildSection(
              'Informations client',
              [
                _buildInfoRow('Nom', widget.clientName),
                _buildInfoRow('Email', widget.clientEmail),
                _buildInfoRow('Téléphone', widget.clientPhone),
              ],
            ),
            const SizedBox(height: 16),

            // Détails spécifiques
            _buildSection(
              'Détails',
              _buildSpecificDetails(),
            ),
            const SizedBox(height: 16),

            // Période de couverture
            _buildSection(
              'Période de couverture',
              [
                _buildInfoRow('Début', dateFormat.format(widget.startDate)),
                _buildInfoRow('Fin', dateFormat.format(widget.endDate)),
              ],
            ),
            const SizedBox(height: 24),

            // Prix total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE30613).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE30613), width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total à payer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${widget.price.toStringAsFixed(0)} XOF',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE30613),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Bouton de souscription
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubscribing ? null : _subscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE30613),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubscribing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Confirmer la souscription',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (widget.insuranceType) {
      case 'voyage':
        return Icons.flight_takeoff;
      case 'sante':
        return Icons.local_hospital;
      case 'auto':
        return Icons.directions_car;
      default:
        return Icons.shield;
    }
  }

  String _getTypeTitle() {
    switch (widget.insuranceType) {
      case 'voyage':
        return 'Assurance Voyage';
      case 'sante':
        return 'Assurance Santé';
      case 'auto':
        return 'Assurance Auto';
      default:
        return 'Assurance';
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  List<Widget> _buildSpecificDetails() {
    List<Widget> rows = [];

    switch (widget.insuranceType) {
      case 'voyage':
        rows.add(
            _buildInfoRow('Destination', widget.details['destination'] ?? '-'));
        rows.add(_buildInfoRow('Durée', '${widget.details['duration']} jours'));
        break;
      case 'sante':
        rows.add(_buildInfoRow('Âge', '${widget.details['age']} ans'));
        rows.add(_buildInfoRow(
          'Maladie chronique',
          widget.details['has_chronic_disease'] == true ? 'Oui' : 'Non',
        ));
        break;
      case 'auto':
        rows.add(_buildInfoRow(
            'Type véhicule', widget.details['vehicle_type'] ?? '-'));
        rows.add(_buildInfoRow(
            'Âge véhicule', '${widget.details['vehicle_age']} ans'));
        break;
    }

    return rows;
  }

  Future<void> _subscribe() async {
    setState(() => _isSubscribing = true);

    try {
      // ✅ Récupérer l'ID de l'utilisateur connecté
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Vous devez être connecté pour souscrire.');
      }

      final insurance = await _insuranceService.subscribeInsurance(
        userId: userId, // ✅ PASSER L'ID ICI
        type: widget.insuranceType,
        clientName: widget.clientName,
        clientEmail: widget.clientEmail,
        clientPhone: widget.clientPhone,
        price: widget.price,
        coverage: widget.coverage,
        startDate: widget.startDate,
        endDate: widget.endDate,
        details: widget.details,
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('Souscription réussie !'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Votre assurance a été activée et sauvegardée.'),
                const SizedBox(height: 12),
                Text(
                  'Référence : ${insurance.reference}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer le dialog
                  Navigator.of(context).pop(); // Fermer le récapitulatif
                  Navigator.of(context).pop(); // Fermer le formulaire
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE30613),
                ),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubscribing = false);
      }
    }
  }
}
