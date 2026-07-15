import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html; // Pour ouvrir les liens
import '../models/apartment_model.dart';
import '../services/real_estate_service.dart';

class RealEstateScreen extends StatefulWidget {
  const RealEstateScreen({super.key});

  @override
  State<RealEstateScreen> createState() => _RealEstateScreenState();
}

class _RealEstateScreenState extends State<RealEstateScreen> {
  final RealEstateService _service = RealEstateService();
  List<ApartmentModel> _apartments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApartments();
  }

  Future<void> _loadApartments() async {
    setState(() => _isLoading = true);
    final apartments = await _service.getAvailableApartments();
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE30613),
        elevation: 0,
        title: const Text(
          'Nos Résidences Mboro',
          style:
              TextStyle(color: Color(0xFFE30613), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE30613)))
          : _apartments.isEmpty
              ? const Center(
                  child: Text('Aucun appartement disponible pour le moment.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _apartments.length,
                  itemBuilder: (context, index) {
                    return _buildApartmentCard(_apartments[index]);
                  },
                ),
    );
  }

  Widget _buildApartmentCard(ApartmentModel apt) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  apt.imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 220,
                    color: Colors.grey[300],
                    child: const Icon(Icons.apartment,
                        size: 64, color: Colors.grey),
                  ),
                ),
              ),
              // Badge "Photos à venir" pour gérer les attentes
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Photos officielles à venir',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              // Badge Mboro
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE30613),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_city, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('MBORO',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(apt.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: Color(0xFFE30613)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(apt.location,
                          style: const TextStyle(
                              color: Color(0xFFE30613),
                              fontWeight: FontWeight.w500)),
                    ),
                    const Icon(Icons.people, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${apt.capacity} pers.',
                        style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  apt.description,
                  style: TextStyle(
                      color: Colors.grey[700], fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE30613).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE30613)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Loyer mensuel',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(
                            apt.formattedPrice,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE30613)),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showContactModal(context, apt.title),
                        icon: const Icon(Icons.contact_mail, size: 18),
                        label: const Text('Nous contacter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE30613),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showContactModal(BuildContext context, String apartmentTitle) {
    final whatsappUrl =
        'https://wa.me/221774979721?text=Bonjour%20SEN%20RELAIS,%20je%20suis%20intéressé%20par%20:%20$apartmentTitle';
    final emailUrl =
        'mailto:senrelais@gmail.com?subject=Demande%20d\'information%20-%20$apartmentTitle&body=Bonjour,%0A%0AJe%20souhaite%20avoir%20plus%20d\'informations%20sur%20l\'appartement%20:%20$apartmentTitle.%0A%0AMerci.';
    final phoneUrl = 'tel:+221774979721';

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // ✅ AJOUTÉ : Permet au menu de s'adapter à la hauteur
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height *
              0.85, // ✅ Limite la hauteur max à 85% de l'écran
        ),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          // ✅ AJOUTÉ : Rend le contenu défilable si besoin
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Contacter SEN RELAIS',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Pour réserver ou visiter : $apartmentTitle',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Bouton WhatsApp
              _buildContactButton(
                icon: Icons.message,
                color: const Color(0xFF25D366),
                label: 'WhatsApp',
                subtitle: '+221 77 497 97 21',
                onTap: () {
                  html.window.open(whatsappUrl, '_blank');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),

              // Bouton Appel
              _buildContactButton(
                icon: Icons.phone,
                color: const Color(0xFFE30613),
                label: 'Appel direct',
                subtitle: '+221 77 497 97 21',
                onTap: () {
                  html.window.open(phoneUrl, '_self');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),

              // Bouton Email
              _buildContactButton(
                icon: Icons.email,
                color: Colors.blue,
                label: 'Email',
                subtitle: 'senrelais@gmail.com',
                onTap: () {
                  html.window.open(emailUrl, '_blank');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required Color color,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 16)),
                  Text(subtitle,
                      style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}
