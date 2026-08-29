# Handoff: CeylonReview mobile app — dark redesign

## Overview
A ten-screen mobile design for Ceylon Review: discover, rate and review places across
Sri Lanka (food, beaches, nature, temples, hotels, shopping), upload photos, and earn
rank for contributing. It covers onboarding, home discovery, search + filters, category
browse, place detail, a three-step review flow, map explore, saved lists, leaderboard
and profile.

Target codebase: `harshawalisundara97/ceylonreview.lk` — the Flutter app under `app/`
(Material 3, Riverpod, Supabase, flutter_map, clean domain/data/application/presentation
layering, gen-l10n for en/si/ta).

## About the design files
The files in `prototype/` are **design references written in HTML** — a click-through
prototype showing intended look and behaviour. They are **not production code to copy**.
The task is to recreate these screens in the Flutter app using its existing patterns:
widgets under `app/lib/presentation/`, Riverpod providers under `app/lib/application/`,
the theme derived from `tokens/*.css` (extended per the token table below), and the
existing l10n strings. Do not embed the HTML, and do not add a webview.

## Fidelity
**High fidelity.** Colors, type sizes, spacing, radii and copy are final and should be
matched closely. Anything unresolved is called out explicitly under "Open questions".

## The one big decision to confirm first
This redesign moves the app to a **dark-first** shell. The ground, surfaces, type and
component treatment come from the Nocturne design system (`prototype/nocturne-styles.css`),
**not** from the repo's current light Ceylon Green theme. The six category colours are
kept — they are the repo's own dark-mode category primaries from `tokens/colors.css` —
and are used only as accents: kickers, 2px card hairlines, map pins, badge dots.

If the product should stay light-first, stop and re-theme before implementing; every
screen below assumes the dark ground.

## Design tokens

### Ground and surfaces
| Token | Value | Use |
| --- | --- | --- |
| bg | `#161826` | Screen background |
| bg deep | `#0e0f18` | Canvas behind the phone, map fallback |
| surface | `#232532` | Cards, inputs, nav bar, list rows |
| surface raised | `#1b1d2a` | Bottom sheets, sidebars |
| hairline | `#3f424d` | 1px card edge (`box-shadow: 0 0 0 1px`) |
| divider | `rgba(233,233,237,.10)` | In-card separators |

### Text
| Token | Value |
| --- | --- |
| text primary | `#e9e9ed` |
| text secondary | `rgba(233,233,237,.62)` |
| text muted | `rgba(233,233,237,.50)` |
| text faint | `rgba(233,233,237,.45)` |

### Accent (interface)
| Token | Value | Use |
| --- | --- | --- |
| accent | `#9184d9` | Borders on primary actions, focus ring, progress fill |
| accent bright | `#b5abfc` | Accent text and icons, avatar fill, floating-nav FAB |
| accent tint | `rgba(145,132,217,.10–.22)` | Button fill, selected pill, callout |

Primary buttons are **outlined**: 1px `#9184d9` border, `rgba(145,132,217,.10)` fill,
`#b5abfc` label. Never a solid accent flood.

### Category accents (from `tokens/colors.css`, dark-mode primaries)
| Category | Hex |
| --- | --- |
| Food | `#FFB59C` |
| Beaches | `#5BD6F0` |
| Nature | `#A7DC7F` |
| Temples | `#FFB95E` |
| Hotels | `#D5BBFF` |
| Shopping | `#FFB0CD` |

Used for: uppercase category kicker text, a 2px bottom hairline on photo tiles, map pin
fill/stroke, badge dots, and a `color-mix(… 26%, transparent)` radial glow inside photo
placeholders. Star rating stays `#FFB951`. Positive delta `#A7DC7F`, negative `#FFB59C`.

### Type — Inter throughout (weights 400/500/600)
| Role | Size / line-height / weight | Notes |
| --- | --- | --- |
| Screen title | 26px / 1.14 / 500, `-0.02em` | Home, Saved, Ranks |
| Hero title | 32px / 1.1 / 500, `-0.02em` | Onboarding |
| Detail title | 28px / 1.1 / 500 | Place detail over hero |
| Section head | 17–19px / 500 | "Near you", "What people said" |
| Card title | 15px / 500 | Place name in list cards |
| Body | 13–14.5px / 1.55–1.6 / 400 | Blurbs, review text |
| Meta | 11–12px / 400 | Rating rows, districts |
| Kicker | 10px / 600, `0.09–0.1em`, uppercase | Category labels, section eyebrows |
| Nav label | 10px / 500 | Bottom tab labels |

Headings never go past weight 500 — hierarchy is size and space.

### Spacing, radii, elevation
- Screen gutter 20px. Card padding 10–14px. Section gap 22–26px.
- Radii: 999px pills · 16px hero cards · 14px cards and sheets · 12px buttons, inputs,
  photo tiles · 10px small tiles · 8–9px chips and tags.
- Elevation is an edge plus ambient darkness: `box-shadow: 0 0 0 1px #3f424d` for cards;
  sheets add `0 -20px 44px rgba(0,0,0,.5)`. No stacked shadows.
- Minimum tap target 44px (nav items 56px, list rows ≥ 62px).

## Screens

### 1. Onboarding
Purpose: set language, state the promise, enter the app.
- Top 462px: gradient ground `linear-gradient(165deg,#2c3040,#191b28 60%,#161826)` with two
  radial washes (accent at 78%/12%, beach cyan at 15%/85%) and a bottom fade to `#161826`.
- Brand: `assets/logo-light.svg` at 136px wide, 60px from top, 22px from left.
- Trust pill above the fold edge: "4,812 verified visits this month", 11px, check glyph in
  `#A7DC7F`, 1px `rgba(233,233,237,.18)` border, 999px radius.
- Headline 32px: "The island, reviewed by people who actually went."
- Body 14.5px secondary: beaches / kottu joints / cloud forests line.
- Language row: three equal 46px buttons — English · සිංහල · தமிழ் — selected gets accent
  border + `#b5abfc` label. Wire to the existing gen-l10n locale provider.
- Primary "Start exploring" (52px, outlined accent), ghost "I'll sign in later" below.

### 2. Home
Purpose: discovery. Two layouts exist as alternatives — see "Variants".
- Header: kicker "Tuesday · Colombo", title "Hi Nadeesha — where to, then?", 42px avatar
  circle (`#b5abfc` fill, `#161826` initial) that opens Profile.
- Search bar: 48px, surface, hairline, magnifier + placeholder "Beaches, kottu, waterfalls…",
  a 1px vertical divider and a filter glyph in accent. Tapping opens Search.
- Category pill row (horizontal scroll): All + six categories. Selected pill =
  `color-mix(in srgb, <category> 16%, transparent)` fill, 1px category border, category text.
  Selecting a category navigates to Category browse.
- "Trending this week": horizontal rail of 236px cards, 158px photo, kicker chip over the
  image, name 15px, meta row "★ 4.9 · 342 reviews · Colombo".
- "Near you": vertical list of place cards (see Card style variants).

### 3. Search & filters
- Back circle (38px) + active search field (accent border, caret) showing a typed query.
- Filter chips row: Open now · Under Rs 3,000 · Verified photos · Family friendly.
- Filter card (surface, hairline, 14px radius) with three rows separated by 1px dividers:
  - Sort by — segmented Rating / Nearest / Newest, selected = accent tint + `#b5abfc`.
  - Minimum rating — five 30px star buttons, filled `#FFB951`, sub-label "Hides anything below 4.0".
  - "Only places I can reach today" — 44×26 pill toggle, on = `rgba(145,132,217,.3)` track,
    `#b5abfc` knob at `left:20px`; off = transparent track, `rgba(233,233,237,.5)` knob at `left:3px`.
- Results: "N matches" + "Ordered by rating", then 56px-thumb rows.

### 4. Category browse
- Header wash: `linear-gradient(180deg, color-mix(in srgb, <category> 14%, transparent), transparent)`.
- Kicker "N places · N reviews" in the category colour, 29px title ("Beaches on the island"),
  a one-line local blurb, then a rule fading right: `linear-gradient(to right, <category>, transparent 70%)` at 50% opacity.
- Category pill row repeats, then a 2-column grid of 118px-photo tiles.

### 5. Place detail
- Hero 322px: gradient ground + category radial glow + camera glyph at 24% opacity, then a
  scrim `linear-gradient(to top, #161826 2%, rgba(22,24,38,.55) 40%, transparent 75%)`.
- Overlay controls at 56px from top: back, save (fills with the category colour when saved),
  share — all 38px circles, `rgba(22,24,38,.62)` with a 1px light border.
- Title block over the hero: kicker "BEACHES · Matara", name 28px.
- Stat row: 30px rating number + five 12px stars + "128 reviews · 412 photos"; 1px vertical
  divider; then two trust lines — "96 verified visits" (green check) and "Best Nov–Apr" (clock).
- Blurb 14px, tag row (28px, `rgba(233,233,237,.06)` fill, 1px light border).
- Actions: "Write a review" (flex, outlined accent, 50px) + "Directions" (secondary outline).
- "Traveller photos": 104px square rail. "What people said": review cards with 34px initial
  avatar in the reviewer's colour, name + optional green "VERIFIED" chip, 10px stars,
  "2 weeks ago · 41 reviews", body 13px, then a "Helpful · 38" outlined button and "Reply".

### 6. Write review — three steps (default)
Header: back circle, "Review <place>", step label, "Step 2 of 3", then a 3-segment 3px
progress bar (filled segments `#9184d9`, empty `rgba(233,233,237,.14)`).
- **Step 1 — Rate it.** "So, how was it?" + five 62px star buttons (selected get an amber
  tint fill and border), a word under it — Rough / Not great / Fine / Really good /
  Best on the island. Visit-type pills: Solo · Couple · Family · Friends · Work trip.
  Green callout: "Visit verified by location — you were here on 14 Aug. Verified reviews
  rank higher and earn double points."
- **Step 2 — Photos and tags.** 3-column grid: an "Add" tile (dashed accent border) then
  photo tiles with a remove ✕ and a "COVER" chip on the first. Caption "2 of 8 · long-press
  to set the cover shot". Then quick tags (9 options, multi-select pills) and
  "N tags chosen — these become filters other people search by."
- **Step 3 — Write it up.** Focused text area (accent border) with counter "n / 1000", then
  three settings rows with pill toggles: show visit as verified · notify on replies ·
  add to public photo wall. Amber-tinted policy note at the bottom.
- Footer bar (gradient to `#161826`): "Back" secondary + primary "Next" / "Post review".
  Primary is disabled-looking until a rating exists.
- **Success state**: accent ring with a check, "Posted. Nicely done.", two stat tiles
  ("+24 points", "#118 in Colombo"), "See your rank" and "Back to home".

### 7. Map explore
- Real Sri Lanka geometry — **do not hand-draw the island**. In Flutter use the existing
  `flutter_map` with a dark tile layer; the prototype's inline path came from Natural Earth
  (world-atlas 2.0.2, 50m) projected with `d3.geoMercator`. Pins are placed from true
  lat/long (Colombo 6.935/79.843, Mirissa 5.945/80.459, Sinharaja 6.404/80.454, Kandy
  7.294/80.641, Kandalama 7.870/80.703, Arugam Bay 6.840/81.836, Horton Plains 6.809/80.800,
  Dambulla 7.856/80.649).
- Pin: teardrop, fill `color-mix(in srgb, <category> 26%, #1b1d2a)`, 1.4px category stroke,
  category dot; selected pin fills solid with the category colour, dot goes `#161826`, and a
  26-unit halo at 14% opacity appears.
- Floating search bar (46px, translucent surface, blur) + category pills below it.
- Bottom sheet 262px, radius 22px top, `#1b1d2a`, grab handle: selected place kicker, name
  19px, rating row, "Open" outlined button; divider; then a scrolling nearby list of 46px rows.

### 8. Saved
- Title "Saved" + "N places in 3 lists. Trip-shaped, not alphabetical."
- Collection rail: 190px cards with a 104px tinted photo, name over it, category hairline,
  "6 places · Dec, with Amaya". Last tile is a dashed "New list".
- "Everything saved": 62px-thumb rows with a bookmark button that unsaves.

### 9. Leaderboard
- Title "Island ranks" + "Points for reviews, more for photos, double for verified visits."
- Scope segmented control: Colombo / Island / Friends.
- Podium: three columns, centre is rank 1 (62px avatar, 76px bar), sides 50px/56px and 44px.
  Bars are `linear-gradient(180deg, color-mix(<avatar> 18%, transparent), rgba(35,37,50,.2))`
  with a 1px light border, no bottom border, radius 10px top only. Rank numeral inside the
  bar top; centre numeral `#FFB951`. Keep 20px between the podium and the card below.
- "You" card: accent-bordered, avatar, "You — #118 in Colombo", "46 points off Silver
  Explorer. Two reviews should do it.", green delta.
- Ranked rows: rank numeral (tabular), 34px avatar, name, "412 reviews · Island Elder",
  points (tabular), delta coloured green/coral/grey. 1px row rule at 7% opacity.

### 10. Profile
- 68px avatar with a `linear-gradient(140deg,#b5abfc,#5BD6F0)` fill, name 21px,
  "@nadee · Colombo 05 · joined 2024", "Edit profile" (outlined accent) + "Share".
- Bio, then four stat tiles: Reviews 64 · Photos 182 · Points 2.4k · Colombo #118.
- Badges rail: pill with a category-coloured dot, 10% tint fill, 40% border.
- Tabs as three pills: Reviews 64 / Photos 182 / Visited 71.
  - Reviews: cards with place name, stars, date, "+24 pts", body.
  - Photos: 3-column square grid, 6px gap, 8px radius.
  - Visited: rows with a 52px thumb and a chevron.
- App language row at the bottom: globe icon, "English · සිංහල · தமிழ்", chevron.

## Interactions & behaviour
- Bottom nav: Home · Map · Review (centre) · Saved · You. Active tab = `#b5abfc` icon with a
  22%-alpha fill and label; inactive `rgba(233,233,237,.5)`. Nav is hidden on onboarding and
  during the review flow.
- Navigation: home → detail (card tap) → review (CTA) → success → leaderboard/home;
  category pill → category browse; map pin → sheet → detail.
- Save toggles are optimistic and must `stopPropagation` so they don't open the card.
- Review flow guards: cannot post without a rating; Back returns a step; the last step posts.
- Motion (from the repo's own tokens): card entrance 220ms ease-emphasized translate-up +
  fade, 40ms stagger; press 120ms scale(0.97); sheets 360ms ease-emphasized; toggles 160ms.
  Respect `prefers-reduced-motion` / Flutter's disable-animations flag.
- Photo placeholders in the prototype are gradient tiles with a camera glyph — in the app
  these are network images with the same 2px category hairline and scrim.

## State
Per screen, as Riverpod state: `screen/route`, `selectedCategory`, `selectedPlaceId`,
`savedPlaceIds`, `mapSelectedPinId`, `profileTab`, `leaderboardScope`, and for the review
flow `step`, `rating`, `visitType`, `photos[]`, `tags[]`, `text`, `verifiedVisit`,
`notifyReplies`, `publicWall`, `posted`. Search holds `query`, `sort`, `minRating`,
`reachableToday`. Data comes from Supabase as it does today; the verified-visit flag needs a
location check at review time.

## Variants shipped in the prototype
Four alternatives are exposed as props on the design component; pick one per axis before
building:
- `homeLayout`: `feed` (trending rail + list) or `mosaic` (2-column staggered grid).
- `cardStyle`: `photo` (196px hero card) or `compact` (96px thumb row).
- `navStyle`: `bar` (88px labelled bar) or `floating` (64px floating pill with a solid FAB).
- `reviewFlow`: `steps` (3 steps) or `single` (everything on one scroll).

## Assets
- `prototype/assets/logo-light.svg` — white wordmark for dark surfaces (from repo `assets/`).
- `prototype/assets/logo-icon.svg` — pin + lotus icon mark (from repo `assets/`).
- Icons: the prototype draws Phosphor-style 1.7–2px stroke glyphs inline. In Flutter keep the
  repo's Material Symbols Rounded set — do not mix icon families.
- Photography: none supplied. The app already sources Wikimedia-licensed photos per place.

## Open questions
1. Dark-first, or dark mode alongside the existing light theme?
2. Does the backend expose a verified-visit signal today, or is that new work?
3. Leaderboard scopes — is "Friends" real, or should it wait for a follow graph?

## Files
- `prototype/CeylonReview App.dc.html` — the click-through prototype, all ten screens.
- `prototype/nocturne-styles.css` — the design-system token sheet the shell is built on.
- `prototype/assets/*` — brand marks.

## Using this with Claude Code
1. Copy `design_handoff_ceylonreview_mobile/` into the repo root (it is reference material —
   consider adding it to `.gitignore` or committing it under `docs/`).
2. Open the repo in Claude Code and prompt, roughly:
   > Read `design_handoff_ceylonreview_mobile/README.md`. Implement the Home and Place detail
   > screens in `app/lib/presentation/` following our existing Riverpod + Material 3 patterns.
   > Add the dark token set to the theme first. Follow `CLAUDE.md` — branch, tests, then PR.
3. Their `CLAUDE.md` requires a feature branch, tests before the PR, and green CI — so ask
   Claude Code to work one screen per branch rather than all ten at once.
