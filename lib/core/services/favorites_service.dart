import 'package:dio/dio.dart';
import '../utils/api_client.dart';
import '../utils/storage_service.dart';
import '../../models/favorite.dart';
import '../../models/recipe.dart';

class FavoritesService {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = StorageService();

  Future<Map<String, dynamic>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Get user's favorites
  Future<List<Favorite>> getFavorites({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParameters = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await _apiClient.dio.get(
        '/favorites',
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Favorite.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get favorites: ${e.toString()}');
    }
  }

  /// Add recipe to favorites
  Future<Favorite> addToFavorites(String recipeId) async {
    try {
      final headers = await _getHeaders();
      final response = await _apiClient.dio.post(
        '/favorites',
        data: {'recipeId': recipeId},
        options: Options(headers: headers),
      );

      return Favorite.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to add to favorites: ${e.toString()}');
    }
  }

  /// Remove recipe from favorites
  Future<void> removeFromFavorites(String recipeId) async {
    try {
      final headers = await _getHeaders();
      await _apiClient.dio.delete(
        '/favorites/$recipeId',
        options: Options(headers: headers),
      );
    } catch (e) {
      throw Exception('Failed to remove from favorites: ${e.toString()}');
    }
  }

  /// Check if recipe is in favorites
  Future<bool> isFavorite(String recipeId) async {
    try {
      final headers = await _getHeaders();
      final response = await _apiClient.dio.get(
        '/favorites/check/$recipeId',
        options: Options(headers: headers),
      );

      return response.data['isFavorite'] ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get favorite recipes by category
  Future<List<Recipe>> getFavoriteRecipesByCategory(String category) async {
    try {
      final headers = await _getHeaders();
      final response = await _apiClient.dio.get(
        '/favorites/category/$category',
        options: Options(headers: headers),
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      throw Exception(
          'Failed to get favorite recipes by category: ${e.toString()}');
    }
  }

  /// Clear all favorites
  Future<void> clearAllFavorites() async {
    try {
      final headers = await _getHeaders();
      await _apiClient.dio.delete(
        '/favorites/clear',
        options: Options(headers: headers),
      );
    } catch (e) {
      throw Exception('Failed to clear favorites: ${e.toString()}');
    }
  }
}
