import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/insurance_service.dart';
import 'insurance_summary_screen.dart';

class InsuranceQuoteScreen extends StatefulWidget {
  final String insuranceType;

  const InsuranceQuoteScreen({super.key, required this.insuranceType});

  @override
  State<InsuranceQuoteScreen> createState() => _InsuranceQuoteScreenState();
}

class _InsuranceQuoteScreenState extends State<InsuranceQuoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _insuranceService = InsuranceService();

  // Champs communs
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _coverage = 'standard';

  // Champs spécifiques voyage
  final _destinationController = TextEditingController();
  int _duration = 7;

  // Champs spécifiques santé
  int _age = 30;
  bool _hasChronicDisease = false;

  // Champs spécifiques auto
  int _vehicleAge = 3;
  String _vehicleType = 'berline';

  double _calculatedPrice = 0.0;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _calculatePrice();
  }

  void _calculatePrice() {
    setState(() => _isCalculating = true);

    double price = 0.0;

    switch (widget.insuranceType) {
      case 'voyage':
        price = _insuranceService.calculateVoyagePrice(
          coverage: _coverage,
          duration: _duration,
          destination: _destinationController.text,
        );
        break;
      case 'sante':
        price = _insuranceService.calculateSantePrice(
          coverage: _coverage,
          age: _age,
          hasChronicDisease: _hasChronicDisease,
        );
        break;
      case 'auto':
        price = _insuranceService.calculateAutoPrice(
          coverage: _coverage,
          vehicleAge: _vehicleAge,
          vehicleType: _vehicleType,
        );
        break;
    }

    setState(() {
      _calculatedPrice = price;
      _isCalculating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE30613),
        elevation: 0,
        title: Text(
          _getTypeTitle(),
          style: const TextStyle(
            color: Color(0xFFE30613),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prix estimé
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE30613), Color(0xFFB80000)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Prix estimé',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    _isCalculating
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            '${_calculatedPrice.toStringAsFixed(0)} XOF',
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

              // Informations personnelles
              const Text(
                'Vos informations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Nom complet'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('Email'),
                validator: (value) => value == null || !value.contains('@')
                    ? 'Email invalide'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration('Téléphone'),
                validator: (value) => value == null || value.length < 8
                    ? 'Numéro invalide'
                    : null,
              ),
              const SizedBox(height: 24),

              // Niveau de couverture
              const Text(
                'Niveau de couverture',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildCoverageSelector(),
              const SizedBox(height: 24),

              // Champs spécifiques selon le type
              _buildSpecificFields(),
              const SizedBox(height: 32),

              // Bouton de souscription
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitQuote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE30613),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Voir le récapitulatif',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeTitle() {
    switch (widget.insuranceType) {
      case 'voyage':
        return 'Assurance Voyage';
      case 'sante':
        return 'Assurance Santé';
      case 'auto':
        return 'Assurance Auto';
      default:
        return 'Assurance';
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE30613), width: 2),
      ),
    );
  }

  Widget _buildCoverageSelector() {
    return Column(
      children: [
        _buildCoverageOption('basique', 'Basique', '15 000 - 45 000 XOF'),
        const SizedBox(height: 8),
        _buildCoverageOption('standard', 'Standard', '22 500 - 67 500 XOF'),
        const SizedBox(height: 8),
        _buildCoverageOption('premium', 'Premium', '33 000 - 99 000 XOF'),
      ],
    );
  }

  Widget _buildCoverageOption(String value, String title, String priceRange) {
    final isSelected = _coverage == value;
    return InkWell(
      onTap: () {
        setState(() => _coverage = value);
        _calculatePrice();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFFE30613) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? const Color(0xFFE30613).withOpacity(0.05)
              : Colors.white,
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _coverage,
              onChanged: (v) {
                setState(() => _coverage = v!);
                _calculatePrice();
              },
              activeColor: const Color(0xFFE30613),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? const Color(0xFFE30613) : Colors.black87,
                    ),
                  ),
                  Text(
                    priceRange,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificFields() {
    switch (widget.insuranceType) {
      case 'voyage':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Détails du voyage',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _destinationController,
              decoration:
                  _inputDecoration('Destination (ex: France, USA, Afrique)'),
              onChanged: (_) => _calculatePrice(),
            ),
            const SizedBox(height: 12),
            const Text('Durée du séjour (jours)'),
            Slider(
              value: _duration.toDouble(),
              min: 1,
              max: 90,
              divisions: 89,
              label: '$_duration jours',
              activeColor: const Color(0xFFE30613),
              onChanged: (value) {
                setState(() => _duration = value.toInt());
                _calculatePrice();
              },
            ),
          ],
        );

      case 'sante':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Détails santé',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Âge : $_age ans'), // ← J'ai juste retiré le mot "const"
            Slider(
              value: _age.toDouble(),
              min: 18,
              max: 80,
              divisions: 62,
              label: '$_age ans',
              activeColor: const Color(0xFFE30613),
              onChanged: (value) {
                setState(() => _age = value.toInt());
                _calculatePrice();
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Maladie chronique'),
              subtitle: const Text('Diabète, hypertension, etc.'),
              value: _hasChronicDisease,
              activeColor: const Color(0xFFE30613),
              onChanged: (value) {
                setState(() => _hasChronicDisease = value);
                _calculatePrice();
              },
            ),
          ],
        );

      case 'auto':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Détails du véhicule',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Type de véhicule'),
            DropdownButtonFormField<String>(
              value: _vehicleType,
              decoration: _inputDecoration('Type'),
              items: [
                const DropdownMenuItem(
                    value: 'citadine', child: Text('Citadine')),
                const DropdownMenuItem(
                    value: 'berline', child: Text('Berline')),
                const DropdownMenuItem(value: 'suv', child: Text('SUV / 4x4')),
                const DropdownMenuItem(
                    value: 'utilitaire', child: Text('Utilitaire')),
              ],
              onChanged: (value) {
                setState(() => _vehicleType = value!);
                _calculatePrice();
              },
            ),
            const SizedBox(height: 12),
            Text(
                'Âge du véhicule : $_vehicleAge ans'), // ← J'ai juste retiré le mot "const"
            Slider(
              value: _vehicleAge.toDouble(),
              min: 0,
              max: 20,
              divisions: 20,
              label: '$_vehicleAge ans',
              activeColor: const Color(0xFFE30613),
              onChanged: (value) {
                setState(() => _vehicleAge = value.toInt());
                _calculatePrice();
              },
            ),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  void _submitQuote() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> details = {};
      DateTime startDate = DateTime.now();
      DateTime endDate = DateTime.now().add(const Duration(days: 365));

      switch (widget.insuranceType) {
        case 'voyage':
          details = {
            'destination': _destinationController.text,
            'duration': _duration,
          };
          endDate = startDate.add(Duration(days: _duration));
          break;
        case 'sante':
          details = {
            'age': _age,
            'has_chronic_disease': _hasChronicDisease,
          };
          break;
        case 'auto':
          details = {
            'vehicle_type': _vehicleType,
            'vehicle_age': _vehicleAge,
          };
          break;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InsuranceSummaryScreen(
            insuranceType: widget.insuranceType,
            clientName: _nameController.text,
            clientEmail: _emailController.text,
            clientPhone: _phoneController.text,
            price: _calculatedPrice,
            coverage: _coverage,
            startDate: startDate,
            endDate: endDate,
            details: details,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _destinationController.dispose();
    super.dispose();
  }
}
