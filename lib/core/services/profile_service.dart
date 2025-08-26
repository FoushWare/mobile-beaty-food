import 'package:dio/dio.dart';
import '../utils/api_client.dart';
import '../utils/storage_service.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = StorageService();

  Future<Map<String, dynamic>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await _apiClient.dio.get(
        '/profile',
        options: Options(headers: headers),
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to get profile: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> profileData) async {
    try {
      final headers = await _getHeaders();
      final response = await _apiClient.dio.patch(
        '/profile',
        data: profileData,
        options: Options(headers: headers),
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> uploadProfileImage(String imagePath) async {
    try {
      final token = await _storageService.getToken();
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });

      final response = await _apiClient.dio.post(
        '/profile/image',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to upload profile image: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getProfileCompletion() async {
    try {
      final headers = await _getHeaders();
      final response = await _apiClient.dio.get(
        '/profile/completion',
        options: Options(headers: headers),
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to get profile completion: ${e.toString()}');
    }
  }

  // Address Management
  Future<List<Map<String, dynamic>>> getAddresses() async {
    try {
      final headers = await _getHeaders();
      final response = await _apiClient.dio.get(
        '/profile/addresses',
        options: Options(headers: headers),
      );

      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Failed to get addresses: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> createAddress(
      Map<String, dynamic> addressData) async {
    try {
      final headers = await _getHeaders();
      final response = await _apiClient.dio.post(
        '/profile/addresses',
        data: addressData,
        options: Options(headers: headers),
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to create address: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> updateAddress(
      String addressId, Map<String, dynamic> addressData) async {
    try {
      final headers = await _getHeaders();
      final response = await _apiClient.dio.patch(
        '/profile/addresses/$addressId',
        data: addressData,
        options: Options(headers: headers),
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to update address: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> deleteAddress(String addressId) async {
    try {
      final headers = await _getHeaders();
      final response = await _apiClient.dio.delete(
        '/profile/addresses/$addressId',
        options: Options(headers: headers),
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to delete address: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> setDefaultAddress(String addressId) async {
    try {
      final headers = await _getHeaders();
      final response = await _apiClient.dio.post(
        '/profile/addresses/$addressId/default',
        options: Options(headers: headers),
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to set default address: ${e.toString()}');
    }
  }

  // Preferences Management
  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final headers = await _getHeaders();
      final response = await _apiClient.dio.get(
        '/profile/preferences',
        options: Options(headers: headers),
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to get preferences: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> updatePreferences(
      Map<String, dynamic> preferences) async {
    try {
      final headers = await _getHeaders();
      final response = await _apiClient.dio.patch(
        '/profile/preferences',
        data: preferences,
        options: Options(headers: headers),
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to update preferences: ${e.toString()}');
    }
  }
}

