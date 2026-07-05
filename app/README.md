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
