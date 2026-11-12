import 'package:flutter/foundation.dart';
import 'package:pathfinder_albania/l10n/app_localizations.dart';
import 'package:pathfinder_albania/common_libs.dart';

class LocaleLogic {
  final Locale _defaultLocal = Locale('en');

  AppLocalizations? _strings;
  AppLocalizations get strings => _strings!;
  bool get isLoaded => _strings != null;
  bool get isEnglish => strings.localeName == 'en';

  /// Resolves a locale (persisted → English default), loads its
  /// `AppLocalizations`, and returns the resolved language code. The device
  /// language is ignored on purpose: first launch is always English, and
  /// Albanian applies once picked with the home screen's language switcher.
  /// The bootstrap caller dispatches `SettingsLocaleHydrated(code)` into
  /// `SettingsBloc`.
  Future<String> load() async {
    Locale locale = _defaultLocal;
    final stored = settingsBloc.state.currentLocale;
    final localeCode = stored ?? _defaultLocal.languageCode;
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
