class BookingModel {
  final String id;
  final String userId;
  final String bookingReference;
  final String flightNumber;
  final String airlineName;
  final String airlineIata;
  final String departureAirport;
  final String departureIata;
  final String departureCity;
  final DateTime departureTime;
  final String arrivalAirport;
  final String arrivalIata;
  final String arrivalCity;
  final DateTime arrivalTime;
  final String passengerName;
  final String passengerEmail;
  final String? passengerPhone;
  final String seatClass;
  final double price;
  final String currency;
  final String status;
  final String paymentMethod;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.bookingReference,
    required this.flightNumber,
    required this.airlineName,
    required this.airlineIata,
    required this.departureAirport,
    required this.departureIata,
    required this.departureCity,
    required this.departureTime,
    required this.arrivalAirport,
    required this.arrivalIata,
    required this.arrivalCity,
    required this.arrivalTime,
    required this.passengerName,
    required this.passengerEmail,
    this.passengerPhone,
    required this.seatClass,
    required this.price,
    this.currency = 'XOF',
    this.status = 'confirmed',
    this.paymentMethod = 'wallet',
    required this.createdAt,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      bookingReference: map['booking_reference'] as String,
      flightNumber: map['flight_number'] as String,
      airlineName: map['airline_name'] as String,
      airlineIata: map['airline_iata'] as String,
      departureAirport: map['departure_airport'] as String,
      departureIata: map['departure_iata'] as String,
      departureCity: map['departure_city'] as String,
      departureTime: DateTime.parse(map['departure_time'] as String),
      arrivalAirport: map['arrival_airport'] as String,
      arrivalIata: map['arrival_iata'] as String,
      arrivalCity: map['arrival_city'] as String,
      arrivalTime: DateTime.parse(map['arrival_time'] as String),
      passengerName: map['passenger_name'] as String,
      passengerEmail: map['passenger_email'] as String,
      passengerPhone: map['passenger_phone'] as String?,
      seatClass: map['seat_class'] as String,
      price: (map['price'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'XOF',
      status: map['status'] as String? ?? 'confirmed',
      paymentMethod: map['payment_method'] as String? ?? 'wallet',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  String get formattedPrice {
    return '${price.toStringAsFixed(0)} $currency';
  }

  String get formattedDepartureTime {
    return '${departureTime.day.toString().padLeft(2, '0')}/${departureTime.month.toString().padLeft(2, '0')}/${departureTime.year} à ${departureTime.hour.toString().padLeft(2, '0')}:${departureTime.minute.toString().padLeft(2, '0')}';
  }

  String get formattedArrivalTime {
    return '${arrivalTime.day.toString().padLeft(2, '0')}/${arrivalTime.month.toString().padLeft(2, '0')}/${arrivalTime.year} à ${arrivalTime.hour.toString().padLeft(2, '0')}:${arrivalTime.minute.toString().padLeft(2, '0')}';
  }

  String get seatClassLabel {
    switch (seatClass) {
      case 'economy':
        return 'Économique';
      case 'business':
        return 'Business';
      case 'first':
        return 'Première';
      default:
        return seatClass;
    }
  }
}