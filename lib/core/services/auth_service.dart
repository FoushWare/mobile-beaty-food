import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/auth.dart';

class AuthService {
  static const String _baseUrl = 'http://localhost:3000/api';
  static const String _authBaseUrl = '$_baseUrl/auth';

  late final Dio _dio;

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _phoneKey = 'phone';
  static const String _profileLevelKey = 'profile_level';
  static const String _userTypeKey = 'user_type';

  AuthService() {
    _dio = Dio(BaseOptions(
      baseUrl: _authBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for token management
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = await _getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired, try to refresh
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the original request
              final token = await _getAccessToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              final response = await _dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  // 🚨 DEVELOPMENT: Fixed OTP for testing
  static const String _fixedOtp = '1234';

  /// Send OTP to phone number
  Future<AuthResponse> sendOtp(String phone) async {
    try {
      final response = await _dio.post('/send-otp', data: {
        'phone': phone,
      });

      // 🚨 DEVELOPMENT: Log fixed OTP for testing
      print('🚨 DEVELOPMENT MODE: Fixed OTP for $phone: $_fixedOtp');
      print('📱 In production, this would be sent via SMS service');

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Verify OTP
  Future<AuthResponse> verifyOtp(String phone, String otp) async {
    try {
      final response = await _dio.post('/verify-otp', data: {
        'phone': phone,
        'otp': otp,
      });

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Complete basic profile
  Future<ProfileCompletionResponse> completeBasicProfile({
    required String phone,
    required String name,
    required String email,
    required UserType userType,
  }) async {
    try {
      final response = await _dio.post('/complete-basic-profile', data: {
        'phone': phone,
        'name': name,
        'email': email,
        'userType': userType.name,
      });

      return ProfileCompletionResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleProfileError(e);
    } catch (e) {
      return ProfileCompletionResponse(
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Complete profile with additional details
  Future<ProfileCompletionResponse> completeProfile({
    required String phone,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    List<String>? dietaryRestrictions,
    List<String>? favoriteCuisines,
    String? spicePreference,
  }) async {
    try {
      final response = await _dio.post('/complete-profile', data: {
        'phone': phone,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (zipCode != null) 'zipCode': zipCode,
        if (dietaryRestrictions != null)
          'dietaryRestrictions': dietaryRestrictions,
        if (favoriteCuisines != null) 'favoriteCuisines': favoriteCuisines,
        if (spicePreference != null) 'spicePreference': spicePreference,
      });

      return ProfileCompletionResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleProfileError(e);
    } catch (e) {
      return ProfileCompletionResponse(
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Complete chef verification
  Future<ProfileCompletionResponse> completeChefVerification({
    required String phone,
    String? bio,
    List<String>? specialties,
    String? experience,
    List<String>? certifications,
  }) async {
    try {
      final response = await _dio.post('/complete-chef-verification', data: {
        'phone': phone,
        if (bio != null) 'bio': bio,
        if (specialties != null) 'specialties': specialties,
        if (experience != null) 'experience': experience,
        if (certifications != null) 'certifications': certifications,
      });

      return ProfileCompletionResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleProfileError(e);
    } catch (e) {
      return ProfileCompletionResponse(
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Login with phone
  Future<AuthResponse> login(String phone) async {
    try {
      final response = await _dio.post('/login', data: {
        'phone': phone,
      });

      if (response.data['success'] == true && response.data['data'] != null) {
        // Store tokens and user data
        await _storeAuthData(response.data['data']);
      }

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Refresh access token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post('/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response.data['success'] == true && response.data['data'] != null) {
        await _storeAuthData(response.data['data']);
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to refresh token: $e');
      return false;
    }
  }

  /// Logout user
  Future<bool> logout() async {
    try {
      final response = await _dio.post('/logout');

      // Clear stored data regardless of response
      await _clearAuthData();

      return response.data['success'] == true;
    } catch (e) {
      // Clear stored data even if API call fails
      await _clearAuthData();
      return true;
    }
  }

  /// Get user profile
  Future<AuthResponse> getProfile() async {
    try {
      final response = await _dio.get('/profile');
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Get profile completion status
  Future<ProfileCompletionResponse> getProfileStatus() async {
    try {
      final response = await _dio.get('/profile-status');
      return ProfileCompletionResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleProfileError(e);
    } catch (e) {
      return ProfileCompletionResponse(
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _getAccessToken();
    return token != null;
  }

  /// Get current user ID
  Future<String?> getCurrentUserId() async {
    return await _getUserId();
  }

  /// Get current user phone
  Future<String?> getCurrentUserPhone() async {
    return await _getPhone();
  }

  /// Get current profile level
  Future<ProfileCompletionLevel?> getCurrentProfileLevel() async {
    final level = await _getProfileLevel();
    if (level == null) return null;

    return ProfileCompletionLevel.values.firstWhere(
      (l) => l.name == level,
      orElse: () => ProfileCompletionLevel.mobileVerified,
    );
  }

  // Private helper methods

  Future<void> _storeAuthData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    if (data['accessToken'] != null) {
      await prefs.setString(_accessTokenKey, data['accessToken']);
    }
    if (data['refreshToken'] != null) {
      await prefs.setString(_refreshTokenKey, data['refreshToken']);
    }
    if (data['userId'] != null) {
      await prefs.setString(_userIdKey, data['userId']);
    }
    if (data['phone'] != null) {
      await prefs.setString(_phoneKey, data['phone']);
    }
    if (data['profileLevel'] != null) {
      await prefs.setString(_profileLevelKey, data['profileLevel']);
    }
    if (data['userType'] != null) {
      await prefs.setString(_userTypeKey, data['userType']);
    }
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_profileLevelKey);
    await prefs.remove(_userTypeKey);
  }

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> getToken() async {
    return _getAccessToken();
  }

  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<String?> _getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  Future<String?> _getProfileLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileLevelKey);
  }

  Future<bool> _refreshToken() async {
    return await refreshToken();
  }

  AuthResponse _handleDioError(DioException e) {
    if (e.response?.data != null) {
      try {
        return AuthResponse.fromJson(e.response!.data);
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

    return AuthResponse(
      success: false,
      message: message,
    );
  }

  ProfileCompletionResponse _handleProfileError(DioException e) {
    if (e.response?.data != null) {
      try {
        return ProfileCompletionResponse.fromJson(e.response!.data);
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

    return ProfileCompletionResponse(
      success: false,
      message: message,
    );
  }

  /// Get fixed OTP for development
  String getFixedOtp() => _fixedOtp;
}
