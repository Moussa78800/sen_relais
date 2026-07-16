import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import 'apartment_management_screen.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;

  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _recentBookings = [];
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _insurances = [];
  Map<String, dynamic> _insuranceStats = {};
  Map<String, dynamic> _realEstateStats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final results = await Future.wait([
      _adminService.getAdvancedStats(),
      _adminService.getRecentBookingsForManagement(limit: 5),
      _adminService.getAllUsers(),
      _adminService.getAllInsurances(),
      _adminService.getInsuranceStats(),
      _adminService.getRealEstateStats(),
    ]);

    setState(() {
      _stats = results[0] as Map<String, dynamic>;
      _recentBookings = results[1] as List<Map<String, dynamic>>;
      _users = results[2] as List<Map<String, dynamic>>;
      _insurances = results[3] as List<Map<String, dynamic>>;
      _insuranceStats = results[4] as Map<String, dynamic>;
      _realEstateStats = results[5] as Map<String, dynamic>;
      _isLoading = false;
    });
  }

  // ✅ Calcul du CA Total (Vols + Immobilier + Assurances)
  double get _totalRevenue {
    final vols = (_stats['totalRevenue'] ?? 0.0) as double;
    final immo = (_realEstateStats['totalRevenue'] ?? 0.0) as double;
    final assurances = (_insuranceStats['totalRevenue'] ?? 0.0) as double;
    return vols + immo + assurances;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Tableau de Bord Admin',
          style:
              TextStyle(color: Color(0xFFE30613), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFE30613)),
            onPressed: _loadData,
            tooltip: 'Actualiser les données',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE30613)))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFFE30613),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // 1. VUE D'ENSEMBLE GLOBALE
                    // ==========================================
                    _buildSectionHeader('📊 Vue d\'ensemble', Icons.analytics),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernCard(
                            'CA Total (Tous pôles)',
                            '${_totalRevenue.toStringAsFixed(0)} XOF',
                            Icons.trending_up,
                            const Color(0xFFE30613),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildModernCard(
                            'Réservations Vols',
                            '${_stats['totalBookings'] ?? 0}',
                            Icons.flight_takeoff,
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernCard(
                            'Revenus Vols',
                            '${(_stats['totalRevenue'] ?? 0.0).toStringAsFixed(0)} XOF',
                            Icons.attach_money,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 130,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                print('🔘 Bouton Export CSV cliqué');
                                print(
                                    '📊 Nombre d\'utilisateurs : ${_users.length}');
                                _adminService.exportUsersToCSV(_users);
                              },
                              icon: const Icon(Icons.download,
                                  color: Colors.white, size: 28),
                              label: const Text('Export CSV Utilisateurs',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ==========================================
                    // 2. 🏠 POLE IMMOBILIER
                    // ==========================================
                    _buildSectionHeader(
                        '🏠 Pôle Immobilier (Mboro)', Icons.home_work),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernCard(
                            'CA Immobilier',
                            '${(_realEstateStats['totalRevenue'] ?? 0.0).toStringAsFixed(0)} XOF',
                            Icons.account_balance_wallet,
                            const Color(0xFF9C27B0),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildModernCard(
                            'Locations Actives',
                            '${_realEstateStats['totalBookings'] ?? 0}',
                            Icons.key,
                            const Color(0xFF9C27B0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ApartmentManagementScreen()),
                        ),
                        icon: const Icon(Icons.settings, color: Colors.white),
                        label: const Text(
                          'Gérer les appartements et les prix',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9C27B0),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ==========================================
                    // 3. 🛡️ POLE ASSURANCES
                    // ==========================================
                    _buildSectionHeader('🛡️ Pôle Assurances', Icons.security),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernCard(
                            'Contrats Souscrits',
                            '${_insuranceStats['totalInsurances'] ?? 0}',
                            Icons.description,
                            const Color(0xFFFF9800),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildModernCard(
                            'Revenus Assurances',
                            '${(_insuranceStats['totalRevenue'] ?? 0.0).toStringAsFixed(0)} XOF',
                            Icons.attach_money,
                            const Color(0xFFFF9800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: _insurances.isEmpty
                            ? [
                                const Padding(
                                  padding: EdgeInsets.all(32),
                                  child: Center(
                                    child: Text('Aucune assurance souscrite',
                                        style: TextStyle(color: Colors.grey)),
                                  ),
                                ),
                              ]
                            : _insurances.take(5).map((insurance) {
                                final clientName = insurance['client_name'] ??
                                    'Client inconnu';
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  leading: CircleAvatar(
                                    backgroundColor: _getInsuranceTypeColor(
                                            insurance['type'])
                                        .withOpacity(0.1),
                                    child: Icon(
                                      _getInsuranceTypeIcon(insurance['type']),
                                      color: _getInsuranceTypeColor(
                                          insurance['type']),
                                      size: 22,
                                    ),
                                  ),
                                  title: Text(
                                    (insurance['type'] ?? 'assurance')
                                        .toString()
                                        .toUpperCase(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  subtitle: Text(
                                    '$clientName\nRéf: ${insurance['reference']}',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 13),
                                  ),
                                  trailing: Text(
                                    '${(insurance['price'] as num).toStringAsFixed(0)} XOF',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFFE30613),
                                    ),
                                  ),
                                );
                              }).toList(),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ==========================================
                    // 4. 👥 UTILISATEURS & 🎫 RÉSERVATIONS (2 colonnes)
                    // ==========================================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Colonne Utilisateurs
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(
                                  '👥 Utilisateurs (${_users.length})',
                                  Icons.people),
                              const SizedBox(height: 16),
                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                child: Column(
                                  children: _users.take(5).map((user) {
                                    final isBlocked =
                                        user['is_blocked'] == true;
                                    return ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 4),
                                      leading: CircleAvatar(
                                        backgroundColor: isBlocked
                                            ? Colors.grey[300]
                                            : (user['is_admin'] == true
                                                ? Colors.red
                                                : Colors.blue),
                                        child: Text(
                                          (user['full_name'] ?? '?')[0]
                                              .toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      title: Text(
                                        user['full_name'] ?? 'Sans nom',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Text(
                                        user['email'] ?? '',
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (user['is_admin'] != true)
                                            IconButton(
                                              icon: Icon(
                                                isBlocked
                                                    ? Icons.lock_open
                                                    : Icons.lock,
                                                color: isBlocked
                                                    ? Colors.orange
                                                    : Colors.red,
                                                size: 20,
                                              ),
                                              onPressed: () async {
                                                await _adminService
                                                    .toggleUserBlock(
                                                        user['id'], !isBlocked);
                                                _loadData();
                                              },
                                              tooltip: isBlocked
                                                  ? 'Débloquer'
                                                  : 'Bloquer',
                                            ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Colonne Réservations Vols
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('🎫 Dernières Réservations',
                                  Icons.confirmation_number),
                              const SizedBox(height: 16),
                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                child: Column(
                                  children: _recentBookings.map((booking) {
                                    final userData = booking['users']
                                        as Map<String, dynamic>?;
                                    final status =
                                        booking['status'] ?? 'confirmed';
                                    final isProcessed = status == 'cancelled' ||
                                        status == 'refunded';

                                    return ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 4),
                                      leading: CircleAvatar(
                                        backgroundColor: isProcessed
                                            ? Colors.grey[300]
                                            : const Color(0xFFE30613)
                                                .withOpacity(0.1),
                                        child: Icon(
                                          isProcessed
                                              ? Icons.cancel
                                              : Icons.flight,
                                          color: isProcessed
                                              ? Colors.grey[600]
                                              : const Color(0xFFE30613),
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(
                                        '${booking['departure_iata']} → ${booking['arrival_iata']}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      subtitle: Text(
                                        '${userData?['full_name'] ?? 'Utilisateur'}\nRéf: ${booking['booking_reference']}',
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12),
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${(booking['price'] as num).toStringAsFixed(0)} XOF',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFE30613)),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(status)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              _getStatusText(status),
                                              style: TextStyle(
                                                color: _getStatusColor(status),
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  // ==========================================
  // WIDGETS UTILITAIRES
  // ==========================================

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE30613), size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A)),
        ),
      ],
    );
  }

  Widget _buildModernCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
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
