import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/cache_service.dart';

enum ConnectionStatus {
  connected,
  disconnected,
  unknown,
}

class OfflineState {
  final ConnectionStatus connectionStatus;
  final bool isCacheValid;
  final Map<String, int> cacheStats;
  final List<Map<String, dynamic>> offlineQueue;
  final bool isSyncing;
  final int? lastSyncHoursAgo;

  const OfflineState({
    this.connectionStatus = ConnectionStatus.unknown,
    this.isCacheValid = false,
    this.cacheStats = const {},
    this.offlineQueue = const [],
    this.isSyncing = false,
    this.lastSyncHoursAgo,
  });

  OfflineState copyWith({
    ConnectionStatus? connectionStatus,
    bool? isCacheValid,
    Map<String, int>? cacheStats,
    List<Map<String, dynamic>>? offlineQueue,
    bool? isSyncing,
    int? lastSyncHoursAgo,
  }) {
    return OfflineState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      isCacheValid: isCacheValid ?? this.isCacheValid,
      cacheStats: cacheStats ?? this.cacheStats,
      offlineQueue: offlineQueue ?? this.offlineQueue,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncHoursAgo: lastSyncHoursAgo ?? this.lastSyncHoursAgo,
    );
  }

  bool get isConnected => connectionStatus == ConnectionStatus.connected;
  bool get isOffline => connectionStatus == ConnectionStatus.disconnected;
  int get pendingOperationsCount => offlineQueue.length;
}

class OfflineNotifier extends StateNotifier<OfflineState> {
  final CacheService _cacheService = CacheService();

  OfflineNotifier() : super(const OfflineState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _cacheService.initialize();
    await _loadCacheStats();
    await _loadOfflineQueue();
  }

  Future<void> _loadCacheStats() async {
    final stats = await _cacheService.getCacheStats();
    final isValid = await _cacheService.isCacheValid();

    state = state.copyWith(
      cacheStats: stats,
      isCacheValid: isValid,
      lastSyncHoursAgo: stats['last_sync_hours_ago'],
    );
  }

  Future<void> _loadOfflineQueue() async {
    final queue = await _cacheService.getOfflineQueue();
    state = state.copyWith(offlineQueue: queue);
  }

  Future<void> updateConnectionStatus(ConnectionStatus status) async {
    state = state.copyWith(connectionStatus: status);

    // If connection is restored, sync data
    if (status == ConnectionStatus.connected) {
      await _syncData();
    }
  }

  Future<void> _syncData() async {
    if (state.isSyncing) return;

    state = state.copyWith(isSyncing: true);

    try {
      // Sync offline queue
      await _syncOfflineQueue();

      // Refresh cache stats
      await _loadCacheStats();

      // Load updated offline queue
      await _loadOfflineQueue();
    } catch (e) {
      // Handle sync errors
    } finally {
      state = state.copyWith(isSyncing: false);
    }
  }

  Future<void> _syncOfflineQueue() async {
    // This would integrate with your API services
    // For now, we'll just clear the queue
    await _cacheService.clearOfflineQueue();
  }

  Future<void> addToOfflineQueue(
      String operation, Map<String, dynamic> data) async {
    await _cacheService.addToOfflineQueue(operation, data);
    await _loadOfflineQueue();
  }

  Future<void> clearOfflineQueue() async {
    await _cacheService.clearOfflineQueue();
    await _loadOfflineQueue();
  }

  Future<void> clearCache() async {
    await _cacheService.clearCache();
    await _loadCacheStats();
  }

  Future<void> refreshCacheStats() async {
    await _loadCacheStats();
  }

  Future<void> manualSync() async {
    await _syncData();
  }

  // Cache operations
  Future<void> cacheRecipes(List<dynamic> recipes) async {
    // Implementation depends on your Recipe model
    await _loadCacheStats();
  }

  Future<List<dynamic>> getCachedRecipes() async {
    return await _cacheService.getCachedRecipes();
  }

  Future<void> cacheOrders(List<dynamic> orders) async {
    // Implementation depends on your Order model
    await _loadCacheStats();
  }

  Future<List<dynamic>> getCachedOrders() async {
    return await _cacheService.getCachedOrders();
  }

  Future<void> cacheFavorites(List<dynamic> favorites) async {
    // Implementation depends on your Favorite model
    await _loadCacheStats();
  }

  Future<List<dynamic>> getCachedFavorites() async {
    return await _cacheService.getCachedFavorites();
  }
}

// Provider
final offlineProvider =
    StateNotifierProvider<OfflineNotifier, OfflineState>((ref) {
  return OfflineNotifier();
});

// Convenience providers
final connectionStatusProvider = Provider<ConnectionStatus>((ref) {
  return ref.watch(offlineProvider).connectionStatus;
});

final isConnectedProvider = Provider<bool>((ref) {
  return ref.watch(offlineProvider).isConnected;
});

final isOfflineProvider = Provider<bool>((ref) {
  return ref.watch(offlineProvider).isOffline;
});

final cacheStatsProvider = Provider<Map<String, int>>((ref) {
  return ref.watch(offlineProvider).cacheStats;
});

final offlineQueueProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(offlineProvider).offlineQueue;
});

final pendingOperationsCountProvider = Provider<int>((ref) {
  return ref.watch(offlineProvider).pendingOperationsCount;
});
