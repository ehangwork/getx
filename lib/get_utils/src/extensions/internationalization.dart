import 'dart:ui';

import '../../../get_core/get_core.dart';

class _IntlHost {
  Locale? locale;

  Locale? fallbackLocale;
}

extension LocalesIntl on GetInterface {
  static final _intlHost = _IntlHost();

  Locale? get locale => _intlHost.locale;

  Locale? get fallbackLocale => _intlHost.fallbackLocale;

  set locale(Locale? newLocale) => _intlHost.locale = newLocale;

  set fallbackLocale(Locale? newLocale) => _intlHost.fallbackLocale = newLocale;
}