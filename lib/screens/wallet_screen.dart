import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _supabase = Supabase.instance.client;
  double _balance = 0.0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    setState(() => _isLoading = true);
    final userId = _supabase.auth.currentUser?.id;

    if (userId != null) {
      try {
        // 1. Récupérer le solde
        final walletResponse = await _supabase
            .from('wallets')
            .select('balance')
            .eq('user_id', userId)
            .single();

        setState(() {
          _balance = (walletResponse['balance'] as num?)?.toDouble() ?? 0.0;
        });

        // 2. Récupérer l'historique des transactions (si la table existe)
        try {
          final txResponse = await _supabase
              .from('transactions')
              .select()
              .eq('user_id', userId)
              .order('created_at', ascending: false)
              .limit(10);

          setState(() {
            _transactions = List<Map<String, dynamic>>.from(txResponse);
          });
        } catch (e) {
          // La table transactions n'existe pas encore, ce n'est pas grave
          print(
              'ℹ️ Table transactions non trouvée, affichage du solde uniquement.');
        }
      } catch (e) {
        print('❌ Erreur chargement wallet: $e');
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _simulateTopUp() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    const amount = 100000.0; // Simule un rechargement de 100 000 XOF

    setState(() => _isLoading = true);

    try {
      // 1. Mettre à jour le solde
      final newBalance = _balance + amount;
      await _supabase
          .from('wallets')
          .update({'balance': newBalance}).eq('user_id', userId);

      // 2. Enregistrer la transaction (si la table existe)
      try {
        await _supabase.from('transactions').insert({
          'user_id': userId,
          'type': 'credit',
          'amount': amount,
          'description': 'Rechargement simulé',
          'created_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        print(
            'ℹ️ Transaction non enregistrée (table manquante), mais solde mis à jour.');
      }

      setState(() => _balance = newBalance);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rechargement de 100 000 XOF effectué !'),
            backgroundColor: Colors.green,
          ),
        );
        _loadWalletData(); // Rafraîchir l'historique
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,##0', 'fr_FR');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE30613),
        elevation: 0,
        title: const Text(
          'Mon Wallet',
          style:
              TextStyle(color: Color(0xFFE30613), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWalletData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE30613)))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Carte de solde
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE30613), Color(0xFFB80000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE30613).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Solde disponible',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${currencyFormat.format(_balance)} XOF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _simulateTopUp,
                                icon: const Icon(Icons.add,
                                    color: Color(0xFFE30613)),
                                label: const Text(
                                  'Recharger',
                                  style: TextStyle(
                                      color: Color(0xFFE30613),
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Module de retrait en cours de développement'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.arrow_downward,
                                    color: Colors.white),
                                label: const Text(
                                  'Retrait',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Historique des transactions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Historique récent',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        if (_transactions.isEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.receipt_long,
                                        size: 48, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Aucune transaction',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          ..._transactions
                              .map((tx) =>
                                  _buildTransactionCard(tx, currencyFormat))
                              .toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildTransactionCard(
      Map<String, dynamic> tx, NumberFormat formatter) {
    final isCredit = tx['type'] == 'credit';
    final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
    final date = tx['created_at'] != null
        ? DateFormat('dd/MM/yyyy HH:mm')
            .format(DateTime.parse(tx['created_at']))
        : 'Date inconnue';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCredit
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
          child: Icon(
            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isCredit ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          tx['description'] ?? 'Transaction',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle:
            Text(date, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        trailing: Text(
          '${isCredit ? '+' : '-'}${formatter.format(amount)} XOF',
          style: TextStyle(
            color: isCredit ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
