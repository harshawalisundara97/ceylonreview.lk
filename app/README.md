# Ceylon Review

Sri Lanka's all-in-one place review app — discover, rate and review restaurants, hotels, beaches, waterfalls, temples, forests, shopping stores and services across the island.

## Features

- **7 core screens** — Home, Category browse, Place detail, Write review, Profile, Map, and Login
- **6 themed categories** — Food, Nature, Beach, Hotels, Temples, Shopping, each with its own colour palette that re-skins the UI with an animated cross-fade
- **Star ratings & reviews** — interactive star picker, review tiles with author avatars, one-decimal rating display (e.g. `4.7`)
- **Interactive map** — browse places on a map of Sri Lanka with category-coloured pins
- **Light & dark mode** — warm greenish off-white light surfaces and green-charcoal dark surfaces, per the Ceylon Review design system
- **Real Sri Lankan places** — the database is seeded with Ministry of Crab, Mirissa Beach, Temple of the Tooth, Sinharaja Forest, Heritance Kandalama, Odel and more, each with a real, freely-licensed photo (sourced from Wikimedia Commons) instead of a placeholder
- **Cloud backend (Supabase)** — real email/password sign-up & sign-in with persisted sessions, places and reviews stored in PostgreSQL, live ratings recomputed by a database trigger on every new review, and Row Level Security guarding writes
- **Search & discovery filters** — filter by price level and "open now", sort by rating/price/distance, and see live distance ("2.3 km") from your current location on place cards
- **Favorites** — bookmark places from any card or the detail screen; saved places appear under "Your Favorites" on your profile
- **Add a Place** — signed-in users add missing places with full details, a camera/gallery photo, and a map-pinned location (or their current position); community places are public instantly and badged "COMMUNITY"
- **Leaderboard** — every review earns 10 points; a "Ranks" tab shows an animated podium for the top 3 and a live, all-time ranked list for everyone, with daily rank-change indicators
- **3 languages** — English, Sinhala (සිංහල), Tamil (தமிழ்) — switchable in-app, persisted

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | [Flutter](https://flutter.dev) (Material 3) |
| Language | Dart |
| State management | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) |
| Backend | [Supabase](https://supabase.com) — Auth (email/password), PostgreSQL, Row Level Security |
| Backend SDK | [supabase_flutter](https://pub.dev/packages/supabase_flutter) |
| Maps | [flutter_map](https://pub.dev/packages/flutter_map) + [latlong2](https://pub.dev/packages/latlong2) |
| Location | [geolocator](https://pub.dev/packages/geolocator) — device position for "near me" distance sorting |
| Photos & ids | [image_picker](https://pub.dev/packages/image_picker), [uuid](https://pub.dev/packages/uuid) |
| Typography | [google_fonts](https://pub.dev/packages/google_fonts) — Bricolage Grotesque (display) + Plus Jakarta Sans (UI/body) |
| Linting | flutter_lints |
| Platforms | Android, iOS, Web, macOS, Linux, Windows |
| Localization | [flutter_localizations](https://api.flutter.dev/flutter/flutter_localizations/flutter_localizations-library.html) + [intl](https://pub.dev/packages/intl) (gen-l10n), [shared_preferences](https://pub.dev/packages/shared_preferences) for persisted locale |

## Architecture

Clean-architecture-style layering:

```
lib/
├── core/              # Theme (colours, typography, spacing) + Supabase config
├── domain/            # Models (Place, Review, User, Category) + repository interfaces
├── data/supabase/     # Supabase-backed repositories (auth, places, reviews)
├── data/sample/       # In-memory sample repositories & seed data (offline stand-in)
├── application/       # Riverpod providers (auth, places, reviews, category theme, filters, location)
└── presentation/      # Screens, app shell (bottom nav), shared widgets
```

The UI depends only on domain repository interfaces; the Supabase implementations are injected via Riverpod providers (`lib/application/repository_providers.dart`), with the in-memory sample repositories still available for tests and offline work.

### Backend (Supabase)

- **Auth** — email/password sign-up & sign-in; sessions persist on-device and are restored on app start. New accounts require email confirmation.
- **Database** — PostgreSQL tables `places`, `reviews`, and `profiles` (auto-created on signup by a trigger). A trigger recomputes each place's average rating and review count whenever reviews change.
- **Security** — Row Level Security: anyone can read places/reviews; only signed-in users can post reviews, and only as themselves.

Full architecture report and schema: [docs/BACKEND_PLAN.md](../docs/BACKEND_PLAN.md).

## Getting Started

```bash
cd app
flutter pub get
flutter run
```

Use `flutter devices` to list available targets and `flutter run -d <device-id>` to pick one.

## Testing

All tests live in `app/test/ceylon_review_test.dart`. Run them with:

```bash
cd app
flutter analyze
flutter test
```

Test groups, by area:

| Group | Covers |
|---|---|
| `sriLankaDistricts` | The 25-district list used by the Add Place dropdown |
| `SamplePlacesRepository` | In-memory places repository (fetch, search, category filter) |
| `SampleReviewsRepository` | In-memory reviews repository (add, fetch by place/user) |
| `SampleFavoritesRepository` | In-memory favorites toggle/fetch |
| `SampleLeaderboardRepository` | In-memory leaderboard ranking |
| `Leaderboard providers` | Riverpod providers for rank/points derivation |
| `SamplePhotoStorageRepository` | In-memory photo upload/delete |
| `myFavoriteIdsProvider` | Derived favorites-id-set provider, incl. signed-out case |
| `Place formatting` | Rating/review-count label formatting |
| `Place addedBy` | Community-added place attribution |
| `AddPlaceController` | Add Place form submission, validation, rollback on failure |
| `ReviewSubmitter` | Review submission incl. photo upload + rollback |
| `LeaderboardEntry` | Leaderboard entry model/points math |
| `Widgets` | Screen/widget tests: Home, Category, Map, Place Detail, Add Place, Write Review, Leaderboard, Profile, Login, ReviewTile, PhotoViewer, filters sheet |
| `Localization` | Sinhala/Tamil string resolution smoke test |
| `localeProvider` | Persisted locale restore/clear |
| `LanguagePicker` | Language picker selection updates the locale |
| `Locale end-to-end` | Login screen renders correctly in Sinhala and Tamil |

When adding a feature or fixing a bug, add or update the relevant group above — this table should stay in sync with the actual `group(...)` blocks in the test file.

## Continuous Integration

GitHub Actions (`.github/workflows/flutter-ci.yml`) runs `flutter analyze` and `flutter test` on every push to `main` and every pull request targeting `main`. A PR cannot be merged with a red CI run — check the "Checks" tab on the PR before merging.
