# Ceylon Review

Sri Lanka's all-in-one place review app — discover, rate and review restaurants, hotels, beaches, waterfalls, temples, forests, shopping stores and services across the island.

## Features

- **7 core screens** — Home, Category browse, Place detail, Write review, Profile, Map, and Login
- **6 themed categories** — Food, Nature, Beach, Hotels, Temples, Shopping, each with its own colour palette that re-skins the UI with an animated cross-fade
- **Star ratings & reviews** — interactive star picker, review tiles with author avatars, one-decimal rating display (e.g. `4.7`)
- **Interactive map** — browse places on a map of Sri Lanka with category-coloured pins
- **Light & dark mode** — warm greenish off-white light surfaces and green-charcoal dark surfaces, per the Ceylon Review design system
- **Real Sri Lankan places** — sample data features Ministry of Crab, Mirissa Beach, Temple of the Tooth, Sinharaja Forest, Heritance Kandalama, Odel and more

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | [Flutter](https://flutter.dev) (Material 3) |
| Language | Dart |
| State management | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) |
| Maps | [flutter_map](https://pub.dev/packages/flutter_map) + [latlong2](https://pub.dev/packages/latlong2) |
| Typography | [google_fonts](https://pub.dev/packages/google_fonts) — Bricolage Grotesque (display) + Plus Jakarta Sans (UI/body) |
| Linting | flutter_lints |
| Platforms | Android, iOS, Web, macOS, Linux, Windows |

## Architecture

Clean-architecture-style layering:

```
lib/
├── core/theme/        # Colours, typography, spacing, Material 3 theme
├── domain/            # Models (Place, Review, User, Category) + repository interfaces
├── data/sample/       # In-memory sample repositories & seed data
├── application/       # Riverpod providers (auth, places, reviews, category theme)
└── presentation/      # Screens, app shell (bottom nav), shared widgets
```

The data layer currently uses in-memory sample repositories behind domain interfaces, so a real backend (e.g. REST or Supabase) can be swapped in without touching the UI.

## Getting Started

```bash
cd app
flutter pub get
flutter run
```

Use `flutter devices` to list available targets and `flutter run -d <device-id>` to pick one.
