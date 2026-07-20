# Ceylon Review Design System

> Sri Lanka's all-in-one place review app — discover, rate and review
> restaurants, hotels, beaches, waterfalls, temples, forests, shopping
> stores and services across the island.

---

## Sources & References

| Source | URL / Path | Notes |
|---|---|---|
| GitHub (app) | https://github.com/harshawalisundara97/ceylonreview.lk | Production Flutter app, actively developed with CI — see [app/README.md](app/README.md) for current state |
| Design brief | Provided in project prompt | Full feature spec, category list, screen priority order |

This design system was authored from the detailed product brief and remains the source of truth for tokens, voice, and visual rules. For the current state of the shipped app — features, tech stack, architecture, testing, and CI — see [app/README.md](app/README.md).

---

## Flutter App (`app/`)

The production Flutter app lives in [`app/`](app/) — see [app/README.md](app/README.md) for full details.

### Features
- 7 core screens: Home, Category browse, Place detail, Write review, Profile, Map, Login
- 6 themed categories with animated colour cross-fade theming
- Interactive star ratings and reviews
- Map of Sri Lanka with category-coloured pins (flutter_map)
- Light & dark mode following this design system
- Real Sri Lankan places seeded in a cloud PostgreSQL database, each with a real, freely-licensed photo (sourced from Wikimedia Commons)
- Supabase backend: email/password auth with persisted sessions, live reviews with trigger-computed ratings, Row Level Security
- Search & discovery filters: price level, "open now", and sort by rating/price/distance from your current location
- Favorites: bookmark any place from its card or detail page, view them all under "Your Favorites" on your profile
- Add a Place: users add missing places with a photo and map-pinned location; community places are instantly public and reviewable
- Leaderboard: reviews earn points, with an animated podium for the top 3 and daily rank-change indicators on a dedicated Ranks tab
- 3 languages — English, Sinhala (සිංහල), Tamil (தமிழ்) — switchable in-app, persisted

### Tech Stack
| Layer | Technology |
|---|---|
| Framework | Flutter (Material 3) |
| Language | Dart |
| State management | flutter_riverpod |
| Backend | Supabase (Auth + PostgreSQL + RLS) via supabase_flutter |
| Maps | flutter_map + latlong2 |
| Location | geolocator (device position for distance sort) |
| Typography | google_fonts (Bricolage Grotesque + Plus Jakarta Sans) |
| Architecture | Clean layering: domain / data / application / presentation |
| Platforms | Android, iOS, Web, macOS, Linux, Windows |
| Localization | flutter_localizations + intl (gen-l10n), shared_preferences for persisted locale |

---

## Brand Overview

Ceylon Review is a **mobile-first** discovery and review platform designed for Sri Lanka's local population and international tourists. It is the island's first all-in-one place-review product, covering six categories:

| Category | Colour seed | Examples |
|---|---|---|
| 🍽 Food | Spice Terracotta `#C0512C` | Ministry of Crab, The Arcade, Nuga Gama |
| 🌿 Nature | Foliage Green `#43811F` | Sinharaja Forest, Knuckles Range, Ravana Falls |
| 🏖 Beach | Ocean Teal `#00788F` | Mirissa Beach, Unawatuna, Arugam Bay |
| 🏨 Hotels | Plum Violet `#7A4F9E` | Heritance Kandalama, Cinnamon Grand, Tri |
| 🛕 Temples | Saffron Gold `#9A5B00` | Temple of the Tooth, Kelaniya Raja Maha Vihara |
| 🛍 Shopping | Magenta Pink `#B11A60` | Odel, Dutch Hospital Shopping Precinct |

The **core brand colour is Ceylon Green `#0F6E56`** — used on the Home screen, app chrome, and primary actions. **Golden Amber `#EF9F27`** is the constant accent (star ratings, highlights).

---

## Content Fundamentals

### Voice & Tone
- **Warm, welcoming, knowledgeable** — like a local friend recommending their favourite spots.
- **Inclusive** — designed for children to elderly; language is simple and never condescending.
- **Proud of Sri Lanka** — copy celebrates the island, its culture, food and people; never generic.
- **Not pretentious** — direct, honest, friendly. No corporate jargon.

### Casing
- Screen titles: **Title Case** (e.g. "Trending This Week", "Write a Review")
- Body text & descriptions: **Sentence case**
- Category labels: **ALL CAPS** with wide letter-spacing (e.g. "BEACHES", "TEMPLES")
- Button labels: **Title Case** or short imperatives ("Explore", "Post Review", "Get Directions")

### First Person
- App speaks to user in **second person** ("Your reviews", "Places you'll love")
- User reviews written in first person ("I visited…", "We had…")

### Emoji
- **Not used in UI chrome** (not in nav labels, buttons, category labels, headings)
- **Allowed in user-generated content** (reviews, bios) — users write naturally
- Category icons are illustrated icons, never emoji

### Real Places — Always
Never use Lorem Ipsum. Always use real Sri Lankan places, dishes, and services:
- Restaurants: Ministry of Crab, The Lagoon at Cinnamon Grand, The Arcade Restaurant, Nuga Gama, Beach Wadiya, Nihonbashi
- Beaches: Mirissa, Unawatuna, Hiriketiya, Arugam Bay, Bentota, Tangalle
- Hotels: Heritance Kandalama, Cinnamon Grand Colombo, Uga Jungle Beach, Tri Hotel, Wallawwa
- Temples: Temple of the Tooth Relic (Kandy), Kelaniya Raja Maha Vihara, Kataragama, Dambulla Cave Temple
- Nature: Sinharaja Forest Reserve, Knuckles Range, Horton Plains, Ravana Falls, Bambarakanda Falls
- Shopping: Odel, Dutch Hospital Shopping Precinct, Arcade Independence Square, Pettah Market

### Numbers & Ratings
- Ratings always shown as `4.7` (one decimal), never `4.70`
- Review counts: `1.2k` not `1,200` for space efficiency
- Distance: `2.3 km` with a space before unit

---

## Visual Foundations

### Color System
The entire UI is built on CSS custom properties that re-skin when a category is active. The swap is animated with a 360ms cross-fade (`--dur-slow`).

**Light mode surfaces** carry a warm, faint greenish-off-white (not clinical hospital white). **Dark mode** surfaces are a warm dark-charcoal with a green-black undertone — never pure `#000000`.

See `tokens/colors.css` for the full system: brand constants, seven palettes (home + 6 categories), semantic roles, and dark-mode overrides.

### Typography
- **Bricolage Grotesque** — display/wordmark/hero numbers. Optical-size 12–96, weight 400–800. Characterful, editorial warmth, works in Sinhala-adjacent contexts.
- **Plus Jakarta Sans** — all UI text, body, labels. Humanist, friendly to all ages. min 14px body.

Scale follows Material Design 3 naming (display → headline → title → body → label) with one extra level for the app's "hero number" format (e.g. "4.7★ · 1.2k reviews").

See `tokens/typography.css`.

### Spacing
8px base grid, with 4px half-steps for tight UI elements. Screen edge gutter: **16px**. Minimum tap target: **44px** (enforced in component CSS). See `tokens/spacing.css`.

### Corner Radii
| Use | Value |
|---|---|
| Chips, Pills, FAB | `--radius-pill` (999px) |
| Hero cards, Sheets | `--radius-xl` (28px) |
| Cards | `--radius-lg` (20px) |
| Buttons, Inputs | `--radius-md` (14px) |
| Small elements | `--radius-sm` (10px) |

Sri Lankan design aesthetic leans into generous rounding — feels warm and inviting, not sharp/corporate.

### Elevation / Shadow
**Very flat** — no heavy drop-shadows or layered gradients. Uses two-layer shadow at low opacity, colour-matched to the current theme. Cards use `--elev-2`, modals/sheets use `--elev-4`. The system uses `hsl(var(--shadow-color) / …)` so shadows shift warm/cool with the theme.

### Backgrounds & Surfaces
- No heavy gradients on primary UI surfaces.
- **Gradient washes are used only** for photo overlay protection (bottom-to-transparent black scrim on place imagery).
- Category tint (`--category-tint`) is an 8% tint of the category primary — used on screen backgrounds, section headers, skeleton loaders.
- Full-bleed photography appears in hero cards (place detail header, carousels). Always with a bottom scrim overlay for text legibility.

### Animation & Motion
- **Category colour transitions**: 360ms ease-standard cross-fade. This is the signature interaction.
- **Card entrances**: 220ms ease-emphasized translate-up + fade. Stagger 40ms per item.
- **Button press**: 120ms scale(0.97) on active, ease-standard.
- **Bottom sheet open**: 360ms ease-emphasized slide-up.
- **No infinite decorative loops** on core screens (reduces distraction for elderly users).
- Respects `prefers-reduced-motion`: all transitions fall back to instant.

### Hover & Press States
- **Buttons**: 8% primary overlay on hover; scale(0.97) on active.
- **Cards**: Subtle lift (`--elev-3`) on hover, shadow appears.
- **Navigation items**: filled icon + label colour change to primary.
- **No underlines** on tappable elements inside the app (native-app feel).

### Photography & Imagery
- Warm, vibrant, golden-hour-lit imagery preferred — matches Sri Lanka's tropical palette.
- Always photography of real places; no stock generics.
- Images always full-bleed within their containers (object-fit: cover).
- 16:9 or 4:3 for place thumbnails; square (1:1) for avatars.
- Bottom scrim: `linear-gradient(to top, rgba(0,0,0,0.65) 0%, transparent 55%)`.

### Borders
- Outline (`--outline-variant`) for inactive inputs, dividers.
- No decorative borders on cards — elevation handles separation.
- Active inputs use `--primary` coloured 2px border.

---

## Iconography

### Icon System: Material Symbols Rounded
- **Font**: `Material Symbols Rounded` (Google Fonts CDN, variable font).
- **Style**: Rounded fill variant. Optical size 24px standard; 20px for compact UI.
- **Usage**: `<span class="material-symbols-rounded">home</span>`
- **Filled variant**: add class `fill` to use `FILL=1` variation setting.

All navigation icons, action icons, and UI chrome icons use Material Symbols Rounded. This is the authentic MD3 icon set.

### Category Icons (App-specific)
Each category uses a Material Symbol as its primary icon:

| Category | Symbol name |
|---|---|
| Food | `restaurant` |
| Nature | `forest` |
| Beach | `beach_access` |
| Hotels | `hotel` |
| Temples | `temple_hindu` |
| Shopping | `shopping_bag` |

### Navigation Icons
| Tab | Default | Active |
|---|---|---|
| Home | `home` (outline) | `home` (fill) |
| Map | `map` (outline) | `map` (fill) |
| Post Review | `add_circle` (fill, primary) | — |
| Feed | `dynamic_feed` (outline) | `dynamic_feed` (fill) |
| Profile | `person` (outline) | `person` (fill) |

### Star Ratings
- Filled stars: `★` unicode or `star` Material Symbol (fill) in `--star` (#EF9F27 / amber).
- Empty stars: `star` (outline) in `--star-empty`.
- Half star: `star_half` Material Symbol fill.

### Asset Files
| File | Description |
|---|---|
| `assets/logo.svg` | Full wordmark (green on light) |
| `assets/logo-icon.svg` | Icon mark only (pin + lotus) |
| `assets/logo-light.svg` | White wordmark for dark surfaces |

---

## File Index

```
ceylon-review-design-system/
├── styles.css                    ← Entry point — @import only
├── readme.md                     ← This file
├── SKILL.md                      ← Claude Code skill manifest
│
├── tokens/
│   ├── colors.css                ← Brand, neutral, semantic, 6 category palettes (light + dark)
│   ├── typography.css            ← Type scale, font families, weights
│   ├── spacing.css               ← Spacing grid, radii, elevation, motion tokens
│   └── fonts.css                 ← Google Fonts @import (Bricolage Grotesque + Plus Jakarta Sans + Material Symbols)
│
├── assets/
│   ├── logo.svg                  ← Full wordmark (dark)
│   ├── logo-icon.svg             ← Icon only
│   └── logo-light.svg            ← White wordmark (for dark backgrounds)
│
├── guidelines/                   ← Specimen cards (Design System tab → Type, Colors, Spacing, Brand)
│   ├── colors-brand.card.html
│   ├── colors-categories.card.html
│   ├── colors-neutrals.card.html
│   ├── colors-semantic.card.html
│   ├── colors-dark.card.html
│   ├── type-display.card.html
│   ├── type-body.card.html
│   ├── type-labels.card.html
│   ├── spacing-scale.card.html
│   ├── spacing-radius.card.html
│   ├── spacing-elevation.card.html
│   ├── spacing-motion.card.html
│   ├── brand-logo.card.html
│   └── brand-category-theme.card.html
│
├── components/
│   ├── core/                     ← Button, Chip, Card, Badge, RatingStars, Avatar
│   ├── forms/                    ← TextInput, SearchBar, StarPicker
│   └── navigation/               ← BottomNav, CategoryPill
│
└── ui_kits/ceylon-app/           ← 7 core screens, light + dark, click-through
    ├── index.html                ← Interactive prototype entry point
    ├── screens/
    │   ├── HomeScreen.jsx
    │   ├── CategoryScreen.jsx
    │   ├── PlaceDetailScreen.jsx
    │   ├── WriteReviewScreen.jsx
    │   ├── ProfileScreen.jsx
    │   ├── MapScreen.jsx
    │   └── LoginScreen.jsx
    └── shared/
        ├── BottomNav.jsx
        ├── TopBar.jsx
        └── theme.js
```

---

## Components Summary

| Component | Location | Description |
|---|---|---|
| `Button` | `components/core/` | Primary, secondary, ghost variants. Pill shape. |
| `Chip` | `components/core/` | Filter chips for categories & tags |
| `Card` | `components/core/` | Place card with image, name, rating, category tint |
| `Badge` | `components/core/` | Count badge, status badge |
| `RatingStars` | `components/core/` | Star display + interactive picker |
| `Avatar` | `components/core/` | User avatar, 3 sizes |
| `TextInput` | `components/forms/` | MD3 outlined + filled variants |
| `SearchBar` | `components/forms/` | Hero search bar |
| `StarPicker` | `components/forms/` | Tappable star rating input |
| `BottomNav` | `components/navigation/` | 5-tab nav with active states |
| `CategoryPill` | `components/navigation/` | Category selector pill row |
