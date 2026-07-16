class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String? address;
  final bool isAdmin;
  final bool isBlocked;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.address,
    this.isAdmin = false,
    this.isBlocked = false,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['full_name'],
      phone: map['phone'],
      address: map['address'],
      isAdmin: map['is_admin'] ?? false,
      isBlocked: map['is_blocked'] ?? false,
      emailNotifications: map['email_notifications'] ?? true,
      pushNotifications: map['push_notifications'] ?? true,
      smsNotifications: map['sms_notifications'] ?? false,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'is_admin': isAdmin,
      'is_blocked': isBlocked,
      'email_notifications': emailNotifications,
      'push_notifications': pushNotifications,
      'sms_notifications': smsNotifications,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
