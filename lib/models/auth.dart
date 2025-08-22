// Auth Models matching backend DTOs
enum ProfileCompletionLevel {
  mobileVerified,
  basicProfile,
  completeProfile,
  chefVerified,
}

enum UserType {
  customer,
  chef,
}

// Request DTOs
class SendOtpRequest {
  final String phone;

  SendOtpRequest({required this.phone});

  Map<String, dynamic> toJson() => {'phone': phone};
}

class VerifyOtpRequest {
  final String phone;
  final String otp;

  VerifyOtpRequest({required this.phone, required this.otp});

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'otp': otp,
      };
}

class CompleteBasicProfileRequest {
  final String phone;
  final String name;
  final String email;
  final UserType userType;

  CompleteBasicProfileRequest({
    required this.phone,
    required this.name,
    required this.email,
    required this.userType,
  });

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'name': name,
        'email': email,
        'userType': userType.name,
      };
}

class CompleteProfileRequest {
  final String phone;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final List<String>? dietaryRestrictions;
  final List<String>? favoriteCuisines;
  final String? spicePreference;

  CompleteProfileRequest({
    required this.phone,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.dietaryRestrictions,
    this.favoriteCuisines,
    this.spicePreference,
  });

  Map<String, dynamic> toJson() => {
        'phone': phone,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (zipCode != null) 'zipCode': zipCode,
        if (dietaryRestrictions != null) 'dietaryRestrictions': dietaryRestrictions,
        if (favoriteCuisines != null) 'favoriteCuisines': favoriteCuisines,
        if (spicePreference != null) 'spicePreference': spicePreference,
      };
}

class ChefVerificationRequest {
  final String phone;
  final String? bio;
  final List<String>? specialties;
  final String? experience;
  final List<String>? certifications;

  ChefVerificationRequest({
    required this.phone,
    this.bio,
    this.specialties,
    this.experience,
    this.certifications,
  });

  Map<String, dynamic> toJson() => {
        'phone': phone,
        if (bio != null) 'bio': bio,
        if (specialties != null) 'specialties': specialties,
        if (experience != null) 'experience': experience,
        if (certifications != null) 'certifications': certifications,
      };
}

class LoginRequest {
  final String phone;

  LoginRequest({required this.phone});

  Map<String, dynamic> toJson() => {'phone': phone};
}

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}

// Response DTOs
class AuthResponse {
  final bool success;
  final String message;
  final AuthData? data;

  AuthResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
    );
  }
}

class AuthData {
  final String? accessToken;
  final String? refreshToken;
  final String? userId;
  final String? phone;
  final ProfileCompletionLevel? profileLevel;
  final UserType? userType;
  final String? name;
  final String? email;
  final bool? verified;

  AuthData({
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.phone,
    this.profileLevel,
    this.userType,
    this.name,
    this.email,
    this.verified,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      userId: json['userId'],
      phone: json['phone'],
      profileLevel: json['profileLevel'] != null
          ? ProfileCompletionLevel.values.firstWhere(
              (level) => level.name == json['profileLevel'],
              orElse: () => ProfileCompletionLevel.mobileVerified,
            )
          : null,
      userType: json['userType'] != null
          ? UserType.values.firstWhere(
              (type) => type.name == json['userType'],
              orElse: () => UserType.customer,
            )
          : null,
      name: json['name'],
      email: json['email'],
      verified: json['verified'],
    );
  }
}

class ProfileCompletionResponse {
  final bool success;
  final String message;
  final ProfileData? data;

  ProfileCompletionResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ProfileCompletionResponse.fromJson(Map<String, dynamic> json) {
    return ProfileCompletionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ProfileData.fromJson(json['data']) : null,
    );
  }
}

class ProfileData {
  final String? userId;
  final ProfileCompletionLevel? profileLevel;
  final UserType? userType;
  final String? name;
  final String? email;
  final String? phone;

  ProfileData({
    this.userId,
    this.profileLevel,
    this.userType,
    this.name,
    this.email,
    this.phone,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      userId: json['userId'],
      profileLevel: json['profileLevel'] != null
          ? ProfileCompletionLevel.values.firstWhere(
              (level) => level.name == json['profileLevel'],
              orElse: () => ProfileCompletionLevel.mobileVerified,
            )
          : null,
      userType: json['userType'] != null
          ? UserType.values.firstWhere(
              (type) => type.name == json['userType'],
              orElse: () => UserType.customer,
            )
          : null,
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}

// Error Response
class ErrorResponse {
  final bool success;
  final String message;
  final String? error;
  final int? statusCode;

  ErrorResponse({
    required this.success,
    required this.message,
    this.error,
    this.statusCode,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      statusCode: json['statusCode'],
    );
  }
}


