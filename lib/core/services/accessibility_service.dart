import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../utils/storage_service.dart';

class AccessibilityService {
  static final AccessibilityService _instance =
      AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  final StorageService _storageService = StorageService();

  bool _isScreenReaderEnabled = false;
  bool _isHighContrastEnabled = false;
  bool _isLargeTextEnabled = false;
  double _textScaleFactor = 1.0;

  bool get isScreenReaderEnabled => _isScreenReaderEnabled;
  bool get isHighContrastEnabled => _isHighContrastEnabled;
  bool get isLargeTextEnabled => _isLargeTextEnabled;
  double get textScaleFactor => _textScaleFactor;

  Future<void> initialize() async {
    await _loadAccessibilitySettings();
  }

  Future<void> _loadAccessibilitySettings() async {
    try {
      final settings =
          await _storageService.getString('accessibility_settings');
      if (settings != null) {
        final Map<String, dynamic> decoded = jsonDecode(settings);
        _isScreenReaderEnabled = decoded['screen_reader'] ?? false;
        _isHighContrastEnabled = decoded['high_contrast'] ?? false;
        _isLargeTextEnabled = decoded['large_text'] ?? false;
        _textScaleFactor = decoded['text_scale'] ?? 1.0;
      }
    } catch (e) {
      debugPrint('Failed to load accessibility settings: $e');
    }
  }

  Future<void> _saveAccessibilitySettings() async {
    try {
      final settings = {
        'screen_reader': _isScreenReaderEnabled,
        'high_contrast': _isHighContrastEnabled,
        'large_text': _isLargeTextEnabled,
        'text_scale': _textScaleFactor,
      };
      await _storageService.setString(
          'accessibility_settings', jsonEncode(settings));
    } catch (e) {
      debugPrint('Failed to save accessibility settings: $e');
    }
  }

  Future<void> updateScreenReader(bool enabled) async {
    _isScreenReaderEnabled = enabled;
    await _saveAccessibilitySettings();
  }

  Future<void> updateHighContrast(bool enabled) async {
    _isHighContrastEnabled = enabled;
    await _saveAccessibilitySettings();
  }

  Future<void> updateLargeText(bool enabled) async {
    _isLargeTextEnabled = enabled;
    _textScaleFactor = enabled ? 1.3 : 1.0;
    await _saveAccessibilitySettings();
  }

  void announceToScreenReader(String message) {
    if (_isScreenReaderEnabled) {
      SemanticsService.announce(message, TextDirection.ltr);
    }
  }

  Color getAccessibleTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }

  TextStyle getAccessibleTextStyle(TextStyle baseStyle) {
    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 14.0) * _textScaleFactor,
    );
  }
}

final accessibilityService = AccessibilityService();
