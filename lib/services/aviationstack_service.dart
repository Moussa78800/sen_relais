import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flight_model.dart';

class AviationStackService {
  final String _apiKey = 'dc27024811f40f817c36a81186e785da'; // Votre clé API
  final String _baseUrl = 'http://api.aviationstack.com/v1';

  Future<List<FlightModel>> searchFlights({
    required String depIata,
    required String arrIata,
    required String date,
  }) async {
    try {
      print('🔍 Recherche de vols:  →  le ');

      final url = Uri.parse(
        '/flights?access_key='
        '&dep_iata='
        '&flight_date='
        '&limit=100',
      );

      print('🌐 URL: ');

      final response = await http.get(url);

      print('📡 Status code: ');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data'] != null) {
          final List<dynamic> allFlightsJson = data['data'];
          print('✅  vols trouvés au départ de ');

          final filteredFlights = allFlightsJson.where((flight) {
            final arrival = flight['arrival'] as Map<String, dynamic>?;
            return arrival?['iata'] == arrIata;
          }).toList();

          print('✅  vols trouvés vers ');

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
        print('❌ Erreur HTTP: ');
        print('❌ Response: ');
        return _getMockFlights(depIata, arrIata, date);
      }
    } catch (e) {
      print('❌ Exception: ');
      return _getMockFlights(depIata, arrIata, date);
    }
  }

  List<FlightModel> _getMockFlights(
      String depIata, String arrIata, String date) {
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
        departureScheduled: 'T:00:00',
        arrivalAirport: arrInfo['name']!,
        arrivalIATA: arrIata,
        arrivalCity: arrInfo['city']!,
        arrivalScheduled: 'T:00:00',
        airlineName: airline['name']!,
        airlineIATA: airline['iata']!,
        flightNumber: '',
        price: 150000 + (index * 50000),
      );
    });
  }

  Future<List<Map<String, String>>> getPopularAirports() async {
    return [
      {
        'iata': 'DKR',
        'city': 'Dakar',
        'name': 'Blaise Diagne',
        'country': 'Sénégal'
      },
      {
        'iata': 'DSS',
        'city': 'Dakar',
        'name': 'Blaise Diagne International',
        'country': 'Sénégal'
      },
      {
        'iata': 'CDG',
        'city': 'Paris',
        'name': 'Charles de Gaulle',
        'country': 'France'
      },
      {'iata': 'ORY', 'city': 'Paris', 'name': 'Orly', 'country': 'France'},
      {
        'iata': 'JFK',
        'city': 'New York',
        'name': 'John F. Kennedy',
        'country': 'USA'
      },
      {
        'iata': 'DXB',
        'city': 'Dubai',
        'name': 'Dubai International',
        'country': 'UAE'
      },
      {
        'iata': 'IST',
        'city': 'Istanbul',
        'name': 'Istanbul Airport',
        'country': 'Turkey'
      },
      {
        'iata': 'CMN',
        'city': 'Casablanca',
        'name': 'Mohammed V',
        'country': 'Morocco'
      },
      {
        'iata': 'ABJ',
        'city': 'Abidjan',
        'name': 'Félix Houphouët-Boigny',
        'country': 'Côte d\'Ivoire'
      },
      {
        'iata': 'BKO',
        'city': 'Bamako',
        'name': 'Modibo Keita',
        'country': 'Mali'
      },
    ];
  }
}
