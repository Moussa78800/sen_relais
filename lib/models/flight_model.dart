class FlightModel {
  final String flightDate;
  final String flightStatus;
  final String departureAirport;
  final String departureIATA;
  final String departureCity;
  final String departureScheduled;
  final String arrivalAirport;
  final String arrivalIATA;
  final String arrivalCity;
  final String arrivalScheduled;
  final String airlineName;
  final String airlineIATA;
  final String flightNumber;
  final int? price; // Prix en XOF (simulé)

  FlightModel({
    required this.flightDate,
    required this.flightStatus,
    required this.departureAirport,
    required this.departureIATA,
    required this.departureCity,
    required this.departureScheduled,
    required this.arrivalAirport,
    required this.arrivalIATA,
    required this.arrivalCity,
    required this.arrivalScheduled,
    required this.airlineName,
    required this.airlineIATA,
    required this.flightNumber,
    this.price,
  });

  factory FlightModel.fromJson(Map<String, dynamic> json) {
    final departure = json['departure'] as Map<String, dynamic>;
    final arrival = json['arrival'] as Map<String, dynamic>;
    final airline = json['airline'] as Map<String, dynamic>;
    final flight = json['flight'] as Map<String, dynamic>;

    return FlightModel(
      flightDate: json['flight_date'] ?? '',
      flightStatus: json['flight_status'] ?? 'scheduled',
      departureAirport: departure['airport'] ?? '',
      departureIATA: departure['iata'] ?? '',
      departureCity: departure['city'] ?? '',
      departureScheduled: departure['scheduled'] ?? '',
      arrivalAirport: arrival['airport'] ?? '',
      arrivalIATA: arrival['iata'] ?? '',
      arrivalCity: arrival['city'] ?? '',
      arrivalScheduled: arrival['scheduled'] ?? '',
      airlineName: airline['name'] ?? '',
      airlineIATA: airline['iata'] ?? '',
      flightNumber: '${airline['iata'] ?? ''}${flight['iata'] ?? ''}',
      price: _generateRandomPrice(),
    );
  }

  // Simuler un prix réaliste (à remplacer par une vraie API de prix plus tard)
  static int _generateRandomPrice() {
    final basePrices = [
      150000, 180000, 220000, 250000, 280000, 320000, 350000, 400000, 450000
    ];
    return basePrices[(DateTime.now().millisecond % basePrices.length)];
  }

  // Calculer la durée du vol
  Duration get flightDuration {
    try {
      final dep = DateTime.parse(departureScheduled);
      final arr = DateTime.parse(arrivalScheduled);
      return arr.difference(dep);
    } catch (e) {
      return Duration.zero;
    }
  }

  String get formattedDuration {
    final duration = flightDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}min';
  }

  String get formattedDepartureTime {
    try {
      final time = DateTime.parse(departureScheduled);
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }

  String get formattedArrivalTime {
    try {
      final time = DateTime.parse(arrivalScheduled);
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }

  String get formattedPrice {
    return '${price?.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        )} XOF';
  }
}