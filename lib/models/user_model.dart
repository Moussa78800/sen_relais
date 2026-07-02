class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String country;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.country = 'SN',
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: map['full_name'] as String?,
      phone: map['phone'] as String?,
      country: map['country'] as String? ?? 'SN',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'country': country,
    };
  }

  UserModel copyWith({String? fullName, String? phone, String? country}) {
    return UserModel(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      createdAt: createdAt,
    );
  }
}
