class Address {
  final String id;
  final String street;
  final String city;
  final String area;
  final String building;
  final String floor;
  final String apartment;
  final String instructions;
  final double latitude;
  final double longitude;
  final bool isDefault;

  const Address({
    required this.id,
    required this.street,
    required this.city,
    required this.area,
    this.building = '',
    this.floor = '',
    this.apartment = '',
    this.instructions = '',
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      area: json['area'] ?? '',
      building: json['building'] ?? '',
      floor: json['floor'] ?? '',
      apartment: json['apartment'] ?? '',
      instructions: json['instructions'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'city': city,
      'area': area,
      'building': building,
      'floor': floor,
      'apartment': apartment,
      'instructions': instructions,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
    };
  }

  String get fullAddress {
    final parts = [
      if (building.isNotEmpty) 'Building $building',
      if (floor.isNotEmpty) 'Floor $floor',
      if (apartment.isNotEmpty) 'Apt $apartment',
      street,
      area,
      city,
    ].where((part) => part.isNotEmpty);
    return parts.join(', ');
  }

  Address copyWith({
    String? id,
    String? street,
    String? city,
    String? area,
    String? building,
    String? floor,
    String? apartment,
    String? instructions,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      street: street ?? this.street,
      city: city ?? this.city,
      area: area ?? this.area,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      apartment: apartment ?? this.apartment,
      instructions: instructions ?? this.instructions,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}