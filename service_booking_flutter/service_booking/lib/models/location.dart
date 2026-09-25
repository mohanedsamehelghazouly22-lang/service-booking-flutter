class LocationModel {
  final String id;
  final String name;
  final String? address;
  final String? city;
  final double? lat;
  final double? lng;
  final String bookingType; // 'pending' | 'instant'
  final bool active;
  final String? imageUrl;
  final String? phone;

  LocationModel({
    required this.id,
    required this.name,
    this.address,
    this.city,
    this.lat,
    this.lng,
    required this.bookingType,
    required this.active,
    this.imageUrl,
    this.phone,
  });

  bool get isInstant => bookingType == 'instant';

  factory LocationModel.fromMap(Map<String, dynamic> map) => LocationModel(
        id: map['id'] as String,
        name: map['name'] as String,
        address: map['address'] as String?,
        city: map['city'] as String?,
        lat: (map['lat'] as num?)?.toDouble(),
        lng: (map['lng'] as num?)?.toDouble(),
        bookingType: map['service_booking_type'] as String? ?? 'pending',
        active: map['active'] as bool? ?? true,
        imageUrl: map['image_url'] as String?,
        phone: map['phone'] as String?,
      );
}
