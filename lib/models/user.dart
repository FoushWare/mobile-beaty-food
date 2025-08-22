import 'package:baty_bites/models/address.dart';

enum UserType { customer, chef }

enum ProfileCompletionLevel {
  mobileVerified,
  basicProfile,
  completeProfile,
  chefVerified,
}

enum DietaryRestriction { vegetarian, vegan, glutenFree, nutFree, halal }

class User {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String profileImage;
  final UserType userType;
  final ProfileCompletionLevel? profileLevel;
  final DateTime createdAt;
  final bool isVerified;
  final bool isActive;
  final double rating;
  final int totalReviews;
  final Address? address;
  final UserPreferences? preferences;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.userType,
    this.profileLevel,
    required this.createdAt,
    this.isVerified = false,
    this.isActive = true,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.address,
    this.preferences,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profileImage'] ?? '',
      userType: UserType.values.firstWhere(
        (type) => type.name == json['userType'],
        orElse: () => UserType.customer,
      ),
      profileLevel: json['profileLevel'] != null
          ? ProfileCompletionLevel.values.firstWhere(
              (level) => level.name == json['profileLevel'],
              orElse: () => ProfileCompletionLevel.mobileVerified,
            )
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
      preferences: json['preferences'] != null ? UserPreferences.fromJson(json['preferences']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'userType': userType.name,
      'profileLevel': profileLevel?.name,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
      'isActive': isActive,
      'rating': rating,
      'totalReviews': totalReviews,
      'address': address?.toJson(),
      'preferences': preferences?.toJson(),
    };
  }

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? profileImage,
    UserType? userType,
    ProfileCompletionLevel? profileLevel,
    DateTime? createdAt,
    bool? isVerified,
    bool? isActive,
    double? rating,
    int? totalReviews,
    Address? address,
    UserPreferences? preferences,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      userType: userType ?? this.userType,
      profileLevel: profileLevel ?? this.profileLevel,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      address: address ?? this.address,
      preferences: preferences ?? this.preferences,
    );
  }
}

class UserPreferences {
  final List<DietaryRestriction> dietaryRestrictions;
  final List<String> favoriteCuisines;
  final String spicePreference; // mild, medium, hot

  const UserPreferences({
    this.dietaryRestrictions = const [],
    this.favoriteCuisines = const [],
    this.spicePreference = 'medium',
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      dietaryRestrictions: (json['dietaryRestrictions'] as List<dynamic>? ?? [])
          .map((e) => DietaryRestriction.values.firstWhere(
                (restriction) => restriction.name == e,
                orElse: () => DietaryRestriction.halal,
              ))
          .toList(),
      favoriteCuisines: List<String>.from(json['favoriteCuisines'] ?? []),
      spicePreference: json['spicePreference'] ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dietaryRestrictions': dietaryRestrictions.map((e) => e.name).toList(),
      'favoriteCuisines': favoriteCuisines,
      'spicePreference': spicePreference,
    };
  }
}