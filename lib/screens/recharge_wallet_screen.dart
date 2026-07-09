import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'recharge_success_screen.dart';

class RechargeWalletScreen extends StatefulWidget {
  const RechargeWalletScreen({super.key});

  @override
  State<RechargeWalletScreen> createState() => _RechargeWalletScreenState();
}

class _RechargeWalletScreenState extends State<RechargeWalletScreen> {
  final _dbService = DatabaseService();
  final _authService = AuthService();
  final _amountController = TextEditingController();

  double _currentBalance = 0.0;
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _selectedMethod;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'orange_money',
      'name': 'Orange Money',
      'icon': Icons.phone_android,
      'color': const Color(0xFFFF6600),
    },
    {
      'id': 'wave',
      'name': 'Wave',
      'icon': Icons.waves,
      'color': const Color(0xFF1E88E5),
    },
    {
      'id': 'free_money',
      'name': 'Free Money',
      'icon': Icons.phone_android,
      'color': const Color(0xFFE91E63),
    },
    {
      'id': 'card',
      'name': 'Carte bancaire',
      'icon': Icons.credit_card,
      'color': const Color(0xFF4CAF50),
    },
  ];

  final List<int> _quickAmounts = [5000, 10000, 25000, 50000, 100000, 200000];

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final userId = _authService.currentUser?.id;
    if (userId != null) {
      final balance = await _dbService.getWalletBalance(userId);
      if (mounted) {
        setState(() {
          _currentBalance = balance;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _processRecharge(int amount) async {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez choisir un moyen de paiement'),
          backgroundColor: Color(0xFFE30613),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Simulation du paiement (en production, intégrer l'API du provider)
      await Future.delayed(const Duration(seconds: 2));

      // Créditer le wallet via la fonction Supabase
      final result = await _dbService.rechargeWallet(userId, amount.toDouble());

      if (!mounted) return;

      if (result) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RechargeSuccessScreen(
              amount: amount.toDouble(),
              method: _selectedMethod!,
              newBalance: _currentBalance + amount.toDouble(),
            ),
          ),
        );
      } else {
        throw Exception('Échec de la recharge');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: const Color(0xFFE30613),
        ),
      );
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFE30613)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE30613),
        foregroundColor: Colors.white,
        title: const Text(
          'Recharger le Wallet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Solde actuel
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE30613), Color(0xFFB80000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Solde actuel',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentBalance.toStringAsFixed(0)} XOF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Montants rapides
            const Text(
              'Montants rapides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickAmounts.map((amount) {
                final isSelected = _amountController.text == amount.toString();
                return InkWell(
                  onTap: () {
                    setState(() {
                      _amountController.text = amount.toString();
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFFE30613) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE30613)
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      '${amount.toString().replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]} ',
                          )} XOF',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Montant personnalisé
            const Text(
              'Ou montant personnalisé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Montant en XOF',
                prefixIcon: const Icon(Icons.attach_money),
                suffixIcon: const Text(
                  'XOF',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE30613),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE30613),
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Moyens de paiement
            const Text(
              'Moyen de paiement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Column(
              children: _paymentMethods.map((method) {
                final isSelected = _selectedMethod == method['id'];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedMethod = method['id'] as String;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE30613).withValues(alpha: 0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE30613)
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: (method['color'] as Color)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            method['icon'] as IconData,
                            color: method['color'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            method['name'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? const Color(0xFFE30613)
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: isSelected
                              ? const Color(0xFFE30613)
                              : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Bouton recharger
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final amount = int.tryParse(_amountController.text);
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Veuillez entrer un montant valide'),
                        backgroundColor: Color(0xFFE30613),
                      ),
                    );
                    return;
                  }
                  _processRecharge(amount);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE30613),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'Recharger',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
