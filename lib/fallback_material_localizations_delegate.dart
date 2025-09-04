import 'package:flutter/material.dart';

/// A custom delegate to handle unsupported MaterialLocalizations.
///
/// When a locale like Santali ('sat') is selected, Flutter's default
/// Material components (like DatePicker, Search, etc.) would crash because
/// they don't have 'sat' translations.
///
/// This delegate intercepts the request for MaterialLocalizations for 'sat'
/// and provides the localizations for a specified fallback locale (e.g., 'hi' or 'en')
/// instead, preventing a crash and ensuring a smooth user experience.
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  final Locale fallbackLocale;

  const FallbackMaterialLocalizationsDelegate({
    this.fallbackLocale = const Locale('en'), // Default fallback to English
  });

  @override
  bool isSupported(Locale locale) {
    // We support all locales and handle the fallback logic in the load method.
    return true;
  }

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    // Check if the current language is Santali
    if (locale.languageCode == 'sat') {
      // If it is, load the Material localizations for the fallback locale (e.g., Hindi)
      return await DefaultMaterialLocalizations.load(fallbackLocale);
    }
    // Otherwise, load the default Material localizations for the given locale
    return await DefaultMaterialLocalizations.load(locale);
  }

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) =>
      fallbackLocale != old.fallbackLocale;
}
