import 'package:flutter/material.dart';
import 'insurance_quote_screen.dart';

class InsuranceChoiceScreen extends StatelessWidget {
  const InsuranceChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE30613),
        elevation: 0,
        title: const Text(
          'Nos Assurances',
          style: TextStyle(
            color: Color(0xFFE30613),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        // ✅ C'EST ICI LA CORRECTION
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choisissez votre protection',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sélectionnez le type d\'assurance adapté à vos besoins',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 32),

            // Assurance Voyage
            _buildInsuranceCard(
              context,
              icon: Icons.flight_takeoff,
              title: 'Assurance Voyage',
              subtitle: 'Voyagez l\'esprit tranquille',
              description: 'Couverture médicale, annulation, perte de bagages',
              price: 'À partir de 15 000 XOF',
              color: const Color(0xFFE30613),
              onTap: () => _navigateToQuote(context, 'voyage'),
            ),
            const SizedBox(height: 16),

            // Assurance Santé
            _buildInsuranceCard(
              context,
              icon: Icons.local_hospital,
              title: 'Assurance Santé',
              subtitle: 'Protégez votre santé et celle de vos proches',
              description: 'Frais médicaux, hospitalisation, médicaments',
              price: 'À partir de 25 000 XOF',
              color: Colors.blue,
              onTap: () => _navigateToQuote(context, 'sante'),
            ),
            const SizedBox(height: 16),

            // Assurance Auto
            _buildInsuranceCard(
              context,
              icon: Icons.directions_car,
              title: 'Assurance Auto',
              subtitle: 'Protégez votre véhicule',
              description: 'Accident, vol, incendie, responsabilité civile',
              price: 'À partir de 45 000 XOF',
              color: Colors.green,
              onTap: () => _navigateToQuote(context, 'auto'),
            ),
          ],
        ),
      ), // ✅ N'oubliez pas cette parenthèse fermante
    );
  }

  Widget _buildInsuranceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required String price,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    );
  }

  void _navigateToQuote(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InsuranceQuoteScreen(insuranceType: type),
      ),
    );
  }
}
