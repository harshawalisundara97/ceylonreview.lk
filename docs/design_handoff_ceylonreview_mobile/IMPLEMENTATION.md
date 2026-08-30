# Implementation plan — read this before the README

I looked at the Flutter app after the first pass. The spec was fine; the *process* is what
failed. Four concrete reasons, then the fix.

## Why the first attempt came out incomplete

**1. Three designed screens have no file in the app.** They were never "skipped" — there was
nowhere to put them:

| Designed screen | In the app today |
| --- | --- |
| Search & filters | only `presentation/widgets/filters_bottom_sheet.dart` — no screen |
| Saved collections | only `application/favorites_provider.dart` — no screen |
| Onboarding | `login_screen.dart` + `splash_screen.dart`, neither is the designed flow |

**2. The nav shell doesn't match the design.** `presentation/shell/app_shell.dart` has six
tabs — Home, Map, Ranks, Post, Feed, Profile. The design has five — Home, Map, Review,
Saved, You. Saved has no tab to live in, and the Feed tab points at `CategoryScreen`, which
in the design is reached by tapping a category pill, not a tab.

**3. Open question 1 got answered silently, the wrong way.** `core/theme/app_colors.dart`
now carries the Nocturne dark tokens, but the comment reads: *"dark mode is opt-in via the
existing Profile > Dark Mode toggle; the light Ceylon Green theme stays the app default."*
So on launch the app is still light green and none of the redesign is visible. That is a
real product decision and it is yours to make — see "Decide this first" below.

**4. Ten screens in one prompt.** The README is ~16k characters. One session cannot hold ten
screens' worth of detail and stay accurate to the end; the later screens degrade. One screen
per branch is what your own `CLAUDE.md` workflow wants anyway.

## Decide this first

Everything else depends on this one answer.

- **Option A — dark-first.** The redesign becomes the app. `ThemeMode.dark` is the default,
  light stays available. This is what the design was drawn for; every screenshot in
  `screens/` is what the user sees on launch.
- **Option B — dark as an opt-in mode.** What the code does now. Then the redesign only ever
  appears behind the Profile toggle, and every screen has to work in *both* themes — roughly
  double the work, and the light versions are not designed.

If you want the app to look like `screens/`, pick A and say so in the first prompt. I'd
recommend A.

The other two open questions from the README — the verified-visit signal and whether the
"Friends" leaderboard scope is real — only affect two screens. Answer them when you get to
branch 6 and branch 8.

## Visual targets

`screens/*.png` — one image per screen, rendered from the prototype. Attach the matching
PNG to each Claude Code session; a picture stops far more drift than prose does.

## Order of work

Foundation first, then the screens that already exist (restyle), then the three new ones.
One branch per row, per your `CLAUDE.md`: tests, green CI, PR, then the next.

| # | Branch | Scope | Screens |
| --- | --- | --- | --- |
| 1 | `feature/nocturne-theme` | theme default + shared widgets | — |
| 2 | `feature/nav-shell` | 5-tab shell, routes for the new screens | — |
| 3 | `feature/home-redesign` | restyle | `02-home.png` |
| 4 | `feature/place-detail-redesign` | restyle | `05-place-detail.png` |
| 5 | `feature/category-redesign` | restyle | `04-category.png` |
| 6 | `feature/write-review-redesign` | restyle + 3 steps + success | `06-write-review.png` |
| 7 | `feature/map-redesign` | restyle | `07-map.png` |
| 8 | `feature/leaderboard-profile-redesign` | restyle both | `09`, `10` |
| 9 | `feature/search-screen` | **new screen** | `03-search-filters.png` |
| 10 | `feature/saved-screen` | **new screen** | `08-saved.png` |
| 11 | `feature/onboarding` | **new screen** | `01-onboarding.png` |

Branches 1 and 2 are not optional and must land first — they are why the individual screens
came out inconsistent. Everything after 2 is independent, so you can stop at any point and
still have a coherent app.

## Prompts

Paste one per session. Attach the named PNG. Start a fresh session per branch — a long
session is what caused the drop-off the first time.

**Branch 1 — theme**

> Read `docs/design_handoff_ceylonreview_mobile/README.md`, the "Design tokens" section only.
> `core/theme/app_colors.dart` already has the Nocturne dark values. Two changes:
> make `ThemeMode.dark` the app default in `app_theme.dart` / `main.dart` (keep light
> available behind the existing Profile toggle), and audit the dark scheme against the token
> table — ground `#161826`, surface `#232532`, hairline `#3f424d`, accent `#9184d9`, accent
> bright `#b5abfc`. Then update the shared widgets in `presentation/widgets/` to the spec:
> `place_card.dart`, `rating_stars.dart`, `star_picker.dart`, `review_tile.dart`,
> `category_pill_row.dart`, `section_header.dart`, `user_avatar.dart`. Primary buttons are
> outlined — 1px `#9184d9` border, `rgba(145,132,217,.10)` fill, `#b5abfc` label, never a
> solid fill. Cards are `#232532` with a 1px `#3f424d` edge and no drop shadow. Follow
> CLAUDE.md: branch, tests, green CI, then PR.

**Branch 2 — shell**

> Read the "Interactions & behaviour" section of the handoff README. Change
> `presentation/shell/app_shell.dart` from six tabs to five: Home, Map, Review (centre),
> Saved, You. Drop the Feed tab — Category is reached by tapping a category pill on Home, not
> from the nav. Active tab is `#b5abfc` with a 22%-alpha icon fill; inactive is
> `rgba(233,233,237,.5)`. The nav hides on onboarding and during the review flow. Create
> placeholder screens with routes for Saved and Search so later branches have somewhere to
> land; leave them empty. Follow CLAUDE.md.

**Branches 3–8 — one screen at a time** (swap the names in)

> Read the "<Screen name>" section of `docs/design_handoff_ceylonreview_mobile/README.md` —
> that section only. Restyle `presentation/screens/<folder>/<file>.dart` to match it and the
> attached screenshot. Use the shared widgets and theme tokens from the earlier branches; do
> not introduce new colors or text styles. Keep the existing Riverpod providers and Supabase
> data flow exactly as they are — this is a visual and layout change. Follow CLAUDE.md.

**Branches 9–11 — the new screens**

> Read the "<Screen name>" section of `docs/design_handoff_ceylonreview_mobile/README.md`
> and match the attached screenshot. This screen does not exist yet: create
> `presentation/screens/<folder>/<file>.dart`, wire it into the shell route added in
> `feature/nav-shell`, and add a Riverpod provider under `application/` for its state (the
> README "State" section lists the fields). For Saved, build on the existing
> `favorites_provider.dart`. For Search, reuse the logic in
> `presentation/widgets/filters_bottom_sheet.dart` as a full screen. Follow CLAUDE.md.

## If a screen still comes out wrong

Give it the screenshot and one sentence about the specific gap — "the podium bars are solid,
they should be a gradient with a 1px border and no bottom border" — rather than re-running
the whole screen. Targeted corrections hold; re-runs drift.
