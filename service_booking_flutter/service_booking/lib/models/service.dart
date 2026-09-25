class ServiceModel {
  final String id;
  final String? categoryId;
  final String name;
  final String? description;
  final int durationMinutes;
  final double? price;
  final bool active;
  final String? imageUrl;
  final List<String> galleryImages;

  ServiceModel({
    required this.id,
    this.categoryId,
    required this.name,
    this.description,
    required this.durationMinutes,
    this.price,
    required this.active,
    this.imageUrl,
    this.galleryImages = const [],
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) => ServiceModel(
        id: map['id'] as String,
        categoryId: map['category_id'] as String?,
        name: map['name'] as String,
        description: map['description'] as String?,
        durationMinutes: (map['duration_minutes'] as num?)?.toInt() ?? 30,
        price: (map['price'] as num?)?.toDouble(),
        active: map['active'] as bool? ?? true,
        imageUrl: map['image_url'] as String?,
        galleryImages: (map['service_images'] as List<dynamic>? ?? [])
            .map((e) => (e as Map<String, dynamic>)['image_url'] as String)
            .toList(),
      );
}
