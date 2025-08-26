import 'package:baty_bites/models/review.dart';

enum DifficultyLevel { easy, medium, hard }
enum SpiceLevel { mild, medium, hot, extraHot }

class Recipe {
  final String id;
  final String chefId;
  final String chefName;
  final String chefImage;
  final String title;
  final String description;
  final List<Ingredient> ingredients;
  final List<CookingStep> instructions;
  final double price;
  final String currency;
  final List<String> images;
  final String cuisineType;
  final String category;
  final int preparationTime; // minutes
  final int cookingTime; // minutes
  final int servings;
  final DifficultyLevel difficulty;
  final SpiceLevel spiceLevel;
  final DietaryInfo dietaryInfo;
  final NutritionInfo? nutritionInfo;
  final List<String> tags;
  final bool isAvailable;
  final bool isFeatured;
  final int orderCount;
  final double rating;
  final int totalReviews;
  final List<Review> reviews;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Recipe({
    required this.id,
    required this.chefId,
    required this.chefName,
    this.chefImage = '',
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.price,
    this.currency = 'EGP',
    required this.images,
    required this.cuisineType,
    required this.category,
    required this.preparationTime,
    required this.cookingTime,
    required this.servings,
    required this.difficulty,
    required this.spiceLevel,
    required this.dietaryInfo,
    this.nutritionInfo,
    this.tags = const [],
    this.isAvailable = true,
    this.isFeatured = false,
    this.orderCount = 0,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.reviews = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // Handle nested chef object from backend
    final chefData = json['chef'] as Map<String, dynamic>? ?? {};
    final imagesData = json['images'] as List<dynamic>? ?? [];
    
    return Recipe(
      id: json['id'] ?? '',
      chefId: json['chefId'] ?? '',
      chefName: chefData['fullName'] ?? '',
      chefImage: chefData['profileImage'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      ingredients: (json['ingredients'] as List<dynamic>? ?? [])
          .map((e) => Ingredient.fromJson(e))
          .toList(),
      instructions: (json['instructions'] as List<dynamic>? ?? [])
          .map((e) => CookingStep.fromJson(e))
          .toList(),
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'EGP',
      images: imagesData.map((img) => img['url'] as String).toList(),
      cuisineType: json['cuisineType'] ?? '',
      category: json['category'] ?? '',
      preparationTime: json['preparationTime'] ?? 0,
      cookingTime: json['cookingTime'] ?? 0,
      servings: json['servings'] ?? 1,
      difficulty: DifficultyLevel.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => DifficultyLevel.medium,
      ),
      spiceLevel: SpiceLevel.values.firstWhere(
        (s) => s.name == json['spiceLevel'],
        orElse: () => SpiceLevel.medium,
      ),
      dietaryInfo: DietaryInfo.fromJson(json['dietaryInfo'] ?? {}),
      nutritionInfo: json['nutritionInfo'] != null
          ? NutritionInfo.fromJson(json['nutritionInfo'])
          : null,
      tags: List<String>.from(json['tags'] ?? []),
      isAvailable: json['isAvailable'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      orderCount: json['orderCount'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      reviews: (json['reviews'] as List<dynamic>? ?? [])
          .map((e) => Review.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chefId': chefId,
      'chefName': chefName,
      'chefImage': chefImage,
      'title': title,
      'description': description,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'instructions': instructions.map((e) => e.toJson()).toList(),
      'price': price,
      'currency': currency,
      'images': images,
      'cuisineType': cuisineType,
      'category': category,
      'preparationTime': preparationTime,
      'cookingTime': cookingTime,
      'servings': servings,
      'difficulty': difficulty.name,
      'spiceLevel': spiceLevel.name,
      'dietaryInfo': dietaryInfo.toJson(),
      'nutritionInfo': nutritionInfo?.toJson(),
      'tags': tags,
      'isAvailable': isAvailable,
      'isFeatured': isFeatured,
      'orderCount': orderCount,
      'rating': rating,
      'totalReviews': totalReviews,
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  int get totalTime => preparationTime + cookingTime;

  String get difficultyText {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 'سهل';
      case DifficultyLevel.medium:
        return 'متوسط';
      case DifficultyLevel.hard:
        return 'صعب';
    }
  }

  String get spiceLevelText {
    switch (spiceLevel) {
      case SpiceLevel.mild:
        return 'خفيف';
      case SpiceLevel.medium:
        return 'متوسط';
      case SpiceLevel.hot:
        return 'حار';
      case SpiceLevel.extraHot:
        return 'حار جداً';
    }
  }
}

class Ingredient {
  final String name;
  final String quantity;
  final String unit;
  final String notes;

  const Ingredient({
    required this.name,
    required this.quantity,
    required this.unit,
    this.notes = '',
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? '',
      unit: json['unit'] ?? '',
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
    };
  }

  String get displayText => '$quantity $unit $name${notes.isNotEmpty ? ' ($notes)' : ''}';
}

class CookingStep {
  final int stepNumber;
  final String instruction;
  final int? timeMinutes;
  final String? image;

  const CookingStep({
    required this.stepNumber,
    required this.instruction,
    this.timeMinutes,
    this.image,
  });

  factory CookingStep.fromJson(Map<String, dynamic> json) {
    return CookingStep(
      stepNumber: json['stepNumber'] ?? 0,
      instruction: json['instruction'] ?? '',
      timeMinutes: json['timeMinutes'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'instruction': instruction,
      'timeMinutes': timeMinutes,
      'image': image,
    };
  }
}

class DietaryInfo {
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final bool isNutFree;
  final bool isHalal;

  const DietaryInfo({
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    this.isNutFree = false,
    this.isHalal = true,
  });

  factory DietaryInfo.fromJson(Map<String, dynamic> json) {
    return DietaryInfo(
      isVegetarian: json['isVegetarian'] ?? false,
      isVegan: json['isVegan'] ?? false,
      isGlutenFree: json['isGlutenFree'] ?? false,
      isNutFree: json['isNutFree'] ?? false,
      isHalal: json['isHalal'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'isGlutenFree': isGlutenFree,
      'isNutFree': isNutFree,
      'isHalal': isHalal,
    };
  }
}

class NutritionInfo {
  final int calories;
  final int protein; // grams
  final int carbs; // grams
  final int fat; // grams
  final int fiber; // grams

  const NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: json['calories'] ?? 0,
      protein: json['protein'] ?? 0,
      carbs: json['carbs'] ?? 0,
      fat: json['fat'] ?? 0,
      fiber: json['fiber'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
    };
  }
}