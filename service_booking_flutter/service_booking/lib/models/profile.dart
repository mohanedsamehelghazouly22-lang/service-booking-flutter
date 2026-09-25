class ProfileModel {
  final String id;
  final String role; // super_user | user | provider
  final String? fullName;
  final String? phone;
  final String? email;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? governorate;
  final String? city;

  ProfileModel({
    required this.id,
    required this.role,
    this.fullName,
    this.phone,
    this.email,
    this.avatarUrl,
    this.dateOfBirth,
    this.gender,
    this.governorate,
    this.city,
  });

  bool get isSuperUser => role == 'super_user';
  bool get isProvider => role == 'provider';

  factory ProfileModel.fromMap(Map<String, dynamic> map) => ProfileModel(
        id: map['id'] as String,
        role: map['role'] as String,
        fullName: map['full_name'] as String?,
        phone: map['phone'] as String?,
        email: map['email'] as String?,
        avatarUrl: map['avatar_url'] as String?,
        dateOfBirth: map['date_of_birth'] != null
            ? DateTime.parse(map['date_of_birth'] as String)
            : null,
        gender: map['gender'] as String?,
        governorate: map['governorate'] as String?,
        city: map['city'] as String?,
      );
}
