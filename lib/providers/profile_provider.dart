import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/profile_service.dart';

class ProfileState {
  final Map<String, dynamic>? profile;
  final List<Map<String, dynamic>> addresses;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic>? completion;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.profile,
    this.addresses = const [],
    this.preferences = const {},
    this.completion,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    Map<String, dynamic>? profile,
    List<Map<String, dynamic>>? addresses,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? completion,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      addresses: addresses ?? this.addresses,
      preferences: preferences ?? this.preferences,
      completion: completion ?? this.completion,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileService _profileService = ProfileService();

  ProfileNotifier() : super(const ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profile = await _profileService.getProfile();
      final completion = await _profileService.getProfileCompletion();

      state = state.copyWith(
        profile: profile,
        completion: completion,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedProfile = await _profileService.updateProfile(profileData);
      final completion = await _profileService.getProfileCompletion();

      state = state.copyWith(
        profile: updatedProfile,
        completion: completion,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> uploadProfileImage(String imagePath) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _profileService.uploadProfileImage(imagePath);

      if (state.profile != null) {
        final updatedProfile = Map<String, dynamic>.from(state.profile!);
        updatedProfile['profileImage'] = result['profileImage'];

        state = state.copyWith(
          profile: updatedProfile,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> loadAddresses() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final addresses = await _profileService.getAddresses();

      state = state.copyWith(
        addresses: addresses,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> createAddress(Map<String, dynamic> addressData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final newAddress = await _profileService.createAddress(addressData);
      final updatedAddresses = List<Map<String, dynamic>>.from(state.addresses);
      updatedAddresses.add(newAddress);

      state = state.copyWith(
        addresses: updatedAddresses,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> updateAddress(
      String addressId, Map<String, dynamic> addressData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedAddress =
          await _profileService.updateAddress(addressId, addressData);
      final updatedAddresses = state.addresses.map((address) {
        if (address['id'] == addressId) {
          return updatedAddress;
        }
        return address;
      }).toList();

      state = state.copyWith(
        addresses: updatedAddresses,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> deleteAddress(String addressId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _profileService.deleteAddress(addressId);
      final updatedAddresses = state.addresses
          .where((address) => address['id'] != addressId)
          .toList();

      state = state.copyWith(
        addresses: updatedAddresses,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedAddress = await _profileService.setDefaultAddress(addressId);
      final updatedAddresses = state.addresses.map((address) {
        return {
          ...address,
          'isDefault': address['id'] == addressId,
        };
      }).toList();

      state = state.copyWith(
        addresses: updatedAddresses,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> loadPreferences() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final preferences = await _profileService.getPreferences();

      state = state.copyWith(
        preferences: preferences,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedPreferences =
          await _profileService.updatePreferences(preferences);

      state = state.copyWith(
        preferences: updatedPreferences,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});

