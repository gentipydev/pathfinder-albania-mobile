import 'package:flutter/foundation.dart';
import 'package:travel_buddy/l10n/app_localizations.dart';
import 'package:intl/intl_standalone.dart';
import 'package:travel_buddy/common_libs.dart';

class LocaleLogic {
  final Locale _defaultLocal = Locale('en');

  AppLocalizations? _strings;
  AppLocalizations get strings => _strings!;
  bool get isLoaded => _strings != null;
  bool get isEnglish => strings.localeName == 'en';

  /// Resolves a locale (persisted → system fallback → default), loads its
  /// `AppLocalizations`, and returns the resolved language code. The bootstrap
  /// caller dispatches `SettingsLocaleHydrated(code)` into `SettingsBloc`.
  Future<String> load() async {
    Locale locale = _defaultLocal;
    final stored = settingsBloc.state.currentLocale;
    final localeCode = stored ?? await findSystemLocale();
    locale = Locale(localeCode.split('_')[0]);
    if (kDebugMode) {
      // locale = Locale('sq'); // uncomment to test albanian
    }
    if (AppLocalizations.supportedLocales.contains(locale) == false) {
      locale = _defaultLocal;
    }

    _strings = await AppLocalizations.delegate.load(locale);
    return locale.languageCode;
  }

  Future<void> loadIfChanged(Locale locale) async {
    bool didChange = _strings?.localeName != locale.languageCode;
    if (didChange && AppLocalizations.supportedLocales.contains(locale)) {
      _strings = await AppLocalizations.delegate.load(locale);
    }
  }
}
