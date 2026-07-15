class ApartmentModel {
  final String id;
  final String title;
  final String description;
  final double pricePerMonth;
  final String location;
  final int capacity;
  final List<String> amenities;
  final String imageUrl;
  final bool isAvailable;

  ApartmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.pricePerMonth,
    required this.location,
    required this.capacity,
    required this.amenities,
    required this.imageUrl,
    required this.isAvailable,
  });

  factory ApartmentModel.fromMap(Map<String, dynamic> map) {
    return ApartmentModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      pricePerMonth: (map['price_per_month'] as num?)?.toDouble() ?? 0.0,
      location: map['location'] ?? '',
      capacity: map['capacity'] ?? 1,
      amenities: List<String>.from(map['amenities'] ?? []),
      imageUrl: map['image_url'] ??
          'https://via.placeholder.com/800x600?text=SEN+RELAIS',
      isAvailable: map['is_available'] ?? true,
    );
  }

  String get formattedPrice => '${pricePerMonth.toStringAsFixed(0)} XOF / mois';
}
