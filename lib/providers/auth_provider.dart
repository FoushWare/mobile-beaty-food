import 'package:flutter/foundation.dart';
import '../core/services/auth_service.dart';
import '../models/auth.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthState _state = AuthState.initial;
  AuthData? _authData;
  ProfileData? _profileData;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthState get state => _state;
  AuthData? get authData => _authData;
  ProfileData? get profileData => _profileData;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isUnauthenticated => _state == AuthState.unauthenticated;

  AuthProvider() {
    _initializeAuth();
  }

  /// Initialize authentication state
  Future<void> _initializeAuth() async {
    _setLoading(true);
    
    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        await _loadUserProfile();
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Failed to initialize auth: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Send OTP to phone number
  Future<bool> sendOtp(String phone) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.sendOtp(phone);
      
      if (response.success) {
        // OTP sent successfully
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to send OTP: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Verify OTP
  Future<bool> verifyOtp(String phone, String otp) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.verifyOtp(phone, otp);
      
      if (response.success) {
        // OTP verified, update state
        _authData = response.data;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to verify OTP: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Complete basic profile
  Future<bool> completeBasicProfile({
    required String phone,
    required String name,
    required String email,
    required UserType userType,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.completeBasicProfile(
        phone: phone,
        name: name,
        email: email,
        userType: userType,
      );
      
      if (response.success && response.data != null) {
        _profileData = response.data;
        _authData = _authData?.copyWith(
          profileLevel: response.data!.profileLevel,
          userType: response.data!.userType,
          name: response.data!.name,
          email: response.data!.email,
        );
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to complete basic profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Complete profile with additional details
  Future<bool> completeProfile({
    required String phone,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    List<String>? dietaryRestrictions,
    List<String>? favoriteCuisines,
    String? spicePreference,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.completeProfile(
        phone: phone,
        address: address,
        city: city,
        state: state,
        zipCode: zipCode,
        dietaryRestrictions: dietaryRestrictions,
        favoriteCuisines: favoriteCuisines,
        spicePreference: spicePreference,
      );
      
      if (response.success && response.data != null) {
        _profileData = response.data;
        _authData = _authData?.copyWith(
          profileLevel: response.data!.profileLevel,
        );
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to complete profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Complete chef verification
  Future<bool> completeChefVerification({
    required String phone,
    String? bio,
    List<String>? specialties,
    String? experience,
    List<String>? certifications,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.completeChefVerification(
        phone: phone,
        bio: bio,
        specialties: specialties,
        experience: experience,
        certifications: certifications,
      );
      
      if (response.success && response.data != null) {
        _profileData = response.data;
        _authData = _authData?.copyWith(
          profileLevel: response.data!.profileLevel,
        );
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to complete chef verification: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Login with phone
  Future<bool> login(String phone) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.login(phone);
      
      if (response.success && response.data != null) {
        _authData = response.data;
        await _loadUserProfile();
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to login: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout user
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
      print('Logout API call failed: $e');
    }
    
    // Clear local state
    _authData = null;
    _profileData = null;
    _setState(AuthState.unauthenticated);
    _setLoading(false);
  }

  /// Load user profile
  Future<void> _loadUserProfile() async {
    try {
      final profileResponse = await _authService.getProfileStatus();
      if (profileResponse.success && profileResponse.data != null) {
        _profileData = profileResponse.data;
      }
    } catch (e) {
      print('Failed to load user profile: $e');
    }
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    if (_state == AuthState.authenticated) {
      await _loadUserProfile();
      notifyListeners();
    }
  }

  /// Get current profile completion level
  ProfileCompletionLevel? get currentProfileLevel {
    return _profileData?.profileLevel ?? _authData?.profileLevel;
  }

  /// Get current user type
  UserType? get currentUserType {
    return _profileData?.userType ?? _authData?.userType;
  }

  /// Check if profile is complete
  bool get isProfileComplete {
    final level = currentProfileLevel;
    return level == ProfileCompletionLevel.completeProfile || 
           level == ProfileCompletionLevel.chefVerified;
  }

  /// Check if user is a chef
  bool get isChef {
    final userType = currentUserType;
    return userType == UserType.chef;
  }

  /// Check if user is verified
  bool get isVerified {
    return _authData?.verified == true;
  }

  /// Get fixed OTP for development
  String get fixedOtp => _authService.getFixedOtp();

  // Private helper methods

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = AuthState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = AuthState.unauthenticated;
    }
  }

  // Extension method for AuthData
  AuthData? copyWith({
    String? accessToken,
    String? refreshToken,
    String? userId,
    String? phone,
    ProfileCompletionLevel? profileLevel,
    UserType? userType,
    String? name,
    String? email,
    bool? verified,
  }) {
    if (_authData == null) return null;
    
    return AuthData(
      accessToken: accessToken ?? _authData!.accessToken,
      refreshToken: refreshToken ?? _authData!.refreshToken,
      userId: userId ?? _authData!.userId,
      phone: phone ?? _authData!.phone,
      profileLevel: profileLevel ?? _authData!.profileLevel,
      userType: userType ?? _authData!.userType,
      name: name ?? _authData!.name,
      email: email ?? _authData!.email,
      verified: verified ?? _authData!.verified,
    );
  }
}