class InsuranceModel {
  final String id;
  final String type; // 'voyage', 'sante', 'auto'
  final String reference;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final double price;
  final String coverage; // Niveau de couverture
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> details; // Détails spécifiques au type
  final String status; // 'pending', 'active', 'expired'
  final DateTime createdAt;

  InsuranceModel({
    required this.id,
    required this.type,
    required this.reference,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.price,
    required this.coverage,
    required this.startDate,
    required this.endDate,
    required this.details,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'reference': reference,
      'client_name': clientName,
      'client_email': clientEmail,
      'client_phone': clientPhone,
      'price': price,
      'coverage': coverage,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'details': details,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory InsuranceModel.fromMap(Map<String, dynamic> map) {
    return InsuranceModel(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      reference: map['reference'] ?? '',
      clientName: map['client_name'] ?? '',
      clientEmail: map['client_email'] ?? '',
      clientPhone: map['client_phone'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      coverage: map['coverage'] ?? '',
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      details: Map<String, dynamic>.from(map['details'] ?? {}),
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  String get typeLabel {
    switch (type) {
      case 'voyage':
        return 'Assurance Voyage';
      case 'sante':
        return 'Assurance Santé';
      case 'auto':
        return 'Assurance Auto';
      default:
        return type;
    }
  }

  String get formattedPrice {
    return '${price.toStringAsFixed(0)} XOF';
  }
}
