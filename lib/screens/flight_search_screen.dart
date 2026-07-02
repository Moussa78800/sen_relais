import 'package:flutter/material.dart';
import '../services/aviationstack_service.dart';
import '../models/flight_model.dart';
import 'flight_results_screen.dart';

class FlightSearchScreen extends StatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  State<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  final _service = AviationStackService();
  final _depController = TextEditingController();
  final _arrController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;
  List<Map<String, String>> _airports = [];

  @override
  void initState() {
    super.initState();
    _loadAirports();
  }

  Future<void> _loadAirports() async {
    final airports = await _service.getPopularAirports();
    setState(() => _airports = airports);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE30613),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _searchFlights() async {
    if (_depController.text.isEmpty || _arrController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Color(0xFFE30613),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final formattedDate = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      
      final flights = await _service.searchFlights(
        depIata: _depController.text.toUpperCase(),
        arrIata: _arrController.text.toUpperCase(),
        date: formattedDate,
      );

      if (!mounted) return;

      if (flights.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun vol trouvé pour ces critères'),
            backgroundColor: Color(0xFFE30613),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlightResultsScreen(
              flights: flights,
              departure: _depController.text.toUpperCase(),
              arrival: _arrController.text.toUpperCase(),
              date: _selectedDate,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: const Color(0xFFE30613),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _swapAirports() {
    final temp = _depController.text;
    setState(() {
      _depController.text = _arrController.text;
      _arrController.text = temp;
    });
  }

  @override
  void dispose() {
    _depController.dispose();
    _arrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE30613),
        foregroundColor: Colors.white,
        title: const Text(
          'Rechercher un vol',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Carte de recherche
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Départ
                  _buildAirportField(
                    controller: _depController,
                    label: 'Départ',
                    icon: Icons.flight_takeoff,
                    airports: _airports,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Bouton swap
                  Center(
                    child: IconButton(
                      onPressed: _swapAirports,
                      icon: const Icon(
                        Icons.swap_vert,
                        color: Color(0xFFE30613),
                        size: 32,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Arrivée
                  _buildAirportField(
                    controller: _arrController,
                    label: 'Arrivée',
                    icon: Icons.flight_land,
                    airports: _airports,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Date
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Color(0xFFE30613),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date de départ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Bouton de recherche
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _searchFlights,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE30613),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: _isLoading
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
                          Icon(Icons.search, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'Rechercher des vols',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Informations - Section CORRIGÉE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE30613).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE30613).withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CORRECTION : Added Expanded around Text to prevent overflow
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFFE30613), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: const Text(
                          'Codes IATA populaires',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE30613),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildIataChip('DSS', 'Dakar'),
                      _buildIataChip('DKR', 'Dakar'),
                      _buildIataChip('CDG', 'Paris'),
                      _buildIataChip('JFK', 'New York'),
                      _buildIataChip('DXB', 'Dubai'),
                      _buildIataChip('IST', 'Istanbul'),
                      _buildIataChip('CMN', 'Casablanca'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAirportField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required List<Map<String, String>> airports,
  }) {
    return Autocomplete<Map<String, String>>(
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Map<String, String>>.empty();
        }
        return airports.where((airport) {
          final search = textEditingValue.text.toLowerCase();
          return airport['iata']!.toLowerCase().contains(search) ||
              airport['city']!.toLowerCase().contains(search) ||
              airport['name']!.toLowerCase().contains(search);
        });
      },
      displayStringForOption: (option) =>
          '${option['iata']} - ${option['city']} (${option['name']})',
      onSelected: (selection) {
        controller.text = selection['iata']!;
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: const Color(0xFFE30613)),
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
          onFieldSubmitted: (_) => onFieldSubmitted(),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: options.map((airport) {
                  return ListTile(
                    title: Text('${airport['iata']} - ${airport['city']}'),
                    subtitle: Text(airport['name']!),
                    onTap: () => onSelected(airport),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIataChip(String iata, String city) {
    return InkWell(
      onTap: () {
        if (_depController.text.isEmpty) {
          setState(() => _depController.text = iata);
        } else if (_arrController.text.isEmpty) {
          setState(() => _arrController.text = iata);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE30613).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE30613).withOpacity(0.3),
          ),
        ),
        child: Text(
          '$iata ($city)',
          style: const TextStyle(
            color: Color(0xFFE30613),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}