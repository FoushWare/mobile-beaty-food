import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'cache_service.dart';
import '../utils/api_client.dart';
import '../utils/storage_service.dart';

enum ConnectionStatus {
  connected,
  disconnected,
  unknown,
}

class OfflineService {
  final CacheService _cacheService = CacheService();
  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = StorageService();

  final StreamController<ConnectionStatus> _connectionController =
      StreamController<ConnectionStatus>.broadcast();

  Stream<ConnectionStatus> get connectionStream => _connectionController.stream;
  ConnectionStatus _currentStatus = ConnectionStatus.unknown;

  Future<void> initialize() async {
    await _cacheService.initialize();
    await _storageService.initialize();
    await _setupConnectivityListener();
  }

  Future<void> _setupConnectivityListener() async {
    // Check initial connectivity
    await _checkConnectivity();

    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _handleConnectivityChange(result);
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _handleConnectivityChange(result);
    } catch (e) {
      _updateConnectionStatus(ConnectionStatus.unknown);
    }
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
        _updateConnectionStatus(ConnectionStatus.connected);
        _syncOfflineQueue();
        break;
      case ConnectivityResult.none:
        _updateConnectionStatus(ConnectionStatus.disconnected);
        break;
      default:
        _updateConnectionStatus(ConnectionStatus.unknown);
    }
  }

  void _updateConnectionStatus(ConnectionStatus status) {
    _currentStatus = status;
    _connectionController.add(status);
  }

  ConnectionStatus get currentStatus => _currentStatus;

  bool get isConnected => _currentStatus == ConnectionStatus.connected;

  // Offline queue operations
  Future<void> addToOfflineQueue(
      String operation, Map<String, dynamic> data) async {
    await _cacheService.addToOfflineQueue(operation, data);
  }

  Future<List<Map<String, dynamic>>> getOfflineQueue() async {
    return await _cacheService.getOfflineQueue();
  }

  Future<void> clearOfflineQueue() async {
    await _cacheService.clearOfflineQueue();
  }

  // Sync offline queue when connection is restored
  Future<void> _syncOfflineQueue() async {
    if (!isConnected) return;

    final queue = await getOfflineQueue();
    if (queue.isEmpty) return;

    final token = await _storageService.getToken();
    if (token == null) return;

    final List<int> successfulOperations = [];

    for (int i = 0; i < queue.length; i++) {
      final operation = queue[i];
      final success = await _processOfflineOperation(operation);

      if (success) {
        successfulOperations.add(i);
      }
    }

    // Remove successful operations from queue
    for (int i = successfulOperations.length - 1; i >= 0; i--) {
      await _cacheService.removeFromOfflineQueue(successfulOperations[i]);
    }
  }

  Future<bool> _processOfflineOperation(Map<String, dynamic> operation) async {
    try {
      final String opType = operation['operation'];
      final Map<String, dynamic> data = operation['data'];

      switch (opType) {
        case 'add_to_favorites':
          return await _syncAddToFavorites(data);
        case 'remove_from_favorites':
          return await _syncRemoveFromFavorites(data);
        case 'create_order':
          return await _syncCreateOrder(data);
        case 'update_profile':
          return await _syncUpdateProfile(data);
        case 'add_review':
          return await _syncAddReview(data);
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> _syncAddToFavorites(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(
        '/favorites',
        data: {'recipeId': data['recipeId']},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _syncRemoveFromFavorites(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.delete(
        '/favorites/${data['recipeId']}',
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _syncCreateOrder(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(
        '/orders',
        data: data,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _syncUpdateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.patch(
        '/profile',
        data: data,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _syncAddReview(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(
        '/recipes/${data['recipeId']}/reviews',
        data: data,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Cache management
  Future<void> cacheRecipes(List<dynamic> recipes) async {
    // Convert to Recipe objects and cache
    // Implementation depends on your Recipe model
  }

  Future<List<dynamic>> getCachedRecipes() async {
    return await _cacheService.getCachedRecipes();
  }

  Future<void> cacheOrders(List<dynamic> orders) async {
    // Convert to Order objects and cache
    // Implementation depends on your Order model
  }

  Future<List<dynamic>> getCachedOrders() async {
    return await _cacheService.getCachedOrders();
  }

  Future<void> cacheFavorites(List<dynamic> favorites) async {
    // Convert to Favorite objects and cache
    // Implementation depends on your Favorite model
  }

  Future<List<dynamic>> getCachedFavorites() async {
    return await _cacheService.getCachedFavorites();
  }

  // Cache validation
  Future<bool> isCacheValid() async {
    return await _cacheService.isCacheValid();
  }

  Future<void> clearExpiredCache() async {
    await _cacheService.clearExpiredCache();
  }

  // Cache statistics
  Future<Map<String, int>> getCacheStats() async {
    return await _cacheService.getCacheStats();
  }

  // Manual sync operations
  Future<void> syncAllData() async {
    if (!isConnected) return;

    try {
      // Sync recipes
      await _syncRecipes();

      // Sync orders
      await _syncOrders();

      // Sync favorites
      await _syncFavorites();

      // Sync user profile
      await _syncUserProfile();

      // Clear expired cache
      await clearExpiredCache();
    } catch (e) {
      // Handle sync errors
    }
  }

  Future<void> _syncRecipes() async {
    // Implementation for syncing recipes
  }

  Future<void> _syncOrders() async {
    // Implementation for syncing orders
  }

  Future<void> _syncFavorites() async {
    // Implementation for syncing favorites
  }

  Future<void> _syncUserProfile() async {
    // Implementation for syncing user profile
  }

  // Utility methods
  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  void dispose() {
    _connectionController.close();
  }
}
