import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/recipe.dart';
import '../../models/order.dart';
import '../../models/favorite.dart';

class CacheService {
  static const String _recipesKey = 'cached_recipes';
  static const String _ordersKey = 'cached_orders';
  static const String _favoritesKey = 'cached_favorites';
  static const String _userProfileKey = 'cached_user_profile';
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _cacheExpiryKey = 'cache_expiry_hours';

  static const int _defaultExpiryHours = 24; // 24 hours default expiry

  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Recipe caching
  Future<void> cacheRecipes(List<Recipe> recipes) async {
    final recipesJson = recipes.map((recipe) => recipe.toJson()).toList();
    await _prefs.setString(_recipesKey, jsonEncode(recipesJson));
    await _updateLastSync();
  }

  Future<List<Recipe>> getCachedRecipes() async {
    final recipesJson = _prefs.getString(_recipesKey);
    if (recipesJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(recipesJson);
      return decoded.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> cacheRecipe(Recipe recipe) async {
    final recipes = await getCachedRecipes();
    final existingIndex = recipes.indexWhere((r) => r.id == recipe.id);

    if (existingIndex >= 0) {
      recipes[existingIndex] = recipe;
    } else {
      recipes.add(recipe);
    }

    await cacheRecipes(recipes);
  }

  Future<Recipe?> getCachedRecipe(String recipeId) async {
    final recipes = await getCachedRecipes();
    try {
      return recipes.firstWhere((recipe) => recipe.id == recipeId);
    } catch (e) {
      return null;
    }
  }

  // Order caching
  Future<void> cacheOrders(List<Order> orders) async {
    final ordersJson = orders.map((order) => order.toJson()).toList();
    await _prefs.setString(_ordersKey, jsonEncode(ordersJson));
    await _updateLastSync();
  }

  Future<List<Order>> getCachedOrders() async {
    final ordersJson = _prefs.getString(_ordersKey);
    if (ordersJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(ordersJson);
      return decoded.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> cacheOrder(Order order) async {
    final orders = await getCachedOrders();
    final existingIndex = orders.indexWhere((o) => o.id == order.id);

    if (existingIndex >= 0) {
      orders[existingIndex] = order;
    } else {
      orders.add(order);
    }

    await cacheOrders(orders);
  }

  Future<Order?> getCachedOrder(String orderId) async {
    final orders = await getCachedOrders();
    try {
      return orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Favorites caching
  Future<void> cacheFavorites(List<Favorite> favorites) async {
    final favoritesJson =
        favorites.map((favorite) => favorite.toJson()).toList();
    await _prefs.setString(_favoritesKey, jsonEncode(favoritesJson));
    await _updateLastSync();
  }

  Future<List<Favorite>> getCachedFavorites() async {
    final favoritesJson = _prefs.getString(_favoritesKey);
    if (favoritesJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(favoritesJson);
      return decoded.map((json) => Favorite.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addCachedFavorite(Favorite favorite) async {
    final favorites = await getCachedFavorites();
    favorites.add(favorite);
    await cacheFavorites(favorites);
  }

  Future<void> removeCachedFavorite(String recipeId) async {
    final favorites = await getCachedFavorites();
    favorites.removeWhere((favorite) => favorite.recipeId == recipeId);
    await cacheFavorites(favorites);
  }

  Future<bool> isCachedFavorite(String recipeId) async {
    final favorites = await getCachedFavorites();
    return favorites.any((favorite) => favorite.recipeId == recipeId);
  }

  // User profile caching
  Future<void> cacheUserProfile(Map<String, dynamic> profile) async {
    await _prefs.setString(_userProfileKey, jsonEncode(profile));
    await _updateLastSync();
  }

  Future<Map<String, dynamic>?> getCachedUserProfile() async {
    final profileJson = _prefs.getString(_userProfileKey);
    if (profileJson == null) return null;

    try {
      return jsonDecode(profileJson);
    } catch (e) {
      return null;
    }
  }

  // Cache management
  Future<void> _updateLastSync() async {
    await _prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<DateTime?> getLastSyncTime() async {
    final timestamp = _prefs.getInt(_lastSyncKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<bool> isCacheValid() async {
    final lastSync = await getLastSyncTime();
    if (lastSync == null) return false;

    final expiryHours = _prefs.getInt(_cacheExpiryKey) ?? _defaultExpiryHours;
    final expiryTime = lastSync.add(Duration(hours: expiryHours));

    return DateTime.now().isBefore(expiryTime);
  }

  Future<void> setCacheExpiry(int hours) async {
    await _prefs.setInt(_cacheExpiryKey, hours);
  }

  Future<void> clearCache() async {
    await _prefs.remove(_recipesKey);
    await _prefs.remove(_ordersKey);
    await _prefs.remove(_favoritesKey);
    await _prefs.remove(_userProfileKey);
    await _prefs.remove(_lastSyncKey);
  }

  Future<void> clearExpiredCache() async {
    if (!await isCacheValid()) {
      await clearCache();
    }
  }

  // Cache statistics
  Future<Map<String, int>> getCacheStats() async {
    final recipes = await getCachedRecipes();
    final orders = await getCachedOrders();
    final favorites = await getCachedFavorites();
    final lastSync = await getLastSyncTime();

    return {
      'recipes_count': recipes.length,
      'orders_count': orders.length,
      'favorites_count': favorites.length,
      'last_sync_hours_ago':
          lastSync != null ? DateTime.now().difference(lastSync).inHours : -1,
    };
  }

  // Offline queue for pending operations
  Future<void> addToOfflineQueue(
      String operation, Map<String, dynamic> data) async {
    final queueKey = 'offline_queue';
    final queueJson = _prefs.getString(queueKey) ?? '[]';

    try {
      final List<dynamic> queue = jsonDecode(queueJson);
      queue.add({
        'operation': operation,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      await _prefs.setString(queueKey, jsonEncode(queue));
    } catch (e) {
      // Handle error
    }
  }

  Future<List<Map<String, dynamic>>> getOfflineQueue() async {
    final queueKey = 'offline_queue';
    final queueJson = _prefs.getString(queueKey) ?? '[]';

    try {
      final List<dynamic> queue = jsonDecode(queueJson);
      return queue.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearOfflineQueue() async {
    await _prefs.remove('offline_queue');
  }

  Future<void> removeFromOfflineQueue(int index) async {
    final queue = await getOfflineQueue();
    if (index >= 0 && index < queue.length) {
      queue.removeAt(index);
      await _prefs.setString('offline_queue', jsonEncode(queue));
    }
  }
}
