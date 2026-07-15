import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/insurance_model.dart';
import '../services/insurance_service.dart';

class MyInsurancesScreen extends StatefulWidget {
  const MyInsurancesScreen({super.key});

  @override
  State<MyInsurancesScreen> createState() => _MyInsurancesScreenState();
}

class _MyInsurancesScreenState extends State<MyInsurancesScreen> {
  final InsuranceService _insuranceService = InsuranceService();
  List<InsuranceModel> _insurances = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInsurances();
  }

  Future<void> _loadInsurances() async {
    setState(() => _isLoading = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final insurances = await _insuranceService.getUserInsurances(userId);
      if (mounted) {
        setState(() {
          _insurances = insurances;
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
          'Mes Assurances',
          style:
              TextStyle(color: Color(0xFFE30613), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _loadInsurances),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE30613)))
          : _insurances.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadInsurances,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _insurances.length,
                    itemBuilder: (context, index) =>
                        _buildInsuranceCard(_insurances[index]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Aucune assurance',
              style: TextStyle(fontSize: 20, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Souscrivez votre première assurance',
              style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.add),
            label: const Text('Souscrire une assurance'),
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

  Widget _buildInsuranceCard(InsuranceModel insurance) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isActive = insurance.status == 'active';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showInsuranceDetails(insurance),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getTypeColor(insurance.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_getTypeIcon(insurance.type),
                        color: _getTypeColor(insurance.type), size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(insurance.typeLabel,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Réf: ${insurance.reference}',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Expirée',
                      style: TextStyle(
                        color: isActive ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Début',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12)),
                      Text(dateFormat.format(insurance.startDate),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Couverture',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12)),
                      Text(insurance.coverage.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Fin',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12)),
                      Text(dateFormat.format(insurance.endDate),
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
                    Text('Montant payé',
                        style: TextStyle(color: Colors.grey[700])),
                    Text(insurance.formattedPrice,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE30613))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInsuranceDetails(InsuranceModel insurance) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Détails du contrat',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    _getTypeColor(insurance.type),
                    _getTypeColor(insurance.type).withOpacity(0.7)
                  ]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(_getTypeIcon(insurance.type),
                        color: Colors.white, size: 48),
                    const SizedBox(height: 8),
                    Text(insurance.typeLabel,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(insurance.reference,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailSection('Informations client', [
                _buildDetailRow('Nom', insurance.clientName),
                _buildDetailRow('Email', insurance.clientEmail),
                _buildDetailRow('Téléphone', insurance.clientPhone),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection('Période de couverture', [
                _buildDetailRow(
                    'Début', dateFormat.format(insurance.startDate)),
                _buildDetailRow('Fin', dateFormat.format(insurance.endDate)),
                _buildDetailRow('Niveau', insurance.coverage.toUpperCase()),
              ]),
              if (insurance.details.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailSection(
                    'Détails', _buildSpecificDetails(insurance)),
              ],
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE30613).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE30613), width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total payé',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(insurance.formattedPrice,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE30613))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
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

  List<Widget> _buildSpecificDetails(InsuranceModel insurance) {
    List<Widget> rows = [];
    switch (insurance.type) {
      case 'voyage':
        rows.add(_buildDetailRow('Destination',
            insurance.details['destination']?.toString() ?? '-'));
        rows.add(
            _buildDetailRow('Durée', '${insurance.details['duration']} jours'));
        break;
      case 'sante':
        rows.add(_buildDetailRow('Âge', '${insurance.details['age']} ans'));
        rows.add(_buildDetailRow('Maladie chronique',
            insurance.details['has_chronic_disease'] == true ? 'Oui' : 'Non'));
        break;
      case 'auto':
        rows.add(_buildDetailRow('Type véhicule',
            insurance.details['vehicle_type']?.toString() ?? '-'));
        rows.add(_buildDetailRow(
            'Âge véhicule', '${insurance.details['vehicle_age']} ans'));
        break;
    }
    return rows;
  }

  IconData _getTypeIcon(String type) {
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

  Color _getTypeColor(String type) {
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
