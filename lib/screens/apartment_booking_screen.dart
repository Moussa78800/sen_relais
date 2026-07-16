import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/apartment_model.dart';

class ApartmentBookingScreen extends StatefulWidget {
  final ApartmentModel apartment;

  const ApartmentBookingScreen({super.key, required this.apartment});

  @override
  State<ApartmentBookingScreen> createState() => _ApartmentBookingScreenState();
}

class _ApartmentBookingScreenState extends State<ApartmentBookingScreen> {
  final _supabase = Supabase.instance.client;

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _durationMonths = 1;
  bool _isBooking = false;

  double get _totalPrice => widget.apartment.pricePerMonth * _durationMonths;
  double get _caution =>
      widget.apartment.location.contains('Louis Lassere') ? 250000 : 0;
  double get _grandTotal => _totalPrice + _caution;

  Future<void> _selectCheckInDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _checkInDate = picked;
        _checkOutDate = picked.add(Duration(days: _durationMonths * 30));
      });
    }
  }

  Future<void> _bookApartment() async {
    if (_checkInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez sélectionner une date d\'entrée'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isBooking = true);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Vous devez être connecté');

      // 1. Vérifier le solde du wallet
      final walletResponse = await _supabase
          .from('wallets')
          .select('balance')
          .eq('user_id', userId)
          .single();

      final balance = (walletResponse['balance'] as num?)?.toDouble() ?? 0.0;

      if (balance < _grandTotal) {
        throw Exception(
            'Solde insuffisant. Vous avez ${balance.toStringAsFixed(0)} XOF, il vous faut ${_grandTotal.toStringAsFixed(0)} XOF');
      }

      // 2. Débiter le wallet
      final newBalance = balance - _grandTotal;
      await _supabase
          .from('wallets')
          .update({'balance': newBalance}).eq('user_id', userId);

      // 3. Créer la réservation
      await _supabase.from('apartment_bookings').insert({
        'user_id': userId,
        'apartment_id': widget.apartment.id,
        'apartment_title': widget.apartment.title,
        'apartment_location': widget.apartment.location,
        'check_in_date': _checkInDate!.toIso8601String(),
        'check_out_date': _checkOutDate!.toIso8601String(),
        'duration_months': _durationMonths,
        'price_per_month': widget.apartment.pricePerMonth,
        'total_price': _totalPrice,
        'caution_amount': _caution,
        'status': 'confirmed',
      });

      // 4. Afficher la confirmation
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('Réservation confirmée !'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Votre réservation a été enregistrée avec succès.'),
                const SizedBox(height: 12),
                Text('Appartement : ${widget.apartment.title}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                    'Date d\'entrée : ${DateFormat('dd/MM/yyyy').format(_checkInDate!)}'),
                Text('Durée : $_durationMonths mois'),
                const SizedBox(height: 12),
                Text('Total payé : ${_grandTotal.toStringAsFixed(0)} XOF',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFFE30613))),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE30613)),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

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
          'Réserver cet appartement',
          style:
              TextStyle(color: Color(0xFFE30613), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Résumé de l'appartement
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.apartment.title,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Color(0xFFE30613)),
                        const SizedBox(width: 4),
                        Expanded(
                            child: Text(widget.apartment.location,
                                style:
                                    const TextStyle(color: Color(0xFFE30613)))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Loyer mensuel : ${widget.apartment.formattedPrice}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE30613))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sélection de la date d'entrée
            const Text('Date d\'entrée',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectCheckInDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE30613)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFFE30613)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _checkInDate != null
                            ? dateFormat.format(_checkInDate!)
                            : 'Sélectionnez une date',
                        style: TextStyle(
                            color: _checkInDate != null
                                ? Colors.black
                                : Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Durée du séjour
            const Text('Durée du séjour',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: _durationMonths > 1
                      ? () => setState(() => _durationMonths--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: const Color(0xFFE30613),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$_durationMonths mois',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _durationMonths++),
                  icon: const Icon(Icons.add_circle_outline),
                  color: const Color(0xFFE30613),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Récapitulatif du prix
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE30613).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE30613), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Récapitulatif',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Loyer ($_durationMonths mois)'),
                      Text('${_totalPrice.toStringAsFixed(0)} XOF',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (_caution > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Caution'),
                        Text('${_caution.toStringAsFixed(0)} XOF',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total à payer',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        '${_grandTotal.toStringAsFixed(0)} XOF',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE30613)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Bouton de réservation
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isBooking ? null : _bookApartment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE30613),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isBooking
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Payer avec mon Wallet',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
