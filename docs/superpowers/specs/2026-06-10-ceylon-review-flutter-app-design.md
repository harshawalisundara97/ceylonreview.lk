# Ceylon Review Flutter App — Design Spec

**Date:** 2026-06-10
**Status:** Approved by user

## Goal

Build the Ceylon Review mobile app (Sri Lanka's all-in-one place review app) as a
Flutter application, implementing all 7 screens from the existing design system
prototype (`ui_kits/ceylon-app/`), with clean layered architecture and SOLID
principles. Runs on a real Android device.

## Decisions (confirmed with user)

| Decision | Choice |
|---|---|
| Data source | Sample (in-memory) data first; backend later behind repository interfaces |
| Screen scope | All 7 screens: Login, Home, Category, Place Detail, Write Review, Map, Profile |
| Map provider | `flutter_map` + OpenStreetMap (free, no API key) |
| Architecture | Layered + Riverpod (UI → application/state → domain interfaces → data) |
| Theming | Full design-token port: 7 palettes (brand + 6 categories), light + dark |
| Auth | Mock login (any input signs in), session held in memory |

## Project layout

Flutter project lives in `app/` at repo root; design system files stay untouched.

```
app/lib/
├── main.dart
├── core/
│   ├── theme/        app_colors.dart, app_typography.dart, app_spacing.dart, app_theme.dart
│   └── routing/      app_router.dart
├── domain/
│   ├── models/       place.dart, review.dart, user.dart, category.dart
│   └── repositories/ places_repository.dart, reviews_repository.dart, auth_repository.dart (abstract)
├── data/sample/      sample_places_repository.dart, sample_reviews_repository.dart,
│                     sample_auth_repository.dart, sample_data.dart
├── application/      auth_provider.dart, category_theme_provider.dart,
│                     places_provider.dart, reviews_provider.dart
└── presentation/
    ├── screens/      login/, home/, category/, place_detail/, write_review/, map/, profile/
    └── widgets/      place_card.dart, rating_stars.dart, category_pill.dart,
                      bottom_nav.dart, search_bar.dart, star_picker.dart, avatar.dart, ...
```

## Design-token mapping

- `tokens/colors.css` → `app_colors.dart`: brand constants (Ceylon Green `#0F6E56`,
  Golden Amber `#EF9F27`), MD3 color roles, 6 category palettes (Food `#C0512C`,
  Nature `#43811F`, Beach `#00788F`, Hotels `#7A4F9E`, Temples `#9A5B00`,
  Shopping `#B11A60`), each with light + dark variants, plus category tints.
- `tokens/typography.css` → `app_typography.dart`: Bricolage Grotesque for
  display/headline/title-lg; Plus Jakarta Sans for everything else; body floor 14px.
  Fonts via `google_fonts`.
- `tokens/spacing.css` → `app_spacing.dart`: 8px grid, radii (pill 999 / xl 28 /
  lg 20 / md 14 / sm 10), motion durations (category swap 360ms, card entrance 220ms,
  press 120ms), elevation kept very flat.
- Icons: Material Symbols Rounded (filled variants for active nav states).

## Signature feature: dynamic category theming

`categoryThemeProvider` (Riverpod `Notifier`) holds the active category.
`app_theme.dart` builds `ThemeData` from the active palette + brightness.
`AnimatedTheme` (360ms, standard easing) cross-fades the whole UI when the
category changes. Light/dark follows system setting with manual override on
Profile screen.

## SOLID application

- **S**: one responsibility per file (widget renders; repository fetches; tokens define).
- **O**: new category = one palette entry + one enum case; no screen edits.
- **L/D**: screens depend only on abstract repositories; Riverpod injects the
  sample implementations; a future `SupabasePlacesRepository` swaps in one override.
- **I**: separate small interfaces for auth, places, reviews.

## Screens

5-tab bottom nav: Home, Map, Post Review (center, filled primary), Feed*, Profile.
(*Feed tab routes to Category screen content for v1, as in the prototype.)

1. **Login** — logo, mock email/password, "Explore" CTA.
2. **Home** — hero search bar, category pill row (drives re-theming), Trending
   This Week carousel, nearby places list.
3. **Category** — themed header, filter chips, place card list.
4. **Place Detail** — full-bleed hero photo with bottom scrim, rating `4.7 · 1.2k`,
   review list, "Write a Review" CTA, "Get Directions" button.
5. **Write Review** — tappable StarPicker, text field, photo placeholder row, Post Review.
6. **Map** — flutter_map + OSM tiles, category-colored markers for sample places,
   tapping a marker opens a place summary sheet.
7. **Profile** — avatar, user's reviews, dark-mode toggle, sign out.

## Sample data

Real Sri Lankan places only (per design brief): Ministry of Crab, Nuga Gama,
Beach Wadiya; Mirissa, Unawatuna, Hiriketiya, Arugam Bay; Heritance Kandalama,
Cinnamon Grand, Tri; Temple of the Tooth, Dambulla Cave Temple, Kelaniya;
Sinharaja, Horton Plains, Ravana Falls; Odel, Dutch Hospital, Pettah Market.
Each place: name, category, district, coordinates, rating (one decimal), review
count (`1.2k` format), description, 2–3 sample reviews. Posted reviews persist
in memory for the session.

## Content rules (from design system)

Title Case screen titles; sentence-case body; ALL-CAPS wide-tracked category
labels; no emoji in UI chrome; ratings `4.7` never `4.70`; distance `2.3 km`.

## Error handling

Repositories return typed results; UI shows friendly empty/error states
(no raw exceptions). Mock login rejects empty fields with inline validation.

## Testing

- Unit: sample repositories (fetch/filter/add review), category theme notifier.
- Widget: RatingStars rendering, PlaceCard content, StarPicker interaction.
- Manual: `flutter run` on the connected Samsung device (R83X201SG1Z) as final verification.

## Out of scope (v1)

Real backend (Supabase), real auth, photo upload, push notifications,
Sinhala/Tamil localization, iOS release setup.
