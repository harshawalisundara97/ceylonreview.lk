# Three-Language Support (English · Sinhala · Tamil) — Design

Date: 2026-07-17
Status: Approved by user

## Problem

Every user-facing string in the app is hardcoded English (~120 strings
across ~17 presentation-layer files). Sri Lankan users who prefer Sinhala
or Tamil have no way to use the app in their language.

## Languages

- English (`en`) — default and fallback
- Sinhala (`si`)
- Tamil (`ta`)

## Approach

Flutter's official gen-l10n workflow — no third-party localization
package:

- Add `flutter_localizations` (SDK) and `intl` to `app/pubspec.yaml`,
  plus `generate: true` under `flutter:`.
- `app/l10n.yaml` configures generation; strings live in ARB files:
  `app/lib/l10n/app_en.arb` (template, with `@` descriptions),
  `app_si.arb`, `app_ta.arb`.
- Flutter generates a type-safe `AppLocalizations` class; widgets use
  `AppLocalizations.of(context)!.someKey`. Missing keys fail the build —
  compile-time safety across all three languages.

Alternatives rejected: `easy_localization` (runtime string keys, no
compile-time checking, extra dependency); hand-rolled string maps
(reinvents plural/format support, unchecked).

## Locale state & persistence

- New `app/lib/application/locale_provider.dart`: a Riverpod
  `Notifier<Locale?>`; `null` means "follow device language".
- Persisted via `shared_preferences` (new dependency) under a single key;
  loaded synchronously at startup (SharedPreferences instance obtained in
  `main()` before `runApp`, passed via provider override — same pattern
  other one-time init like Supabase already follows).
- `MaterialApp` in `app/lib/main.dart` gains `locale` (watched from the
  provider), `localizationsDelegates`, and `supportedLocales`. Changing
  the locale rebuilds the whole app instantly.

## Language picker UI

- **Profile screen**: a "Language" row opening a chooser with the three
  options, each labeled in its own script — "English", "සිංහල", "தமிழ்" —
  plus "System default". Selecting persists and applies immediately.
- **Login screen**: a small globe `IconButton` (top-right) opening the
  same chooser, so users can switch language before signing in.
- The chooser is one shared widget (e.g.
  `app/lib/presentation/widgets/language_picker.dart`) used by both.

## Scope of translation

Translated: every static UI string — screen titles, buttons, labels,
input hints, validators, snackbar/dialog messages, empty states — across
all presentation files (login, reset password, home, category, map,
place detail, add place, write review, leaderboard, profile, splash, and
shared widgets like filters sheet, place card, review tile, section
headers).

Not translated:
- User-generated content: place names, descriptions, reviews.
- Stored data values: district names in the Add Place dropdown (DB
  values; display-only translation can be a later enhancement).
- Category *values* stay English in the DB; their display labels are
  translated in the UI layer only.

Strings with runtime values use ARB placeholders (e.g.
`"youRated": "You: {rating}★"`).

## Fonts

Sinhala and Tamil scripts render with system fonts (Noto) on Android,
iOS, and web — no bundled fonts or theme changes needed.

## Error handling

- Unsupported/removed persisted locale value → treated as `null`
  (system default).
- Device set to an unsupported language → Flutter's resolution falls
  back to English.

## Testing

- Widget test: pumping the app shell with `locale: Locale('si')` (and
  `'ta'`) shows the translated login-screen strings.
- Widget test: selecting a language in the picker updates
  `localeProvider` and the visible strings.
- Unit test: `localeProvider` persists to and restores from
  `shared_preferences` (mocked via `SharedPreferences.setMockInitialValues`).

## Out of scope

- Translating user-generated or DB-stored content.
- Per-locale number/date formats beyond what `intl` gives for free.
- RTL support (none of the three languages is RTL).
