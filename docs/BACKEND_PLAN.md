# CeylonReview — Backend + Database Plan (Supabase)

## Context

The Flutter UI is complete and runs on device, but all data is hardcoded in
`app/lib/data/sample/` (18 places, 8 reviews, fake login that accepts anything).
The goal is a real backend: persistent database, real authentication, and reviews
that actually save — so multiple users see the same live data.

**Chosen stack (confirmed with user):** Supabase + email/password auth.
The Supabase MCP is already connected to this session, so the database, tables,
and seed data can be created directly from here — no dashboard clicking needed.

The app's architecture makes this a clean swap: UI talks to repository
*interfaces* (`app/lib/domain/repositories/`), injected via Riverpod in
`app/lib/application/repository_providers.dart`. We write new Supabase-backed
implementations and change ~3 lines of provider wiring. **No UI screen changes**
except making async loading/error states real and locking login to real auth.

## How it works (the report part)

```
┌─────────────── Flutter app (already built) ───────────────┐
│  Screens → Riverpod providers → Repository interfaces      │
└──────────────────────────┬─────────────────────────────────┘
                           │  supabase_flutter SDK (HTTPS + JWT)
┌──────────────────────────▼─────────────────────────────────┐
│                      SUPABASE (cloud)                       │
│  • Auth        — email/password signup & login, issues JWT  │
│  • PostgreSQL  — places, reviews, profiles tables           │
│  • RLS         — row-level security: who can read/write     │
│  • Storage     — (later) real place photos                  │
└─────────────────────────────────────────────────────────────┘
```

- The app never talks to Postgres directly; the SDK calls Supabase's auto-generated
  REST API. Auth returns a JWT token the SDK attaches to every request.
- **Row Level Security (RLS)** is the authorization layer: rules live in the
  database itself (e.g., "anyone authenticated can read places; users can only
  insert reviews as themselves").
- Place `rating` / `review_count` are **computed from reviews** by a database
  trigger, so they can never drift out of sync.

## Tech stack additions

| Layer | Choice | Why |
|---|---|---|
| Database | Supabase Postgres | Relational fits places↔reviews; free tier |
| Auth | Supabase Auth (email/password) | Matches existing login screen |
| Flutter SDK | `supabase_flutter` (pub.dev) | Official; handles auth session persistence |
| State | Riverpod (already in app) | Providers become `FutureProvider`/async |
| Images | Keep picsum placeholder URLs for now | Storage bucket is a later phase |

## Database schema

```sql
-- enum matching app/lib/domain/models/category.dart (minus 'home' = ALL filter)
create type place_category as enum
  ('food','nature','beach','hotels','temples','shopping');

create table public.profiles (          -- 1:1 with auth.users
  id uuid primary key references auth.users on delete cascade,
  name text not null,
  email text not null,
  created_at timestamptz not null default now()
);

create table public.places (
  id text primary key,                  -- keep slug ids: 'ministry-of-crab'
  name text not null,
  category place_category not null,
  district text not null,
  latitude double precision not null,
  longitude double precision not null,
  rating numeric(2,1) not null default 0,      -- maintained by trigger
  review_count int not null default 0,         -- maintained by trigger
  description text not null,
  image_url text not null,
  trending boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.reviews (
  id uuid primary key default gen_random_uuid(),
  place_id text not null references public.places on delete cascade,
  user_id uuid not null references public.profiles on delete cascade,
  author_name text not null,            -- denormalized for fast display
  rating int not null check (rating between 1 and 5),
  text text not null check (char_length(text) >= 10),
  photo_urls text[] not null default '{}',       -- up to 3 review photos
  created_at timestamptz not null default now()
);
create index on public.reviews (place_id, created_at desc);
create index on public.reviews (user_id, created_at desc);
```

Phase 1 moderation additions (2026-07-22):
```sql
alter table public.profiles
  add column role text not null default 'user'
    check (role in ('user', 'admin'));

create table public.reports (
  id uuid primary key default gen_random_uuid(),
  review_id uuid not null references public.reviews on delete cascade,
  reporter_id uuid not null references public.profiles on delete cascade,
  reason text not null check (reason in ('spam', 'inappropriate', 'fake', 'other')),
  note text,
  status text not null default 'open' check (status in ('open', 'actioned', 'dismissed')),
  created_at timestamptz not null default now()
);
create index on public.reports (status, created_at desc);
```

Plus:
- **Trigger** on `reviews` (insert/delete/update) → recompute `places.rating`
  (avg, 1 decimal) and `places.review_count`.
- **Trigger** on `auth.users` insert → auto-create `profiles` row from signup
  metadata (standard Supabase pattern).
- **RLS policies:** places readable by everyone, writable by no one (admin/MCP
  seeds them); reviews readable by everyone, insertable only with
  `auth.uid() = user_id`; profiles readable by all, updatable only by owner.
- **Seed migration:** insert the 18 places from
  `app/lib/data/sample/sample_data.dart` (sample reviews need real user ids, so
  reviews start empty / or seed after creating a demo user).

## Implementation steps

### Phase 0 — housekeeping
1. New daily branch: `2026-06-11-supabase-backend` (per user's branch convention).

### Phase 1 — Supabase project (via MCP)
2. Create Supabase project (confirm cost — free tier), get project URL + publishable (anon) key.
3. Apply migrations: enum, tables, triggers, RLS policies, place seed data.
4. Run `get_advisors` to check for security warnings.

### Phase 2 — Flutter wiring
5. Add `supabase_flutter` to `app/pubspec.yaml`.
6. `Supabase.initialize(url, anonKey)` in `app/lib/main.dart` before `runApp`
   (anon key is safe to ship in-app; RLS is the security boundary). Keys go in
   `app/lib/core/supabase_config.dart` (or `--dart-define` if user prefers).
7. New data layer `app/lib/data/supabase/`:
   - `supabase_auth_repository.dart` — implements `AuthRepository`:
     `signIn` → `auth.signInWithPassword`, plus **add `signUp`** to the interface
     (sample auth had no real signup); `signOut` → `auth.signOut`.
   - `supabase_places_repository.dart` — implements `PlacesRepository`:
     `fetchAll/byCategory/trending/byId`, `search` via `ilike` on name/district.
   - `supabase_reviews_repository.dart` — implements `ReviewsRepository`:
     `fetchForPlace` (newest first), `fetchByUser` (switch from author-name to
     `user_id`), `add` inserts with current `auth.uid()`.
   - `fromJson` mappers on the three domain models (or small DTOs in data layer).
8. Swap the three providers in `app/lib/application/repository_providers.dart`.
9. Make repository interfaces async (`Future<...>`) if not already; convert the
   places/reviews providers to `FutureProvider` and give list screens
   loading/error states (Riverpod `AsyncValue.when`).

### Phase 3 — Auth flow updates
10. Login screen: real errors ("invalid credentials"), loading spinner, and a
    **Sign up** toggle (name + email + password) since accounts are real now.
11. Session persistence: on splash, check `Supabase.instance.client.auth.currentSession`
    → skip login if already signed in. Profile screen sign-out calls real signOut.
12. "My reviews" on profile filters by `user_id` instead of author name.

### Phase 4 — verify + document
13. Run on the Samsung tab (R83X201SG1Z): sign up → browse seeded places →
    write a review → see rating/count update → sign out/in → review persists.
    Cross-check rows via MCP `execute_sql`.
14. Update READMEs with backend architecture + new tech stack (user's standing
    rule before any push).

## Critical files

- `app/lib/application/repository_providers.dart` — the swap point
- `app/lib/domain/repositories/{places,reviews,auth}_repository.dart` — interfaces (make async, add signUp)
- `app/lib/data/supabase/` — new repository implementations (3 files + config)
- `app/lib/main.dart` — Supabase.initialize
- `app/lib/presentation/screens/login/login_screen.dart` — real auth + signup UI
- `app/pubspec.yaml` — add supabase_flutter
- `app/lib/data/sample/sample_data.dart` — source for seed migration (kept as offline fallback)

## Out of scope (future phases)

- Real photos via Supabase Storage (replace picsum URLs)
- Google Sign-In, favorites/bookmarks, edit/delete own reviews, admin panel for adding places

## Verification

- `flutter analyze` clean; app builds and runs on device
- End-to-end on the tab: signup → login → data loads from cloud → review submit → rating recomputes (trigger) → persists across restart
- MCP `get_advisors` shows no RLS/security errors; `execute_sql` confirms seeded + user-written rows

---

## Live deployment status (2026-06-11)

- **Supabase project:** `ceylonreview` (ref `jrepeqykdgsckrlvujnt`), region `ap-south-1`, free tier ($0/month)
- **API URL:** `https://jrepeqykdgsckrlvujnt.supabase.co`
- **Migrations applied:** `create_core_schema`, `seed_places` (18 places), `lock_down_trigger_functions`
- **Security advisors:** 0 warnings
