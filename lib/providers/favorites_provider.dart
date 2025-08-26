import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/favorites_service.dart';
import '../models/favorite.dart';
import '../models/recipe.dart';

class FavoritesState {
  final List<Favorite> favorites;
  final Set<String> favoriteRecipeIds;
  final bool isLoading;
  final String? error;

  const FavoritesState({
    this.favorites = const [],
    this.favoriteRecipeIds = const {},
    this.isLoading = false,
    this.error,
  });

  FavoritesState copyWith({
    List<Favorite>? favorites,
    Set<String>? favoriteRecipeIds,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      favoriteRecipeIds: favoriteRecipeIds ?? this.favoriteRecipeIds,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final FavoritesService _favoritesService = FavoritesService();

  FavoritesNotifier() : super(const FavoritesState());

  /// Load user's favorites
  Future<void> loadFavorites({
    int page = 1,
    int limit = 10,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final favorites = await _favoritesService.getFavorites(
        page: page,
        limit: limit,
      );

      // If it's the first page, replace the list, otherwise append
      final updatedFavorites =
          page == 1 ? favorites : [...state.favorites, ...favorites];

      // Update favorite recipe IDs set
      final updatedFavoriteIds = <String>{};
      for (final favorite in updatedFavorites) {
        updatedFavoriteIds.add(favorite.recipeId);
      }

      state = state.copyWith(
        favorites: updatedFavorites,
        favoriteRecipeIds: updatedFavoriteIds,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Add recipe to favorites
  Future<void> addToFavorites(String recipeId) async {
    try {
      final favorite = await _favoritesService.addToFavorites(recipeId);

      state = state.copyWith(
        favorites: [favorite, ...state.favorites],
        favoriteRecipeIds: {...state.favoriteRecipeIds, recipeId},
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Remove recipe from favorites
  Future<void> removeFromFavorites(String recipeId) async {
    try {
      await _favoritesService.removeFromFavorites(recipeId);

      state = state.copyWith(
        favorites:
            state.favorites.where((f) => f.recipeId != recipeId).toList(),
        favoriteRecipeIds: state.favoriteRecipeIds.difference({recipeId}),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String recipeId) async {
    if (state.favoriteRecipeIds.contains(recipeId)) {
      await removeFromFavorites(recipeId);
    } else {
      await addToFavorites(recipeId);
    }
  }

  /// Check if recipe is in favorites
  bool isFavorite(String recipeId) {
    return state.favoriteRecipeIds.contains(recipeId);
  }

  /// Get favorite recipes by category
  Future<List<Recipe>> getFavoriteRecipesByCategory(String category) async {
    try {
      return await _favoritesService.getFavoriteRecipesByCategory(category);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  /// Clear all favorites
  Future<void> clearAllFavorites() async {
    try {
      await _favoritesService.clearAllFavorites();
      state = state.copyWith(
        favorites: [],
        favoriteRecipeIds: {},
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Refresh favorites status for a recipe
  Future<void> refreshFavoriteStatus(String recipeId) async {
    try {
      final isFavorite = await _favoritesService.isFavorite(recipeId);

      if (isFavorite && !state.favoriteRecipeIds.contains(recipeId)) {
        state = state.copyWith(
          favoriteRecipeIds: {...state.favoriteRecipeIds, recipeId},
        );
      } else if (!isFavorite && state.favoriteRecipeIds.contains(recipeId)) {
        state = state.copyWith(
          favoriteRecipeIds: state.favoriteRecipeIds.difference({recipeId}),
        );
      }
    } catch (e) {
      // Silently fail for status refresh
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier();
});

// Convenience providers
final favoriteRecipesProvider = Provider<List<Recipe>>((ref) {
  final favoritesState = ref.watch(favoritesProvider);
  return favoritesState.favorites.map((f) => f.recipe).toList();
});

final favoriteRecipeIdsProvider = Provider<Set<String>>((ref) {
  final favoritesState = ref.watch(favoritesProvider);
  return favoritesState.favoriteRecipeIds;
});

final isFavoriteProvider = Provider.family<bool, String>((ref, recipeId) {
  final favoriteIds = ref.watch(favoriteRecipeIdsProvider);
  return favoriteIds.contains(recipeId);
});
