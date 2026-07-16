import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'flight_search_screen.dart';
import 'insurance_choice_screen.dart';
import 'real_estate_screen.dart';
import 'wallet_screen.dart'; // ✅ AJOUTÉ pour le Wallet

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userId = _authService.currentUser?.id;
    if (userId != null) {
      final user = await _authService.getUserProfile(userId);
      if (mounted) setState(() => _user = user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SEN RELAIS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Message de bienvenue
                if (_user != null) ...[
                  Text(
                    'Bonjour ${_user!.fullName ?? "Utilisateur"} !',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFFE30613),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                // Logo circulaire
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE30613),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE30613).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.travel_explore,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Bienvenue sur SEN RELAIS',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE30613),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Votre guichet unique pour tous vos besoins',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Module Voyage
                _buildModuleButton(
                  context,
                  icon: Icons.flight,
                  label: 'Voyage & Billetterie',
                  description: 'Réservez vos vols au meilleur prix',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FlightSearchScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Module Immobilier
                _buildModuleButton(
                  context,
                  icon: Icons.home_work,
                  label: 'Nos Résidences',
                  description: 'Mboro',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RealEstateScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Module Assurance
                _buildModuleButton(
                  context,
                  icon: Icons.security,
                  label: 'Assurance',
                  description: 'Protégez ce qui compte',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InsuranceChoiceScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Module Transport & Logistique
                _buildModuleButton(
                  context,
                  icon: Icons.local_shipping,
                  label: 'Transport & Logistique',
                  description: 'Envoyez et suivez vos colis',
                  onTap: () =>
                      _showComingSoon(context, 'Transport & Logistique'),
                ),
                const SizedBox(height: 24),

                // ✅ Bouton Wallet (CORRIGÉ)
                _buildWalletButton(
                  context,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WalletScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          side: const BorderSide(color: Color(0xFFE30613), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE30613).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFFE30613), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE30613),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFFE30613),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletButton(
    BuildContext context, {
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.account_balance_wallet, size: 28),
        label: const Text(
          'Mon Wallet',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE30613),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: const Color(0xFFE30613).withOpacity(0.4),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String moduleName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Module $moduleName - Bientôt disponible !'),
        backgroundColor: const Color(0xFFE30613),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
