import 'dart:convert';
import 'package:dio/dio.dart';
import '../../models/recipe.dart';

class RecipeService {
  static const String _baseUrl = 'http://localhost:3000/api';
  static const String _recipesBaseUrl = '$_baseUrl/recipes';
  
  late final Dio _dio;
  
  RecipeService() {
    _dio = Dio(BaseOptions(
      baseUrl: _recipesBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }

  /// Get all recipes
  Future<List<Recipe>> getAllRecipes() async {
    try {
      final response = await _dio.get('/');
      
      if (response.data['success'] == true) {
        final List<dynamic> recipesData = response.data['data'];
        return recipesData.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch recipes');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get recipe by ID
  Future<Recipe?> getRecipeById(String id) async {
    try {
      final response = await _dio.get('/$id');
      
      if (response.data['success'] == true && response.data['data'] != null) {
        return Recipe.fromJson(response.data['data']);
      } else {
        return null;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get recipes by chef
  Future<List<Recipe>> getRecipesByChef(String chefId) async {
    try {
      final response = await _dio.get('/chef/$chefId');
      
      if (response.data['success'] == true) {
        final List<dynamic> recipesData = response.data['data'];
        return recipesData.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch chef recipes');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get recipes by category
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      final response = await _dio.get('/category/$category');
      
      if (response.data['success'] == true) {
        final List<dynamic> recipesData = response.data['data'];
        return recipesData.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch category recipes');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get recipes by cuisine
  Future<List<Recipe>> getRecipesByCuisine(String cuisine) async {
    try {
      final response = await _dio.get('/cuisine/$cuisine');
      
      if (response.data['success'] == true) {
        final List<dynamic> recipesData = response.data['data'];
        return recipesData.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch cuisine recipes');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Search recipes
  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      final response = await _dio.get('/search', queryParameters: {'q': query});
      
      if (response.data['success'] == true) {
        final List<dynamic> recipesData = response.data['data'];
        return recipesData.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to search recipes');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Filter recipes
  Future<List<Recipe>> filterRecipes({
    String? category,
    String? cuisine,
    bool? isVegetarian,
    bool? isVegan,
    bool? isGlutenFree,
    bool? isHalal,
    String? difficulty,
    double? minPrice,
    double? maxPrice,
    int? maxPrepTime,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      
      if (category != null) queryParams['category'] = category;
      if (cuisine != null) queryParams['cuisine'] = cuisine;
      if (isVegetarian != null) queryParams['isVegetarian'] = isVegetarian.toString();
      if (isVegan != null) queryParams['isVegan'] = isVegan.toString();
      if (isGlutenFree != null) queryParams['isGlutenFree'] = isGlutenFree.toString();
      if (isHalal != null) queryParams['isHalal'] = isHalal.toString();
      if (difficulty != null) queryParams['difficulty'] = difficulty;
      if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
      if (maxPrepTime != null) queryParams['maxPrepTime'] = maxPrepTime.toString();

      final response = await _dio.get('/filter', queryParameters: queryParams);
      
      if (response.data['success'] == true) {
        final List<dynamic> recipesData = response.data['data'];
        return recipesData.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to filter recipes');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get all categories
  Future<List<String>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      
      if (response.data['success'] == true) {
        final List<dynamic> categoriesData = response.data['data'];
        return categoriesData.map((category) => category.toString()).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch categories');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get all cuisines
  Future<List<String>> getCuisines() async {
    try {
      try {
        final response = await _dio.get('/cuisines');
        
        if (response.data['success'] == true) {
          final List<dynamic> cuisinesData = response.data['data'];
          return cuisinesData.map((cuisine) => cuisine.toString()).toList();
        } else {
          throw Exception(response.data['message'] ?? 'Failed to fetch cuisines');
        }
      } on DioException catch (e) {
        throw Exception(_handleDioError(e));
      } catch (e) {
        throw Exception('Unexpected error: $e');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  String _handleDioError(DioException e) {
    if (e.response?.data != null) {
      try {
        final errorData = e.response!.data;
        return errorData['message'] ?? 'Network error';
      } catch (_) {
        // Fallback to generic error
      }
    }

    String message = 'Network error';
    if (e.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      message = 'Request timeout';
    } else if (e.type == DioExceptionType.connectionError) {
      message = 'No internet connection';
    }

    return message;
  }
}




