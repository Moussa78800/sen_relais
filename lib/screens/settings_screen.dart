import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  final UserModel user;

  const SettingsScreen({super.key, required this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();

  late bool _emailNotifications;
  late bool _pushNotifications;
  late bool _smsNotifications;

  @override
  void initState() {
    super.initState();
    _emailNotifications = widget.user.emailNotifications;
    _pushNotifications = widget.user.pushNotifications;
    _smsNotifications = widget.user.smsNotifications;
  }

  Future<void> _updateNotifications() async {
    final success = await _authService.updateNotificationPreferences(
      userId: widget.user.id,
      emailNotifications: _emailNotifications,
      pushNotifications: _pushNotifications,
      smsNotifications: _smsNotifications,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Préférences mises à jour'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la mise à jour'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE30613),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Notifications
          const Text(
            'Notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Notifications par email'),
                  subtitle: const Text('Recevoir les mises à jour par email'),
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() => _emailNotifications = value);
                    _updateNotifications();
                  },
                  activeColor: const Color(0xFFE30613),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Notifications push'),
                  subtitle: const Text('Recevoir les alertes en temps réel'),
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() => _pushNotifications = value);
                    _updateNotifications();
                  },
                  activeColor: const Color(0xFFE30613),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Notifications SMS'),
                  subtitle: const Text('Recevoir les SMS importants'),
                  value: _smsNotifications,
                  onChanged: (value) {
                    setState(() => _smsNotifications = value);
                    _updateNotifications();
                  },
                  activeColor: const Color(0xFFE30613),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section Sécurité
          const Text(
            'Sécurité',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock, color: Color(0xFFE30613)),
              title: const Text('Changer le mot de passe'),
              subtitle: const Text('Modifier votre mot de passe'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Section Compte
          const Text(
            'Compte',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info, color: Colors.blue),
                  title: const Text('Informations du compte'),
                  subtitle: Text(
                      'Membre depuis ${_formatDate(widget.user.createdAt)}'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Se déconnecter',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Version de l'app
          Center(
            child: Text(
              'SEN RELAIS v1.0.0',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
        ],
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
            child: const Text('Annuler'),
          ),
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
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }
}
