import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LocalizationService extends GetxService {
  // Storage key for selected language
  static const String _storageKey = 'selected_language';

  // Available languages
  static const List<Locale> supportedLocales = [
    Locale('pt', 'BR'),
    Locale('en', 'US'),
  ];

  // Default language
  static const Locale defaultLocale = Locale('pt', 'BR');

  // Storage instance
  late GetStorage _storage;

  // Current locale
  Rx<Locale> currentLocale = defaultLocale.obs;

  @override
  void onInit() {
    super.onInit();
    _storage = GetStorage();
    _loadSavedLanguage();
  }

  /// Load saved language from storage
  void _loadSavedLanguage() {
    final savedLanguage = _storage.read(_storageKey);
    if (savedLanguage != null) {
      // Parse the saved language string (e.g., "en_US" or "pt_BR")
      final parts = savedLanguage.split('_');
      if (parts.length == 2) {
        currentLocale.value = Locale(parts[0], parts[1]);
      }
    }
  }

  /// Change language and save to storage
  void changeLanguage(Locale locale) {
    currentLocale.value = locale;
    _storage.write(_storageKey, '${locale.languageCode}_${locale.countryCode}');
    Get.updateLocale(locale);
  }

  /// Get current AppLocalizations instance
  AppLocalizations get translations {
    return AppLocalizations.of(Get.context!);
  }

  /// Get language name for display
  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'pt':
        return 'Português';
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  /// Get language flag emoji
  String getLanguageFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '🇺🇸';
      case 'pt':
        return '🇧🇷';
      default:
        return '🌐';
    }
  }

  /// Check if a locale is currently selected
  bool isCurrentLocale(Locale locale) {
    return currentLocale.value.languageCode == locale.languageCode;
  }
}

/// Extension to make accessing translations easier
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Global function to access translations easily
AppLocalizations get l10n => Get.find<LocalizationService>().translations;
