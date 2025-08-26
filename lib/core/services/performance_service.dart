import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../utils/storage_service.dart';

class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  final StorageService _storageService = StorageService();
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, Timer> _cacheTimers = {};

  // Cache configuration
  static const int _maxCacheSize = 100; // Maximum number of cached items
  static const Duration _cacheExpiry = Duration(hours: 24);
  static const Duration _cleanupInterval = Duration(minutes: 30);

  // Performance metrics
  final Map<String, int> _apiCallTimes = {};
  final Map<String, int> _imageLoadTimes = {};
  final List<double> _memoryUsage = [];
  final List<double> _frameRates = [];

  // Cache manager for images
  static final CacheManager _imageCacheManager = CacheManager(
    Config(
      'beaty_food_images',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 200,
      repo: JsonCacheInfoRepository(databaseName: 'beaty_food_images_cache'),
      fileService: HttpFileService(),
    ),
  );

  Future<void> initialize() async {
    await _loadCacheFromStorage();
    _startCacheCleanupTimer();
    _startPerformanceMonitoring();
  }

  // Image caching and optimization
  Future<File?> getCachedImage(String url) async {
    try {
      final fileInfo = await _imageCacheManager.getFileFromCache(url);
      if (fileInfo != null) {
        _recordImageLoadTime(url, 0); // Cached, instant load
        return fileInfo.file;
      }

      final startTime = DateTime.now().millisecondsSinceEpoch;
      final file = await _imageCacheManager.getSingleFile(url);
      final loadTime = DateTime.now().millisecondsSinceEpoch - startTime;
      _recordImageLoadTime(url, loadTime);

      return file;
    } catch (e) {
      debugPrint('Failed to load cached image: $e');
      return null;
    }
  }

  Future<void> preloadImages(List<String> urls) async {
    for (final url in urls) {
      try {
        await _imageCacheManager.getSingleFile(url);
      } catch (e) {
        debugPrint('Failed to preload image: $e');
      }
    }
  }

  Future<void> clearImageCache() async {
    await _imageCacheManager.emptyCache();
  }

  // Data caching
  Future<T?> getCachedData<T>(String key) async {
    if (_cache.containsKey(key)) {
      final timestamp = _cacheTimestamps[key];
      if (timestamp != null &&
          DateTime.now().difference(timestamp) < _cacheExpiry) {
        return _cache[key] as T;
      } else {
        _removeFromCache(key);
      }
    }
    return null;
  }

  Future<void> setCachedData<T>(String key, T data) async {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();

    // Set expiry timer
    _cacheTimers[key]?.cancel();
    _cacheTimers[key] = Timer(_cacheExpiry, () => _removeFromCache(key));

    // Check cache size and cleanup if necessary
    if (_cache.length > _maxCacheSize) {
      _cleanupOldestCache();
    }

    await _saveCacheToStorage();
  }

  void _removeFromCache(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
    _cacheTimers[key]?.cancel();
    _cacheTimers.remove(key);
  }

  void _cleanupOldestCache() {
    if (_cacheTimestamps.isEmpty) return;

    final sortedEntries = _cacheTimestamps.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final entriesToRemove =
        sortedEntries.take(_cache.length - _maxCacheSize + 10);
    for (final entry in entriesToRemove) {
      _removeFromCache(entry.key);
    }
  }

  Future<void> _loadCacheFromStorage() async {
    try {
      final cacheData = await _storageService.getString('performance_cache');
      if (cacheData != null) {
        final Map<String, dynamic> decoded = Map<String, dynamic>.from(
          jsonDecode(cacheData),
        );

        for (final entry in decoded.entries) {
          final timestamp = DateTime.parse(entry.value['timestamp']);
          if (DateTime.now().difference(timestamp) < _cacheExpiry) {
            _cache[entry.key] = entry.value['data'];
            _cacheTimestamps[entry.key] = timestamp;
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to load cache from storage: $e');
    }
  }

  Future<void> _saveCacheToStorage() async {
    try {
      final cacheData = <String, dynamic>{};
      for (final entry in _cache.entries) {
        final timestamp = _cacheTimestamps[entry.key];
        if (timestamp != null) {
          cacheData[entry.key] = {
            'data': entry.value,
            'timestamp': timestamp.toIso8601String(),
          };
        }
      }

      await _storageService.setString(
          'performance_cache', jsonEncode(cacheData));
    } catch (e) {
      debugPrint('Failed to save cache to storage: $e');
    }
  }

  void _startCacheCleanupTimer() {
    Timer.periodic(_cleanupInterval, (timer) {
      _cleanupExpiredCache();
    });
  }

  void _cleanupExpiredCache() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) >= _cacheExpiry) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _removeFromCache(key);
    }
  }

  // Performance monitoring
  void _startPerformanceMonitoring() {
    // Monitor memory usage
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _recordMemoryUsage();
    });
  }

  void _recordMemoryUsage() {
    // In a real app, you would use platform-specific APIs to get memory usage
    // For now, we'll simulate memory monitoring
    final memoryUsage = _getSimulatedMemoryUsage();
    _memoryUsage.add(memoryUsage);

    // Keep only last 100 measurements
    if (_memoryUsage.length > 100) {
      _memoryUsage.removeAt(0);
    }
  }

  double _getSimulatedMemoryUsage() {
    // Simulate memory usage based on cache size and other factors
    final baseUsage = 50.0; // Base memory usage in MB
    final cacheUsage = _cache.length * 0.1; // 0.1 MB per cached item
    final imageUsage = _imageLoadTimes.length * 0.5; // 0.5 MB per cached image

    return baseUsage + cacheUsage + imageUsage;
  }

  void _recordImageLoadTime(String url, int loadTimeMs) {
    _imageLoadTimes[url] = loadTimeMs;

    // Keep only last 1000 measurements
    if (_imageLoadTimes.length > 1000) {
      final keysToRemove = _imageLoadTimes.keys.take(100);
      for (final key in keysToRemove) {
        _imageLoadTimes.remove(key);
      }
    }
  }

  void recordApiCallTime(String endpoint, int callTimeMs) {
    _apiCallTimes[endpoint] = callTimeMs;

    // Keep only last 1000 measurements
    if (_apiCallTimes.length > 1000) {
      final keysToRemove = _apiCallTimes.keys.take(100);
      for (final key in keysToRemove) {
        _apiCallTimes.remove(key);
      }
    }
  }

  void recordFrameRate(double fps) {
    _frameRates.add(fps);

    // Keep only last 1000 measurements
    if (_frameRates.length > 1000) {
      _frameRates.removeAt(0);
    }
  }

  // Performance analytics
  Map<String, dynamic> getPerformanceMetrics() {
    final avgImageLoadTime = _imageLoadTimes.values.isEmpty
        ? 0
        : _imageLoadTimes.values.reduce((a, b) => a + b) /
            _imageLoadTimes.length;

    final avgApiCallTime = _apiCallTimes.values.isEmpty
        ? 0
        : _apiCallTimes.values.reduce((a, b) => a + b) / _apiCallTimes.length;

    final avgFrameRate = _frameRates.isEmpty
        ? 0
        : _frameRates.reduce((a, b) => a + b) / _frameRates.length;

    final currentMemoryUsage = _memoryUsage.isNotEmpty ? _memoryUsage.last : 0;

    final avgMemoryUsage = _memoryUsage.isEmpty
        ? 0
        : _memoryUsage.reduce((a, b) => a + b) / _memoryUsage.length;

    return {
      'cache_size': _cache.length,
      'image_cache_size': _imageLoadTimes.length,
      'avg_image_load_time_ms': avgImageLoadTime.round(),
      'avg_api_call_time_ms': avgApiCallTime.round(),
      'avg_frame_rate': avgFrameRate.toStringAsFixed(1),
      'current_memory_usage_mb': currentMemoryUsage.toStringAsFixed(1),
      'avg_memory_usage_mb': avgMemoryUsage.toStringAsFixed(1),
      'total_api_calls': _apiCallTimes.length,
      'total_images_loaded': _imageLoadTimes.length,
    };
  }

  // Memory management
  Future<void> optimizeMemory() async {
    // Clear old cache entries
    _cleanupExpiredCache();

    // Clear old performance data
    if (_apiCallTimes.length > 500) {
      final keysToRemove = _apiCallTimes.keys.take(200);
      for (final key in keysToRemove) {
        _apiCallTimes.remove(key);
      }
    }

    if (_imageLoadTimes.length > 500) {
      final keysToRemove = _imageLoadTimes.keys.take(200);
      for (final key in keysToRemove) {
        _imageLoadTimes.remove(key);
      }
    }

    if (_frameRates.length > 500) {
      _frameRates.removeRange(0, 200);
    }

    if (_memoryUsage.length > 50) {
      _memoryUsage.removeRange(0, 25);
    }
  }

  // Network optimization
  Future<void> optimizeNetworkRequests() async {
    // Implement request batching, caching, and optimization
    // This would integrate with your API client
  }

  // App startup optimization
  Future<void> optimizeStartup() async {
    // Preload essential data
    await _preloadEssentialData();

    // Initialize critical services
    await _initializeCriticalServices();
  }

  Future<void> _preloadEssentialData() async {
    // Preload user preferences, essential cache, etc.
    try {
      await _storageService.getString('user_preferences');
      await _storageService.getString('auth_token');
    } catch (e) {
      debugPrint('Failed to preload essential data: $e');
    }
  }

  Future<void> _initializeCriticalServices() async {
    // Initialize services that are needed immediately
    try {
      // Initialize critical services here
    } catch (e) {
      debugPrint('Failed to initialize critical services: $e');
    }
  }

  // Cleanup
  void dispose() {
    for (final timer in _cacheTimers.values) {
      timer.cancel();
    }
    _cacheTimers.clear();
    _cache.clear();
    _cacheTimestamps.clear();
  }
}

// Global performance service instance
final performanceService = PerformanceService();
