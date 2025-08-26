import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/auth_service.dart';
import '../models/auth.dart';

class AuthState {
  final AuthStatus status;
  final AuthData? authData;
  final ProfileData? profileData;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.initial,
    this.authData,
    this.profileData,
    this.errorMessage,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthData? authData,
    ProfileData? profileData,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      authData: authData ?? this.authData,
      profileData: profileData ?? this.profileData,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get hasError => errorMessage != null;

  // Get current user (combining auth data and profile data)
  Map<String, dynamic>? get currentUser {
    if (authData == null) return null;

    return {
      'userId': authData!.userId,
      'phone': authData!.phone,
      'name': profileData?.name ?? authData!.name,
      'fullName': profileData?.name ?? authData!.name,
      'email': profileData?.email ?? authData!.email,
      'userType': profileData?.userType ?? authData!.userType,
      'profileLevel':
          (profileData?.profileLevel ?? authData!.profileLevel)?.name,
      'verified': authData!.verified,
      'profileImage': '', // Add empty profileImage for now
    };
  }

  ProfileCompletionLevel? get currentProfileLevel {
    return profileData?.profileLevel ?? authData?.profileLevel;
  }

  UserType? get currentUserType {
    return profileData?.userType ?? authData?.userType;
  }

  bool get isProfileComplete {
    final level = currentProfileLevel;
    return level == ProfileCompletionLevel.completeProfile ||
        level == ProfileCompletionLevel.chefVerified;
  }

  bool get isChef {
    final userType = currentUserType;
    return userType == UserType.chef;
  }

  bool get isVerified {
    return authData?.verified == true;
  }
}

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();

  AuthNotifier() : super(const AuthState()) {
    _initializeAuth();
  }

  /// Initialize authentication state
  Future<void> _initializeAuth() async {
    state = state.copyWith(isLoading: true);

    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        await _loadUserProfile();
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to initialize auth: $e',
        isLoading: false,
      );
    }
  }

  /// Send OTP to phone number
  Future<bool> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.sendOtp(phone);

      if (response.success) {
        // OTP sent successfully
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: response.message,
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to send OTP: $e',
        isLoading: false,
      );
      return false;
    }
  }

  /// Verify OTP
  Future<bool> verifyOtp(String phone, String otp) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.verifyOtp(phone, otp);

      if (response.success) {
        // OTP verified, update state
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authData: response.data,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: response.message,
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to verify OTP: $e',
        isLoading: false,
      );
      return false;
    }
  }

  /// Complete basic profile
  Future<bool> completeBasicProfile({
    required String phone,
    required String name,
    required String email,
    required UserType userType,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.completeBasicProfile(
        phone: phone,
        name: name,
        email: email,
        userType: userType,
      );

      if (response.success && response.data != null) {
        final updatedAuthData = state.authData?.copyWith(
          profileLevel: response.data!.profileLevel,
          userType: response.data!.userType,
          name: response.data!.name,
          email: response.data!.email,
        );

        state = state.copyWith(
          status: AuthStatus.authenticated,
          profileData: response.data,
          authData: updatedAuthData,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: response.message,
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to complete basic profile: $e',
        isLoading: false,
      );
      return false;
    }
  }

  /// Complete profile with additional details
  Future<bool> completeProfile({
    required String phone,
    String? address,
    String? city,
    String? stateParam,
    String? zipCode,
    List<String>? dietaryRestrictions,
    List<String>? favoriteCuisines,
    String? spicePreference,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.completeProfile(
        phone: phone,
        address: address,
        city: city,
        state: stateParam,
        zipCode: zipCode,
        dietaryRestrictions: dietaryRestrictions,
        favoriteCuisines: favoriteCuisines,
        spicePreference: spicePreference,
      );

      if (response.success && response.data != null) {
        final updatedAuthData = state.authData?.copyWith(
          profileLevel: response.data!.profileLevel,
        );

        state = state.copyWith(
          status: AuthStatus.authenticated,
          profileData: response.data,
          authData: updatedAuthData,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: response.message,
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to complete profile: $e',
        isLoading: false,
      );
      return false;
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
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.completeChefVerification(
        phone: phone,
        bio: bio,
        specialties: specialties,
        experience: experience,
        certifications: certifications,
      );

      if (response.success && response.data != null) {
        final updatedAuthData = state.authData?.copyWith(
          profileLevel: response.data!.profileLevel,
        );

        state = state.copyWith(
          status: AuthStatus.authenticated,
          profileData: response.data,
          authData: updatedAuthData,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: response.message,
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to complete chef verification: $e',
        isLoading: false,
      );
      return false;
    }
  }

  /// Register new user (same as login for OTP-based auth)
  Future<bool> register(String phone) async {
    return await login(phone);
  }

  /// Login with phone
  Future<bool> login(String phone) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.login(phone);

      if (response.success && response.data != null) {
        await _loadUserProfile();
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authData: response.data,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: response.message,
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to login: $e',
        isLoading: false,
      );
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
      print('Logout API call failed: $e');
    }

    // Clear local state
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      authData: null,
      profileData: null,
      isLoading: false,
    );
  }

  /// Load user profile
  Future<void> _loadUserProfile() async {
    try {
      final profileResponse = await _authService.getProfileStatus();
      if (profileResponse.success && profileResponse.data != null) {
        state = state.copyWith(profileData: profileResponse.data);
      }
    } catch (e) {
      print('Failed to load user profile: $e');
    }
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    if (state.isAuthenticated) {
      await _loadUserProfile();
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Get fixed OTP for development
  String get fixedOtp => _authService.getFixedOtp();
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
