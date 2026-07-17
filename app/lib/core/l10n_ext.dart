import 'package:flutter/widgets.dart';

import '../l10n/generated/app_localizations.dart';

export '../l10n/generated/app_localizations.dart' show AppLocalizations;

/// Shorthand for the generated localizations: `context.l10n.someKey`.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
