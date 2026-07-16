import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class ApartmentManagementScreen extends StatefulWidget {
  const ApartmentManagementScreen({super.key});

  @override
  State<ApartmentManagementScreen> createState() =>
      _ApartmentManagementScreenState();
}

class _ApartmentManagementScreenState extends State<ApartmentManagementScreen> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _apartments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApartments();
  }

  Future<void> _loadApartments() async {
    setState(() => _isLoading = true);
    final apartments = await _adminService.getAllApartments();
    if (mounted) {
      setState(() {
        _apartments = apartments;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Appartements'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _loadApartments),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _apartments.isEmpty
              ? const Center(child: Text('Aucun appartement'))
              : RefreshIndicator(
                  onRefresh: _loadApartments,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _apartments.length,
                    itemBuilder: (context, index) {
                      return _buildApartmentCard(_apartments[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildApartmentCard(Map<String, dynamic> apt) {
    final isAvailable = apt['is_available'] == true;
    final price = (apt['price_per_month'] as num?)?.toDouble() ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        apt['title'] ?? 'Sans titre',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        apt['location'] ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAvailable ? 'Disponible' : 'Loué',
                    style: TextStyle(
                      color: isAvailable ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.attach_money,
                    color: const Color(0xFFE30613), size: 20),
                const SizedBox(width: 4),
                Text(
                  '${price.toStringAsFixed(0)} XOF / mois',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE30613)),
                ),
                const Spacer(),
                Text(
                  'Capacité: ${apt['capacity']} pers.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditDialog(apt),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Modifier'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _toggleAvailability(apt['id'], !isAvailable),
                    icon: Icon(isAvailable ? Icons.lock : Icons.lock_open,
                        size: 18),
                    label: Text(isAvailable ? 'Marquer loué' : 'Marquer dispo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          isAvailable ? Colors.orange : Colors.green,
                      side: BorderSide(
                          color: isAvailable ? Colors.orange : Colors.green),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _confirmDelete(apt['id'], apt['title']),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> apt) {
    final titleController = TextEditingController(text: apt['title']);
    final priceController =
        TextEditingController(text: apt['price_per_month'].toString());
    final locationController = TextEditingController(text: apt['location']);
    final capacityController =
        TextEditingController(text: apt['capacity'].toString());
    final descriptionController =
        TextEditingController(text: apt['description']);
    final imageUrlController = TextEditingController(text: apt['image_url']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier l\'appartement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration:
                    const InputDecoration(labelText: 'Prix mensuel (XOF)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Localisation'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: capacityController,
                decoration:
                    const InputDecoration(labelText: 'Capacité (personnes)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'URL de l\'image'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updates = {
                'title': titleController.text,
                'price_per_month': double.tryParse(priceController.text) ?? 0.0,
                'location': locationController.text,
                'capacity': int.tryParse(capacityController.text) ?? 1,
                'description': descriptionController.text,
                'image_url': imageUrlController.text,
              };

              final success =
                  await _adminService.updateApartment(apt['id'], updates);
              if (mounted) {
                Navigator.pop(ctx);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Appartement mis à jour'),
                        backgroundColor: Colors.green),
                  );
                  _loadApartments();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Erreur lors de la mise à jour'),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE30613)),
            child: const Text('Enregistrer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleAvailability(String apartmentId, bool newStatus) async {
    final success =
        await _adminService.toggleApartmentAvailability(apartmentId, newStatus);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(newStatus ? 'Marqué comme disponible' : 'Marqué comme loué'),
          backgroundColor: Colors.green,
        ),
      );
      _loadApartments();
    }
  }

  Future<void> _confirmDelete(String apartmentId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cet appartement ?'),
        content: Text(
            'Êtes-vous sûr de vouloir supprimer "$title" ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _adminService.deleteApartment(apartmentId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Appartement supprimé'),
              backgroundColor: Colors.green),
        );
        _loadApartments();
      }
    }
  }
}
