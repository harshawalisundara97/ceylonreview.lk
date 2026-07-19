import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localePrefKey = 'app_locale';
const supportedLanguageCodes = ['en', 'si', 'ta'];

/// The user's chosen app language. `null` means "follow device language".
/// Persisted across launches in [SharedPreferences].
class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    // Restore asynchronously; the first frame renders with the device
    // locale and snaps to the saved one as soon as prefs load.
    SharedPreferences.getInstance().then((prefs) {
      final code = prefs.getString(_localePrefKey);
      if (code != null && supportedLanguageCodes.contains(code)) {
        state = Locale(code);
      }
    });
    return null;
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_localePrefKey);
    } else {
      await prefs.setString(_localePrefKey, locale.languageCode);
    }
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);
