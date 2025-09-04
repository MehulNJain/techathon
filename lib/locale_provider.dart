import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;
  Locale? get locale => _locale;

  /// Set the app's locale and persist the choice.
  Future<void> setLocale(Locale newLocale) async {
    if (!AppLocalizations.supportedLocales.contains(newLocale)) return;

    _locale = newLocale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', newLocale.languageCode);
  }

  /// Load the saved locale from storage on app startup.
  Future<void> fetchLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code');

    if (languageCode != null) {
      _locale = Locale(languageCode);
    } else {
      _locale = const Locale(
        'en',
      ); // Default to English if no preference is saved
    }
  }
}
