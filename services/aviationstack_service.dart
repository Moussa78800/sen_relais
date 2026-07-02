import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/flight_model.dart';

class AviationStackService {
  final String _apiKey = dotenv.env['AVIATIONSTACK_API_KEY'] ?? '';
  final String _baseUrl = 'http://api.aviationstack.com/v1';

  // Rechercher des vols (méthode compatible avec le plan gratuit)
  Future<List<FlightModel>> searchFlights({
    required String depIata,
    required String arrIata,
    required String date,
  }) async {
    try {
      print('🔍 Recherche de vols: $depIata → $arrIata le $date');
      
      // Étape 1 : Récupérer TOUS les vols de l'aéroport de départ à cette date
      final url = Uri.parse(
        '$_baseUrl/flights?access_key=$_apiKey'
        '&dep_iata=$depIata'
        '&flight_date=$date'
        '&limit=100',
      );

      print('🌐 URL: $url');

      final response = await http.get(url);

      print('📡 Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['data'] != null) {
          final List<dynamic> allFlightsJson = data['data'];
          print('✅ ${allFlightsJson.length} vols trouvés au départ de $depIata');
          
          // Étape 2 : Filtrer côté client pour ne garder que ceux qui vont à arrIata
          final filteredFlights = allFlightsJson.where((flight) {
            final arrival = flight['arrival'] as Map<String, dynamic>?;
            return arrival?['iata'] == arrIata;
          }).toList();
          
          print('✅ ${filteredFlights.length} vols trouvés vers $arrIata');
          
          // Si aucun vol trouvé, retourner des données mockées réalistes
          if (filteredFlights.isEmpty) {
            print('⚠️ Aucun vol réel trouvé, utilisation de données mockées');
            return _getMockFlights(depIata, arrIata, date);
          }
          
          return filteredFlights
              .map((json) => FlightModel.fromJson(json))
              .toList();
        } else {
          print('⚠️ Pas de données dans la réponse');
          return _getMockFlights(depIata, arrIata, date);
        }
      } else {
        print('❌ Erreur HTTP: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        // En cas d'erreur API, retourner des données mockées
        return _getMockFlights(depIata, arrIata, date);
      }
    } catch (e) {
      print('❌ Exception: $e');
      // En cas d'exception, retourner des données mockées
      return _getMockFlights(depIata, arrIata, date);
    }
  }

  // Données mockées réalistes (fallback)
  List<FlightModel> _getMockFlights(String depIata, String arrIata, String date) {
    final airlines = [
      {'name': 'Air France', 'iata': 'AF'},
      {'name': 'Brussels Airlines', 'iata': 'SN'},
      {'name': 'Turkish Airlines', 'iata': 'TK'},
      {'name': 'Royal Air Maroc', 'iata': 'AT'},
      {'name': 'Air Senegal', 'iata': 'HC'},
    ];

    final airports = {
      'DKR': {'city': 'Dakar', 'name': 'Blaise Diagne'},
      'DSS': {'city': 'Dakar', 'name': 'Blaise Diagne'},
      'CDG': {'city': 'Paris', 'name': 'Charles de Gaulle'},
      'ORY': {'city': 'Paris', 'name': 'Orly'},
      'JFK': {'city': 'New York', 'name': 'John F. Kennedy'},
      'DXB': {'city': 'Dubai', 'name': 'Dubai International'},
      'IST': {'city': 'Istanbul', 'name': 'Istanbul Airport'},
      'CMN': {'city': 'Casablanca', 'name': 'Mohammed V'},
    };

    final depInfo = airports[depIata] ?? {'city': depIata, 'name': depIata};
    final arrInfo = airports[arrIata] ?? {'city': arrIata, 'name': arrIata};

    return List.generate(5, (index) {
      final airline = airlines[index % airlines.length];
      final depHour = 6 + (index * 3);
      final arrHour = depHour + 5 + (index % 3);
      
      return FlightModel(
        flightDate: date,
        flightStatus: 'scheduled',
        departureAirport: depInfo['name']!,
        departureIATA: depIata,
        departureCity: depInfo['city']!,
        departureScheduled: '${date}T${depHour.toString().padLeft(2, '0')}:00:00',
        arrivalAirport: arrInfo['name']!,
        arrivalIATA: arrIata,
        arrivalCity: arrInfo['city']!,
        arrivalScheduled: '${date}T${arrHour.toString().padLeft(2, '0')}:00:00',
        airlineName: airline['name']!,
        airlineIATA: airline['iata']!,
        flightNumber: '${airline['iata']}${100 + index}',
        price: 150000 + (index * 50000),
      );
    });
  }

  // Obtenir les aéroports populaires
  Future<List<Map<String, String>>> getPopularAirports() async {
    return [
      {'iata': 'DKR', 'city': 'Dakar', 'name': 'Blaise Diagne', 'country': 'Sénégal'},
      {'iata': 'DSS', 'city': 'Dakar', 'name': 'Blaise Diagne International', 'country': 'Sénégal'},
      {'iata': 'CDG', 'city': 'Paris', 'name': 'Charles de Gaulle', 'country': 'France'},
      {'iata': 'ORY', 'city': 'Paris', 'name': 'Orly', 'country': 'France'},
      {'iata': 'JFK', 'city': 'New York', 'name': 'John F. Kennedy', 'country': 'USA'},
      {'iata': 'DXB', 'city': 'Dubai', 'name': 'Dubai International', 'country': 'UAE'},
      {'iata': 'IST', 'city': 'Istanbul', 'name': 'Istanbul Airport', 'country': 'Turkey'},
      {'iata': 'CMN', 'city': 'Casablanca', 'name': 'Mohammed V', 'country': 'Morocco'},
      {'iata': 'ABJ', 'city': 'Abidjan', 'name': 'Félix Houphouët-Boigny', 'country': 'Côte d\'Ivoire'},
      {'iata': 'BKO', 'city': 'Bamako', 'name': 'Modibo Keita', 'country': 'Mali'},
      {'iata': 'CKY', 'city': 'Conakry', 'name': 'Ahmed Sékou Touré', 'country': 'Guinea'},
      {'iata': 'NDJ', 'city': 'N\'Djamena', 'name': 'Hassan Djamous', 'country': 'Chad'},
      {'iata': 'LFW', 'city': 'Lomé', 'name': 'Gnassingbé Eyadéma', 'country': 'Togo'},
      {'iata': 'COO', 'city': 'Cotonou', 'name': 'Cadjehoun', 'country': 'Benin'},
      {'iata': 'NKC', 'city': 'Nouakchott', 'name': 'Oumtounsy', 'country': 'Mauritania'},
    ];
  }
}