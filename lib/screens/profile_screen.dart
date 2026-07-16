import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'dashboard_admin_screen.dart';
import 'my_insurances_screen.dart';
import 'my_bookings_screen.dart';
import 'my_apartment_bookings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final userId = _authService.currentUser?.id;
    if (userId != null) {
      final user = await _authService.getUserProfile(userId);
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE30613),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              if (_user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(user: _user!),
                  ),
                ).then((_) => _loadProfile());
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('Erreur de chargement'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: const Color(0xFFE30613),
                        child: Text(
                          (_user!.fullName ?? _user!.email)[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _user!.fullName ?? 'Utilisateur',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _user!.email,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      if (_user!.isAdmin)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE30613).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified,
                                  color: Color(0xFFE30613), size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Administrateur',
                                style: TextStyle(
                                  color: Color(0xFFE30613),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 32),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.phone,
                                  color: Color(0xFFE30613)),
                              title: const Text('Téléphone'),
                              subtitle: Text(_user!.phone ?? 'Non renseigné'),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.location_on,
                                  color: Color(0xFFE30613)),
                              title: const Text('Adresse'),
                              subtitle:
                                  Text(_user!.address ?? 'Non renseignée'),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.calendar_today,
                                  color: Color(0xFFE30613)),
                              title: const Text('Membre depuis'),
                              subtitle: Text(_formatDate(_user!.createdAt)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildMenuItem(
                        icon: Icons.confirmation_number,
                        label: 'Mes Réservations (Vols)',
                        subtitle: 'Voir vos billets d\'avion',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyBookingsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.home,
                        label: 'Mes Locations Immobilières',
                        subtitle: 'Voir vos locations d\'appartements',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MyApartmentBookingsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.shield,
                        label: 'Mes Assurances',
                        subtitle: 'Voir vos contrats actifs',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyInsurancesScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditProfileScreen(user: _user!),
                              ),
                            ).then((result) {
                              if (result == true) _loadProfile();
                            });
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Modifier mon profil'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE30613),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_user!.isAdmin) ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DashboardAdminScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.dashboard,
                                color: Color(0xFFE30613)),
                            label: const Text(
                              'Dashboard Admin',
                              style: TextStyle(color: Color(0xFFE30613)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFFE30613), width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SettingsScreen(user: _user!),
                              ),
                            ).then((_) => _loadProfile());
                          },
                          icon: const Icon(Icons.settings,
                              color: Color(0xFFE30613)),
                          label: const Text(
                            'Paramètres',
                            style: TextStyle(color: Color(0xFFE30613)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFFE30613), width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () => _confirmLogout(context),
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text(
                            'Se déconnecter',
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                          style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
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
          border: Border.all(color: const Color(0xFFE30613).withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFE30613), size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE30613))),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Color(0xFFE30613)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'inconnu';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text(
            'Vous devrez vous reconnecter pour accéder à votre compte.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Se déconnecter',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const _LoginRedirectScreen()),
          (route) => false,
        );
      }
    }
  }
}

class _LoginRedirectScreen extends StatelessWidget {
  const _LoginRedirectScreen();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed('/');
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Color(0xFFE30613))),
    );
  }
}
