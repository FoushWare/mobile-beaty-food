import 'package:flutter/foundation.dart';
import 'package:baty_bites/models/recipe.dart';
import 'package:baty_bites/core/services/recipe_service.dart';

class RecipeProvider extends ChangeNotifier {
  List<Recipe> _recipes = [];
  List<Recipe> _featuredRecipes = [];
  final List<String> _favoriteIds = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  String _selectedCuisineType = '';

  final RecipeService _recipeService = RecipeService();

  List<Recipe> get recipes => _recipes;
  List<Recipe> get featuredRecipes => _featuredRecipes;
  List<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedCuisineType => _selectedCuisineType;

  List<Recipe> get filteredRecipes {
    var filtered = _recipes.where((recipe) {
      bool matchesSearch = _searchQuery.isEmpty ||
          recipe.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          recipe.description
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          recipe.cuisineType.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesCategory =
          _selectedCategory == 'الكل' || recipe.category == _selectedCategory;

      bool matchesCuisine = _selectedCuisineType.isEmpty ||
          recipe.cuisineType == _selectedCuisineType;

      return matchesSearch && matchesCategory && matchesCuisine;
    }).toList();

    // Sort by featured first, then by rating
    filtered.sort((a, b) {
      if (a.isFeatured && !b.isFeatured) return -1;
      if (!a.isFeatured && b.isFeatured) return 1;
      return b.rating.compareTo(a.rating);
    });

    return filtered;
  }

  Future<void> loadRecipes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final recipes = await _recipeService.getAllRecipes();
      _recipes = recipes;
      _featuredRecipes = _recipes.where((recipe) => recipe.isFeatured).toList();
    } catch (e) {
      debugPrint('Error loading recipes: $e');
      // Fallback to sample data if API fails
      _recipes = [];
      _featuredRecipes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchRecipes(String query) async {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setCuisineType(String cuisineType) {
    _selectedCuisineType = cuisineType;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'الكل';
    _selectedCuisineType = '';
    notifyListeners();
  }

  Recipe? getRecipeById(String id) {
    try {
      return _recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }

  bool isFavorite(String recipeId) {
    return _favoriteIds.contains(recipeId);
  }

  Future<void> toggleFavorite(String recipeId) async {
    if (_favoriteIds.contains(recipeId)) {
      _favoriteIds.remove(recipeId);
    } else {
      _favoriteIds.add(recipeId);
    }
    notifyListeners();

    // TODO: Save to storage and sync with API
  }

  List<Recipe> get favoriteRecipes {
    return _recipes
        .where((recipe) => _favoriteIds.contains(recipe.id))
        .toList();
  }

  List<Recipe> getRecipesByChef(String chefId) {
    return _recipes.where((recipe) => recipe.chefId == chefId).toList();
  }

  List<Recipe> getRecipesByCategory(String category) {
    return _recipes.where((recipe) => recipe.category == category).toList();
  }

  List<Recipe> getRecipesByCuisine(String cuisineType) {
    return _recipes
        .where((recipe) => recipe.cuisineType == cuisineType)
        .toList();
  }

  Future<void> refreshRecipes() async {
    await loadRecipes();
  }
}
