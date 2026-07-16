import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyApartmentBookingsScreen extends StatefulWidget {
  const MyApartmentBookingsScreen({super.key});

  @override
  State<MyApartmentBookingsScreen> createState() =>
      _MyApartmentBookingsScreenState();
}

class _MyApartmentBookingsScreenState extends State<MyApartmentBookingsScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    final userId = _supabase.auth.currentUser?.id;

    if (userId != null) {
      final response = await _supabase
          .from('apartment_bookings')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _bookings = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } else {
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
          'Mes Locations',
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
              ? const Center(child: Text('Aucune réservation immobilière'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) =>
                      _buildBookingCard(_bookings[index]),
                ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final checkIn = DateTime.parse(booking['check_in_date']);
    final checkOut = DateTime.parse(booking['check_out_date']);
    final totalPrice = (booking['total_price'] as num?)?.toDouble() ?? 0.0;
    final caution = (booking['caution_amount'] as num?)?.toDouble() ?? 0.0;
    final grandTotal = totalPrice + caution;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking['apartment_title'] ?? 'Appartement',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on,
                    size: 16, color: Color(0xFFE30613)),
                const SizedBox(width: 4),
                Expanded(
                    child: Text(booking['apartment_location'] ?? '',
                        style: const TextStyle(color: Color(0xFFE30613)))),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Entrée',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Text(dateFormat.format(checkIn),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Durée',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Text('${booking['duration_months']} mois',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Sortie',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Text(dateFormat.format(checkOut),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE30613).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total payé', style: TextStyle(color: Colors.grey[700])),
                  Text(
                    '${grandTotal.toStringAsFixed(0)} XOF',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE30613)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
