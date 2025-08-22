import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baty_bites/models/user.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Token Management
  Future<void> saveToken(String token) async {
    await _preferences!.setString('user_token', token);
  }

  String? getToken() {
    return _preferences!.getString('user_token');
  }

  Future<void> removeToken() async {
    await _preferences!.remove('user_token');
  }

  bool get hasToken => getToken() != null;

  // User Data Management
  Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    await _preferences!.setString('user_data', userJson);
  }

  User? getUser() {
    final userJson = _preferences!.getString('user_data');
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> removeUser() async {
    await _preferences!.remove('user_data');
  }

  // User Type Selection
  Future<void> saveSelectedUserType(UserType userType) async {
    await _preferences!.setString('selected_user_type', userType.name);
  }

  UserType? getSelectedUserType() {
    final userTypeString = _preferences!.getString('selected_user_type');
    if (userTypeString != null) {
      return UserType.values.firstWhere(
        (type) => type.name == userTypeString,
        orElse: () => UserType.customer,
      );
    }
    return null;
  }

  Future<void> removeSelectedUserType() async {
    await _preferences!.remove('selected_user_type');
  }

  // Onboarding
  Future<void> setOnboardingCompleted() async {
    await _preferences!.setBool('onboarding_completed', true);
  }

  bool get isOnboardingCompleted {
    return _preferences!.getBool('onboarding_completed') ?? false;
  }

  // Favorites
  Future<void> addToFavorites(String recipeId) async {
    final favorites = getFavorites();
    if (!favorites.contains(recipeId)) {
      favorites.add(recipeId);
      await _preferences!.setStringList('favorites', favorites);
    }
  }

  Future<void> removeFromFavorites(String recipeId) async {
    final favorites = getFavorites();
    favorites.remove(recipeId);
    await _preferences!.setStringList('favorites', favorites);
  }

  List<String> getFavorites() {
    return _preferences!.getStringList('favorites') ?? [];
  }

  bool isFavorite(String recipeId) {
    return getFavorites().contains(recipeId);
  }

  // Search History
  Future<void> addToSearchHistory(String query) async {
    final history = getSearchHistory();
    history.remove(query); // Remove if exists
    history.insert(0, query); // Add to beginning
    
    // Keep only last 10 searches
    if (history.length > 10) {
      history.removeRange(10, history.length);
    }
    
    await _preferences!.setStringList('search_history', history);
  }

  List<String> getSearchHistory() {
    return _preferences!.getStringList('search_history') ?? [];
  }

  Future<void> clearSearchHistory() async {
    await _preferences!.remove('search_history');
  }

  // Settings
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _preferences!.setBool('notifications_enabled', enabled);
  }

  bool get notificationsEnabled {
    return _preferences!.getBool('notifications_enabled') ?? true;
  }

  Future<void> setDarkModeEnabled(bool enabled) async {
    await _preferences!.setBool('dark_mode_enabled', enabled);
  }

  bool get darkModeEnabled {
    return _preferences!.getBool('dark_mode_enabled') ?? false;
  }

  Future<void> setLanguage(String languageCode) async {
    await _preferences!.setString('language', languageCode);
  }

  String get language {
    return _preferences!.getString('language') ?? 'ar';
  }

  // Clear All Data
  Future<void> clearAll() async {
    await _preferences!.clear();
  }
}