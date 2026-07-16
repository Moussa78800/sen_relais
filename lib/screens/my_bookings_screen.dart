import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;

    print('🔍 ID Utilisateur actuel (Auth): $userId');

    if (userId != null) {
      final bookings = await _authService.getUserBookings(userId);
      print('📦 Réservations trouvées: ${bookings.length}');

      if (mounted) {
        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      }
    } else {
      print('⚠️ Aucun utilisateur connecté');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE30613),
        elevation: 0,
        title: const Text(
          'Mes Réservations',
          style:
              TextStyle(color: Color(0xFFE30613), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBookings),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE30613)))
          : _bookings.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) =>
                        _buildBookingCard(_bookings[index]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.airplane_ticket_outlined,
              size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Aucune réservation',
              style: TextStyle(fontSize: 20, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Réservez votre premier vol',
              style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.flight),
            label: const Text('Rechercher un vol'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE30613),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final status = booking['status'] ?? 'confirmed';
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    // ✅ Fonction sécurisée pour parser les dates (évite les crashes si null)
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null) return null;
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return null;
      }
    }

    final depDate = parseDate(booking['departure_time']);
    final arrDate = parseDate(booking['arrival_time']);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['booking_reference'] ?? 'Réservation',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Compagnie: ${booking['airline_name'] ?? 'N/A'}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Trajet
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['departure_iata'] ?? '???',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        booking['departure_city'] ??
                            booking['departure_airport'] ??
                            '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        depDate != null
                            ? dateFormat.format(depDate)
                            : 'Date inconnue',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward,
                    color: Color(0xFFE30613), size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        booking['arrival_iata'] ?? '???',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        booking['arrival_city'] ??
                            booking['arrival_airport'] ??
                            '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        arrDate != null
                            ? dateFormat.format(arrDate)
                            : 'Date inconnue',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Informations passager et prix
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Passager',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Text(
                      booking['passenger_name'] ?? 'N/A',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Prix total',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Text(
                      '${(booking['price'] as num?)?.toStringAsFixed(0) ?? '0'} XOF',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE30613),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Classe de siège
            Row(
              children: [
                const Icon(Icons.airline_seat_recline_normal,
                    size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Classe: ${(booking['seat_class'] ?? 'Économique').toString().toUpperCase()}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmée';
      case 'cancelled':
        return 'Annulée';
      case 'refunded':
        return 'Remboursée';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'refunded':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
