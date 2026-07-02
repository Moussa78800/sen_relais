import 'package:flutter/material.dart';
import '../models/flight_model.dart';
import '../services/booking_service.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'booking_confirmation_screen.dart';
import '../services/email_service.dart';

class PaymentScreen extends StatefulWidget {
  final FlightModel flight;
  final String passengerName;
  final String passengerEmail;
  final String? passengerPhone;
  final String seatClass;

  const PaymentScreen({
    super.key,
    required this.flight,
    required this.passengerName,
    required this.passengerEmail,
    this.passengerPhone,
    required this.seatClass,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _bookingService = BookingService();
  final _dbService = DatabaseService();
  final _authService = AuthService();
  
  double _walletBalance = 0.0;
  bool _isLoading = true;
  bool _isProcessing = false;

  double get _adjustedPrice {
    double multiplier = 1.0;
    switch (widget.seatClass) {
      case 'business':
        multiplier = 2.5;
        break;
      case 'first':
        multiplier = 4.0;
        break;
    }
    return (widget.flight.price ?? 0) * multiplier;
  }

  @override
  void initState() {
    super.initState();
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    final userId = _authService.currentUser?.id;
    if (userId != null) {
      final balance = await _dbService.getWalletBalance(userId);
      if (mounted) {
        setState(() {
          _walletBalance = balance;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processPayment() async {
    if (_walletBalance < _adjustedPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solde insuffisant. Veuillez recharger votre wallet.'),
          backgroundColor: Color(0xFFE30613),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final booking = await _bookingService.createBooking(
        userId: userId,
        flight: widget.flight,
        passengerName: widget.passengerName,
        passengerEmail: widget.passengerEmail,
        passengerPhone: widget.passengerPhone,
        seatClass: widget.seatClass,
      );

      if (!mounted) return;

      if (booking != null) {
  // Envoyer l'email de confirmation
        await EmailService.sendBookingConfirmation(booking);
  
        Navigator.pushAndRemoveUntil(
          context,
            MaterialPageRoute(
              builder: (context) => BookingConfirmationScreen(booking: booking),
            ),
            (route) => route.isFirst,
        );
} else {
        throw Exception('Échec de la création de la réservation');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: const Color(0xFFE30613),
        ),
      );
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFE30613)),
        ),
      );
    }

    final hasEnoughBalance = _walletBalance >= _adjustedPrice;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE30613),
        foregroundColor: Colors.white,
        title: const Text(
          'Paiement',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Résumé du vol
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Récapitulatif du vol',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.flight.formattedDepartureTime,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.flight.departureIATA,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.flight,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.flight.formattedArrivalTime,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            Text(
                              widget.flight.arrivalIATA,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${widget.flight.airlineName} • ${widget.flight.flightNumber}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Informations passager
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
                    'Passager',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Nom', widget.passengerName),
                  const SizedBox(height: 8),
                  _buildInfoRow('Email', widget.passengerEmail),
                  if (widget.passengerPhone != null && widget.passengerPhone!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow('Téléphone', widget.passengerPhone!),
                  ],
                  const SizedBox(height: 8),
                  _buildInfoRow('Classe', _getSeatClassLabel()),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Wallet
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: hasEnoughBalance
                    ? Colors.green.withOpacity(0.05)
                    : Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasEnoughBalance ? Colors.green : Colors.orange,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: hasEnoughBalance ? Colors.green : Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Votre Wallet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Solde actuel',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${_walletBalance.toStringAsFixed(0)} XOF',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: hasEnoughBalance ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Montant à payer',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${_adjustedPrice.toStringAsFixed(0)} XOF',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE30613),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Solde après paiement',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${(_walletBalance - _adjustedPrice).toStringAsFixed(0)} XOF',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: hasEnoughBalance ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Bouton payer
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasEnoughBalance
                      ? const Color(0xFFE30613)
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            hasEnoughBalance
                                ? 'Payer ${_adjustedPrice.toStringAsFixed(0)} XOF'
                                : 'Solde insuffisant',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getSeatClassLabel() {
    switch (widget.seatClass) {
      case 'economy':
        return 'Économique';
      case 'business':
        return 'Business';
      case 'first':
        return 'Première';
      default:
        return widget.seatClass;
    }
  }
}