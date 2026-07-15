import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/admin_service.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;

  Map<String, dynamic> _stats = {};
  Map<String, int> _seatDistribution = {};
  List<Map<String, dynamic>> _recentBookings = [];
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _insurances = [];
  Map<String, dynamic> _insuranceStats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final results = await Future.wait([
      _adminService.getAdvancedStats(),
      _adminService.getSeatClassDistribution(),
      _adminService.getRecentBookingsForManagement(limit: 5),
      _adminService.getAllUsers(),
      _adminService.getAllInsurances(),
      _adminService.getInsuranceStats(),
    ]);

    setState(() {
      _stats = results[0] as Map<String, dynamic>;
      _seatDistribution = results[1] as Map<String, int>;
      _recentBookings = results[2] as List<Map<String, dynamic>>;
      _users = results[3] as List<Map<String, dynamic>>;
      _insurances = results[4] as List<Map<String, dynamic>>;
      _insuranceStats = results[5] as Map<String, dynamic>;
      _isLoading = false;
    });

    print('✅ Données chargées !');
    print('👥 Nombre d\'utilisateurs : ${_users.length}');
    print('🛡️ Nombre d\'assurances : ${_insurances.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin Complet'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Cartes de résumé
                    Row(
                      children: [
                        Expanded(
                            child: _buildSummaryCard(
                                'Revenus',
                                '${(_stats['totalRevenue'] ?? 0.0).toStringAsFixed(0)} XOF',
                                Icons.attach_money,
                                Colors.green)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildSummaryCard(
                                'Réservations',
                                '${_stats['totalBookings'] ?? 0}',
                                Icons.flight_takeoff,
                                Colors.blue)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: _buildSummaryCard(
                                'Panier Moyen',
                                '${(_stats['averageBasket'] ?? 0.0).toStringAsFixed(0)} XOF',
                                Icons.shopping_cart,
                                Colors.orange)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _adminService.exportUsersToCSV(_users),
                            icon:
                                const Icon(Icons.download, color: Colors.white),
                            label: const Text('Export CSV',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE30613),
                              minimumSize: const Size.fromHeight(80),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 2. Graphique Camembert
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('📊 Répartition par Classe de Siège',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            SizedBox(height: 250, child: _buildPieChart()),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. Gestion des Utilisateurs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('👥 Gestion des Utilisateurs',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('${_users.length} total',
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 2,
                      child: Column(
                        children: _users.take(10).map((user) {
                          final isBlocked = user['is_blocked'] == true;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isBlocked
                                  ? Colors.grey
                                  : (user['is_admin'] == true
                                      ? Colors.red
                                      : Colors.blue),
                              child: Text(
                                  (user['full_name'] ?? '?')[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text(user['full_name'] ?? 'Sans nom'),
                            subtitle: Text(user['email'] ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (user['is_admin'] != true) ...[
                                  IconButton(
                                    icon: Icon(
                                        isBlocked
                                            ? Icons.lock_open
                                            : Icons.lock,
                                        color: isBlocked
                                            ? Colors.orange
                                            : Colors.red),
                                    onPressed: () async {
                                      await _adminService.toggleUserBlock(
                                          user['id'], !isBlocked);
                                      _loadData();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await _showConfirmDialog(
                                          'Supprimer cet utilisateur ?',
                                          'Cette action est irréversible.');
                                      if (confirm) {
                                        await _adminService
                                            .deleteUser(user['id']);
                                        _loadData();
                                      }
                                    },
                                  ),
                                ]
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4. Gestion des Réservations
                    const Text('🎫 Gestion des Réservations',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 2,
                      child: Column(
                        children: _recentBookings.map((booking) {
                          final userData =
                              booking['users'] as Map<String, dynamic>?;
                          final status = booking['status'] ?? 'confirmed';
                          final isProcessed =
                              status == 'cancelled' || status == 'refunded';

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isProcessed
                                  ? Colors.grey
                                  : const Color(0xFFE30613),
                              child: Icon(
                                  isProcessed ? Icons.cancel : Icons.flight,
                                  color: Colors.white),
                            ),
                            title: Text(
                                '${booking['departure_iata']} → ${booking['arrival_iata']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                '${userData?['full_name'] ?? 'Utilisateur'}\nRéf: ${booking['booking_reference']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        '${(booking['price'] as num).toStringAsFixed(0)} XOF',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFE30613))),
                                    Text(_getStatusText(status),
                                        style: TextStyle(
                                            color: _getStatusColor(status),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                if (!isProcessed) const SizedBox(width: 12),
                                if (!isProcessed)
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) =>
                                        _handleBookingAction(value, booking),
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                          value: 'cancel',
                                          child: Text('Annuler')),
                                      const PopupMenuItem(
                                          value: 'refund',
                                          child: Text('Rembourser')),
                                    ],
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 5. 🛡️ SECTION ASSURANCES
                    const Text('🛡️ Assurances',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: _buildSummaryCard(
                                'Total Assurances',
                                '${_insuranceStats['totalInsurances'] ?? 0}',
                                Icons.shield,
                                Colors.orange)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildSummaryCard(
                                'Revenus Assurances',
                                '${(_insuranceStats['totalRevenue'] ?? 0.0).toStringAsFixed(0)} XOF',
                                Icons.attach_money,
                                Colors.orange)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 2,
                      child: Column(
                        children: _insurances.isEmpty
                            ? const [
                                Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text('Aucune assurance souscrite',
                                      style: TextStyle(color: Colors.grey)),
                                ),
                              ]
                            : _insurances.take(10).map((insurance) {
                                final userData =
                                    insurance['users'] as Map<String, dynamic>?;
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getInsuranceTypeColor(
                                        insurance['type']),
                                    child: Icon(
                                        _getInsuranceTypeIcon(
                                            insurance['type']),
                                        color: Colors.white),
                                  ),
                                  title: Text(
                                      (insurance['type'] ?? 'assurance')
                                          .toString()
                                          .toUpperCase(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                      '${userData?['full_name'] ?? 'Client'}\nRéf: ${insurance['reference']}'),
                                  trailing: Text(
                                    '${(insurance['price'] as num).toStringAsFixed(0)} XOF',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE30613)),
                                  ),
                                );
                              }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title,
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    if (_seatDistribution.isEmpty) {
      return const Center(child: Text('Aucune donnée de réservation'));
    }

    final sections = _seatDistribution.entries.map((entry) {
      Color color;
      switch (entry.key.toLowerCase()) {
        case 'business':
          color = Colors.orange;
          break;
        case 'first':
          color = Colors.purple;
          break;
        default:
          color = const Color(0xFFE30613);
      }
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.key}\n${entry.value}',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
        borderData: FlBorderData(show: false),
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

  Future<void> _handleBookingAction(
      String action, Map<String, dynamic> booking) async {
    final bookingId = booking['id'] as String;
    final price = (booking['price'] as num).toDouble();
    final ref = booking['booking_reference'];

    if (action == 'cancel') {
      final confirm = await _showConfirmDialog(
          'Annuler la réservation $ref ?', 'Le client ne sera pas remboursé.');
      if (confirm) {
        await _adminService.cancelBooking(bookingId);
        _loadData();
      }
    } else if (action == 'refund') {
      final confirm = await _showConfirmDialog(
          'Rembourser la réservation $ref ?',
          'Le montant de ${price.toStringAsFixed(0)} XOF sera crédité.');
      if (confirm) {
        final success = await _adminService.refundBooking(bookingId, price);
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Remboursement effectué'),
                backgroundColor: Colors.green));
          }
          _loadData();
        }
      }
    }
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Confirmer', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE30613)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  IconData _getInsuranceTypeIcon(String? type) {
    switch (type) {
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

  Color _getInsuranceTypeColor(String? type) {
    switch (type) {
      case 'voyage':
        return const Color(0xFFE30613);
      case 'sante':
        return Colors.blue;
      case 'auto':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
