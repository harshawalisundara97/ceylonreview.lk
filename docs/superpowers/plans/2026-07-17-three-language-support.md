# Three-Language Support (en/si/ta) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Localize every static UI string into English, Sinhala, and Tamil with an in-app, persisted language picker.

**Architecture:** Flutter's official gen-l10n workflow (ARB files → generated `AppLocalizations`), a Riverpod `Notifier<Locale?>` persisted via `shared_preferences` (null = follow device), and a shared `LanguagePicker` sheet reachable from Profile and Login. Migration of the ~120 hardcoded strings happens screen-cluster by screen-cluster in mechanical tasks after the scaffolding lands.

**Tech Stack:** Flutter (Dart SDK ^3.6.1), flutter_localizations (SDK), intl, shared_preferences, Riverpod, flutter_test.

Spec: `docs/superpowers/specs/2026-07-17-three-language-support-design.md`

## Global Constraints

- Exactly three locales: `en` (template + fallback), `si`, `ta`. No others.
- Official gen-l10n only — do NOT add `easy_localization` or any other l10n package.
- Generated output goes to `app/lib/l10n/generated/` (`synthetic-package: false`, `nullable-getter: false`). Never edit generated files; never commit changes to them by hand.
- Widgets access strings ONLY via the `context.l10n` extension (defined in Task 1) — no direct `AppLocalizations.of(context)` at call sites.
- Brand name "Ceylon Review" stays untranslated in all locales.
- NOT translated: user-generated content (place names, descriptions, reviews), district names in the Add Place dropdown, category values stored in the DB (display labels ARE translated).
- The default test locale is `en`, so existing English `find.text(...)` assertions keep passing; do not rewrite existing tests to Sinhala/Tamil.
- All commands below run from `app/`. After every task: `flutter analyze` clean and `flutter test` fully green before committing.
- Test file `test/ceylon_review_test.dart` contains intentional global `HttpOverrides` scaffolding at the top — do not remove or rescope it.

---

### Task 1: gen-l10n scaffolding + complete ARB files

**Files:**
- Modify: `app/pubspec.yaml`
- Create: `app/l10n.yaml`
- Create: `app/lib/l10n/app_en.arb`, `app/lib/l10n/app_si.arb`, `app/lib/l10n/app_ta.arb`
- Create: `app/lib/core/l10n_ext.dart`
- Modify: `app/lib/main.dart` (delegates + supportedLocales only; `locale:` comes in Task 2)
- Modify: `app/test/ceylon_review_test.dart` (the `themed(...)` helper near line 559)

**Interfaces:**
- Consumes: nothing.
- Produces: generated class `AppLocalizations` at `app/lib/l10n/generated/app_localizations.dart`; extension getter `context.l10n` returning `AppLocalizations` (from `app/lib/core/l10n_ext.dart`). Every later task uses `context.l10n.<key>` with the exact key names in the ARB below.

- [ ] **Step 1: Add dependencies and enable generation**

In `app/pubspec.yaml` add under `dependencies:`:

```yaml
  flutter_localizations:
    sdk: flutter
  intl: any
```

(`intl: any` lets the Flutter SDK pin its own compatible version.) Under the top-level `flutter:` section add:

```yaml
  generate: true
```

- [ ] **Step 2: Create `app/l10n.yaml`**

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-dir: lib/l10n/generated
synthetic-package: false
nullable-getter: false
```

- [ ] **Step 3: Create the three ARB files**

`app/lib/l10n/app_en.arb` — the template. Full content:

```json
{
  "@@locale": "en",
  "appTitle": "Ceylon Review",
  "tagline": "Places you'll love, across the island",
  "navHome": "Home",
  "navMap": "Map",
  "navRanks": "Ranks",
  "navPost": "Post",
  "navFeed": "Feed",
  "navProfile": "Profile",
  "name": "Name",
  "email": "Email",
  "password": "Password",
  "enterYourName": "Enter your name",
  "enterValidEmail": "Enter a valid email",
  "passwordMin6": "Password must be at least 6 characters",
  "explore": "Explore",
  "createAccount": "Create account",
  "alreadyHaveAccountSignIn": "Already have an account? Sign in",
  "newHereCreateAccount": "New here? Create an account",
  "forgotPassword": "Forgot password?",
  "accountCreatedCheckEmail": "Account created! Check your email to confirm, then sign in.",
  "genericConnectionError": "Something went wrong. Check your connection and try again.",
  "resetYourPassword": "Reset your password",
  "sendResetLink": "Send reset link",
  "cancel": "Cancel",
  "checkYourEmail": "Check your email",
  "resetLinkSent": "If an account exists for {email}, a reset link is on its way.",
  "@resetLinkSent": {"placeholders": {"email": {"type": "String"}}},
  "done": "Done",
  "setNewPassword": "Set a new password",
  "newPassword": "New password",
  "confirmPassword": "Confirm password",
  "passwordsDontMatch": "Passwords don't match",
  "updatePassword": "Update password",
  "couldNotUpdatePassword": "Could not update your password. Try again.",
  "discoverSriLanka": "DISCOVER SRI LANKA",
  "ayubowan": "Ayubowan!",
  "ayubowanUser": "Ayubowan, {name}!",
  "@ayubowanUser": {"placeholders": {"name": {"type": "String"}}},
  "whereToNext": "Where to next in Sri Lanka?",
  "searchHint": "Search places, beaches, food…",
  "trendingThisWeek": "Trending This Week",
  "couldNotLoadPlaces": "Could not load places.",
  "pullToRefreshError": "Something went wrong. Pull to refresh.",
  "noPlacesFound": "No places found for \"{query}\"",
  "@noPlacesFound": {"placeholders": {"query": {"type": "String"}}},
  "community": "COMMUNITY",
  "filters": "Filters",
  "sortBy": "Sort by",
  "price": "Price",
  "priceLevel": "Price level",
  "openNow": "Open now",
  "closed": "Closed",
  "opensTime": "Opens {time}",
  "@opensTime": {"placeholders": {"time": {"type": "String"}}},
  "closesTime": "Closes {time}",
  "@closesTime": {"placeholders": {"time": {"type": "String"}}},
  "reset": "Reset",
  "apply": "Apply",
  "reviews": "Reviews",
  "photos": "Photos",
  "hours": "Hours",
  "getDirections": "Get Directions",
  "directionsOpenInMapTab": "Directions open in the Map tab.",
  "writeAReview": "Write a Review",
  "couldNotLoadThisPlace": "Could not load this place.",
  "couldNotLoadReviews": "Could not load reviews.",
  "noReviewsYetBeFirst": "No reviews yet — be the first to share your visit!",
  "nReviews": "{count} reviews",
  "@nReviews": {"placeholders": {"count": {"type": "String"}}},
  "youRated": "You: {rating}★",
  "@youRated": {"placeholders": {"rating": {"type": "String"}}},
  "viewPlace": "View Place",
  "place": "Place",
  "chooseAPlace": "Choose a place",
  "chooseAPlaceToReview": "Choose a place to review.",
  "yourRating": "Your rating",
  "tapStarsToRate": "Tap the stars to rate your visit.",
  "yourReview": "Your review",
  "shareWhatYouLoved": "Share what you loved — the food, the views, the welcome…",
  "tellUsMore": "Tell us a little more — at least 10 characters.",
  "addPhotosOptional": "Add photos (optional, up to 3)",
  "camera": "Camera",
  "gallery": "Gallery",
  "postReview": "Post Review",
  "reviewPostedThankYou": "Review posted. Thank you!",
  "thisPlaceNoLongerExists": "This place no longer exists.",
  "addAPlace": "Add a Place",
  "addPlace": "Add Place",
  "nameRequired": "Name is required",
  "category": "Category",
  "pickACategory": "Pick a category.",
  "district": "District",
  "chooseADistrict": "Choose a district",
  "districtRequired": "District is required",
  "descriptionOptional": "Description (optional)",
  "photoOptional": "Photo (optional)",
  "locationTapMap": "Location — tap the map or use your position",
  "searchTownOrLandmark": "Search a town or landmark",
  "searchExampleHint": "e.g. Ella, Galle Fort",
  "useMyCurrentLocation": "Use my current location",
  "enableLocationToUse": "Enable location to use your position.",
  "dropAPin": "Drop a pin for the location.",
  "openingHoursOptional": "Opening hours (optional)",
  "opensAt": "Opens at",
  "closesAt": "Closes at",
  "couldNotAddPlace": "Could not add the place. Please try again.",
  "leaderboard": "Leaderboard",
  "couldNotLoadLeaderboard": "Could not load the leaderboard.",
  "nPts": "{points} pts",
  "@nPts": {"placeholders": {"points": {"type": "String"}}},
  "ptsToReach": "{points} pts to reach #{rank}",
  "@ptsToReach": {"placeholders": {"points": {"type": "String"}, "rank": {"type": "String"}}},
  "darkMode": "Dark Mode",
  "language": "Language",
  "systemDefault": "System default",
  "yourReviews": "Your Reviews",
  "yourFavorites": "Your Favorites",
  "couldNotLoadYourReviews": "Could not load your reviews.",
  "couldNotLoadYourFavorites": "Could not load your favorites.",
  "noReviewsYetVisit": "No reviews yet. Visit a place and share your experience!",
  "signOut": "Sign Out",
  "map": "Map",
  "couldNotLoadMap": "Could not load the map.",
  "categoryAll": "All",
  "categoryAllPlaces": "All Places",
  "categoryFood": "Food",
  "categoryNature": "Nature",
  "categoryBeaches": "Beaches",
  "categoryHotels": "Hotels",
  "categoryTemples": "Temples",
  "categoryShopping": "Shopping"
}
```

`app/lib/l10n/app_si.arb` — same keys, Sinhala values (no `@` metadata needed in non-template files):

```json
{
  "@@locale": "si",
  "appTitle": "Ceylon Review",
  "tagline": "දිවයින පුරා ඔබ ප්‍රිය කරන ස්ථාන",
  "navHome": "මුල් පිටුව",
  "navMap": "සිතියම",
  "navRanks": "ශ්‍රේණි",
  "navPost": "පළ කරන්න",
  "navFeed": "ෆීඩ්",
  "navProfile": "පැතිකඩ",
  "name": "නම",
  "email": "විද්‍යුත් තැපෑල",
  "password": "මුරපදය",
  "enterYourName": "ඔබේ නම ඇතුළත් කරන්න",
  "enterValidEmail": "වලංගු විද්‍යුත් තැපෑලක් ඇතුළත් කරන්න",
  "passwordMin6": "මුරපදය අවම වශයෙන් අක්ෂර 6ක් විය යුතුය",
  "explore": "ගවේෂණය කරන්න",
  "createAccount": "ගිණුමක් සාදන්න",
  "alreadyHaveAccountSignIn": "දැනටමත් ගිණුමක් තිබේද? පුරන්න",
  "newHereCreateAccount": "අලුත්ද? ගිණුමක් සාදන්න",
  "forgotPassword": "මුරපදය අමතකද?",
  "accountCreatedCheckEmail": "ගිණුම සෑදුවා! තහවුරු කිරීමට ඔබේ විද්‍යුත් තැපෑල බලා, පසුව පුරන්න.",
  "genericConnectionError": "යමක් වැරදුණා. සම්බන්ධතාවය පරීක්ෂා කර නැවත උත්සාහ කරන්න.",
  "resetYourPassword": "මුරපදය යළි සකසන්න",
  "sendResetLink": "යළි සැකසීමේ සබැඳිය යවන්න",
  "cancel": "අවලංගු කරන්න",
  "checkYourEmail": "ඔබේ විද්‍යුත් තැපෑල බලන්න",
  "resetLinkSent": "{email} සඳහා ගිණුමක් තිබේ නම්, යළි සැකසීමේ සබැඳියක් එවා ඇත.",
  "done": "හරි",
  "setNewPassword": "නව මුරපදයක් සකසන්න",
  "newPassword": "නව මුරපදය",
  "confirmPassword": "මුරපදය තහවුරු කරන්න",
  "passwordsDontMatch": "මුරපද නොගැලපේ",
  "updatePassword": "මුරපදය යාවත්කාලීන කරන්න",
  "couldNotUpdatePassword": "මුරපදය යාවත්කාලීන කළ නොහැකි විය. නැවත උත්සාහ කරන්න.",
  "discoverSriLanka": "ශ්‍රී ලංකාව සොයා යන්න",
  "ayubowan": "ආයුබෝවන්!",
  "ayubowanUser": "ආයුබෝවන්, {name}!",
  "whereToNext": "ශ්‍රී ලංකාවේ ඊළඟට කොහෙද?",
  "searchHint": "ස්ථාන, වෙරළ, කෑම සොයන්න…",
  "trendingThisWeek": "මේ සතියේ ජනප්‍රිය",
  "couldNotLoadPlaces": "ස්ථාන පූරණය කළ නොහැකි විය.",
  "pullToRefreshError": "යමක් වැරදුණා. නැවුම් කිරීමට පහළට අදින්න.",
  "noPlacesFound": "\"{query}\" සඳහා ස්ථාන හමු නොවීය",
  "community": "ප්‍රජාව",
  "filters": "පෙරහන්",
  "sortBy": "අනුපිළිවෙල",
  "price": "මිල",
  "priceLevel": "මිල මට්ටම",
  "openNow": "දැන් විවෘතයි",
  "closed": "වසා ඇත",
  "opensTime": "{time} ට විවෘත වේ",
  "closesTime": "{time} ට වැසේ",
  "reset": "යළි සකසන්න",
  "apply": "යොදන්න",
  "reviews": "සමාලෝචන",
  "photos": "ඡායාරූප",
  "hours": "වේලාවන්",
  "getDirections": "මාර්ග උපදෙස්",
  "directionsOpenInMapTab": "මාර්ග උපදෙස් සිතියම් පටිත්තෙන් විවෘත වේ.",
  "writeAReview": "සමාලෝචනයක් ලියන්න",
  "couldNotLoadThisPlace": "මෙම ස්ථානය පූරණය කළ නොහැකි විය.",
  "couldNotLoadReviews": "සමාලෝචන පූරණය කළ නොහැකි විය.",
  "noReviewsYetBeFirst": "තවම සමාලෝචන නැත — ඔබේ සංචාරය බෙදාගන්නා පළමුවැන්නා වන්න!",
  "nReviews": "සමාලෝචන {count}",
  "youRated": "ඔබ: {rating}★",
  "viewPlace": "ස්ථානය බලන්න",
  "place": "ස්ථානය",
  "chooseAPlace": "ස්ථානයක් තෝරන්න",
  "chooseAPlaceToReview": "සමාලෝචනය කිරීමට ස්ථානයක් තෝරන්න.",
  "yourRating": "ඔබේ ශ්‍රේණිගත කිරීම",
  "tapStarsToRate": "ඔබේ සංචාරය ශ්‍රේණිගත කිරීමට තරු ස්පර්ශ කරන්න.",
  "yourReview": "ඔබේ සමාලෝචනය",
  "shareWhatYouLoved": "ඔබ ප්‍රිය කළ දේ බෙදාගන්න — කෑම, දර්ශන, පිළිගැනීම…",
  "tellUsMore": "තව ටිකක් කියන්න — අවම වශයෙන් අක්ෂර 10ක්.",
  "addPhotosOptional": "ඡායාරූප එක් කරන්න (අත්‍යවශ්‍ය නොවේ, උපරිම 3)",
  "camera": "කැමරාව",
  "gallery": "ගැලරිය",
  "postReview": "සමාලෝචනය පළ කරන්න",
  "reviewPostedThankYou": "සමාලෝචනය පළ විය. ස්තූතියි!",
  "thisPlaceNoLongerExists": "මෙම ස්ථානය තවදුරටත් නොපවතී.",
  "addAPlace": "ස්ථානයක් එක් කරන්න",
  "addPlace": "ස්ථානය එක් කරන්න",
  "nameRequired": "නම අවශ්‍යයි",
  "category": "වර්ගය",
  "pickACategory": "වර්ගයක් තෝරන්න.",
  "district": "දිස්ත්‍රික්කය",
  "chooseADistrict": "දිස්ත්‍රික්කයක් තෝරන්න",
  "districtRequired": "දිස්ත්‍රික්කය අවශ්‍යයි",
  "descriptionOptional": "විස්තරය (අත්‍යවශ්‍ය නොවේ)",
  "photoOptional": "ඡායාරූපය (අත්‍යවශ්‍ය නොවේ)",
  "locationTapMap": "පිහිටීම — සිතියම ස්පර්ශ කරන්න හෝ ඔබේ පිහිටීම භාවිතා කරන්න",
  "searchTownOrLandmark": "නගරයක් හෝ ස්ථානයක් සොයන්න",
  "searchExampleHint": "උදා: ඇල්ල, ගාලු කොටුව",
  "useMyCurrentLocation": "මගේ වත්මන් පිහිටීම භාවිතා කරන්න",
  "enableLocationToUse": "ඔබේ පිහිටීම භාවිතා කිරීමට ස්ථාන සේවාව සක්‍රීය කරන්න.",
  "dropAPin": "පිහිටීම සඳහා පින් එකක් තබන්න.",
  "openingHoursOptional": "විවෘත වේලාවන් (අත්‍යවශ්‍ය නොවේ)",
  "opensAt": "විවෘත වන වේලාව",
  "closesAt": "වැසෙන වේලාව",
  "couldNotAddPlace": "ස්ථානය එක් කළ නොහැකි විය. නැවත උත්සාහ කරන්න.",
  "leaderboard": "ප්‍රමුඛ ලැයිස්තුව",
  "couldNotLoadLeaderboard": "ප්‍රමුඛ ලැයිස්තුව පූරණය කළ නොහැකි විය.",
  "nPts": "ලකුණු {points}",
  "ptsToReach": "#{rank} වෙත ළඟා වීමට ලකුණු {points}",
  "darkMode": "අඳුරු තේමාව",
  "language": "භාෂාව",
  "systemDefault": "පද්ධති නිතිය",
  "yourReviews": "ඔබේ සමාලෝචන",
  "yourFavorites": "ඔබේ ප්‍රියතම",
  "couldNotLoadYourReviews": "ඔබේ සමාලෝචන පූරණය කළ නොහැකි විය.",
  "couldNotLoadYourFavorites": "ඔබේ ප්‍රියතම පූරණය කළ නොහැකි විය.",
  "noReviewsYetVisit": "තවම සමාලෝචන නැත. ස්ථානයකට ගොස් ඔබේ අත්දැකීම බෙදාගන්න!",
  "signOut": "වරන්න",
  "map": "සිතියම",
  "couldNotLoadMap": "සිතියම පූරණය කළ නොහැකි විය.",
  "categoryAll": "සියල්ල",
  "categoryAllPlaces": "සියලු ස්ථාන",
  "categoryFood": "කෑම",
  "categoryNature": "සොබාදහම",
  "categoryBeaches": "වෙරළ",
  "categoryHotels": "හෝටල්",
  "categoryTemples": "පන්සල්",
  "categoryShopping": "සාප්පු"
}
```

`app/lib/l10n/app_ta.arb` — same keys, Tamil values:

```json
{
  "@@locale": "ta",
  "appTitle": "Ceylon Review",
  "tagline": "தீவு முழுவதும் நீங்கள் விரும்பும் இடங்கள்",
  "navHome": "முகப்பு",
  "navMap": "வரைபடம்",
  "navRanks": "தரவரிசை",
  "navPost": "பதிவிடு",
  "navFeed": "ஃபீடு",
  "navProfile": "சுயவிவரம்",
  "name": "பெயர்",
  "email": "மின்னஞ்சல்",
  "password": "கடவுச்சொல்",
  "enterYourName": "உங்கள் பெயரை உள்ளிடவும்",
  "enterValidEmail": "சரியான மின்னஞ்சலை உள்ளிடவும்",
  "passwordMin6": "கடவுச்சொல் குறைந்தது 6 எழுத்துகள் இருக்க வேண்டும்",
  "explore": "ஆராயுங்கள்",
  "createAccount": "கணக்கை உருவாக்கவும்",
  "alreadyHaveAccountSignIn": "ஏற்கனவே கணக்கு உள்ளதா? உள்நுழையவும்",
  "newHereCreateAccount": "புதியவரா? கணக்கை உருவாக்கவும்",
  "forgotPassword": "கடவுச்சொல் மறந்துவிட்டதா?",
  "accountCreatedCheckEmail": "கணக்கு உருவாக்கப்பட்டது! உறுதிப்படுத்த உங்கள் மின்னஞ்சலைப் பார்த்து, பின் உள்நுழையவும்.",
  "genericConnectionError": "ஏதோ தவறு நடந்தது. இணைப்பைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.",
  "resetYourPassword": "கடவுச்சொல்லை மீட்டமைக்கவும்",
  "sendResetLink": "மீட்டமைப்பு இணைப்பை அனுப்பவும்",
  "cancel": "ரத்துசெய்",
  "checkYourEmail": "உங்கள் மின்னஞ்சலைப் பார்க்கவும்",
  "resetLinkSent": "{email} க்கு கணக்கு இருந்தால், மீட்டமைப்பு இணைப்பு அனுப்பப்பட்டுள்ளது.",
  "done": "முடிந்தது",
  "setNewPassword": "புதிய கடவுச்சொல்லை அமைக்கவும்",
  "newPassword": "புதிய கடவுச்சொல்",
  "confirmPassword": "கடவுச்சொல்லை உறுதிப்படுத்தவும்",
  "passwordsDontMatch": "கடவுச்சொற்கள் பொருந்தவில்லை",
  "updatePassword": "கடவுச்சொல்லைப் புதுப்பிக்கவும்",
  "couldNotUpdatePassword": "கடவுச்சொல்லைப் புதுப்பிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.",
  "discoverSriLanka": "இலங்கையைக் கண்டறியுங்கள்",
  "ayubowan": "வணக்கம்!",
  "ayubowanUser": "வணக்கம், {name}!",
  "whereToNext": "இலங்கையில் அடுத்து எங்கே?",
  "searchHint": "இடங்கள், கடற்கரைகள், உணவு தேடுங்கள்…",
  "trendingThisWeek": "இந்த வாரம் பிரபலமானவை",
  "couldNotLoadPlaces": "இடங்களை ஏற்ற முடியவில்லை.",
  "pullToRefreshError": "ஏதோ தவறு நடந்தது. புதுப்பிக்க கீழே இழுக்கவும்.",
  "noPlacesFound": "\"{query}\" க்கு இடங்கள் கிடைக்கவில்லை",
  "community": "சமூகம்",
  "filters": "வடிப்பான்கள்",
  "sortBy": "வரிசைப்படுத்து",
  "price": "விலை",
  "priceLevel": "விலை நிலை",
  "openNow": "இப்போது திறந்துள்ளது",
  "closed": "மூடப்பட்டுள்ளது",
  "opensTime": "{time} க்கு திறக்கும்",
  "closesTime": "{time} க்கு மூடும்",
  "reset": "மீட்டமை",
  "apply": "பயன்படுத்து",
  "reviews": "விமர்சனங்கள்",
  "photos": "புகைப்படங்கள்",
  "hours": "நேரங்கள்",
  "getDirections": "வழிகாட்டுதல்",
  "directionsOpenInMapTab": "வழிகாட்டுதல் வரைபடத் தாவலில் திறக்கும்.",
  "writeAReview": "விமர்சனம் எழுதுங்கள்",
  "couldNotLoadThisPlace": "இந்த இடத்தை ஏற்ற முடியவில்லை.",
  "couldNotLoadReviews": "விமர்சனங்களை ஏற்ற முடியவில்லை.",
  "noReviewsYetBeFirst": "இன்னும் விமர்சனங்கள் இல்லை — உங்கள் வருகையைப் பகிரும் முதல் நபராகுங்கள்!",
  "nReviews": "{count} விமர்சனங்கள்",
  "youRated": "நீங்கள்: {rating}★",
  "viewPlace": "இடத்தைப் பார்க்கவும்",
  "place": "இடம்",
  "chooseAPlace": "ஒரு இடத்தைத் தேர்ந்தெடுக்கவும்",
  "chooseAPlaceToReview": "விமர்சிக்க ஒரு இடத்தைத் தேர்ந்தெடுக்கவும்.",
  "yourRating": "உங்கள் மதிப்பீடு",
  "tapStarsToRate": "உங்கள் வருகையை மதிப்பிட நட்சத்திரங்களைத் தட்டவும்.",
  "yourReview": "உங்கள் விமர்சனம்",
  "shareWhatYouLoved": "நீங்கள் விரும்பியதைப் பகிருங்கள் — உணவு, காட்சிகள், வரவேற்பு…",
  "tellUsMore": "இன்னும் கொஞ்சம் சொல்லுங்கள் — குறைந்தது 10 எழுத்துகள்.",
  "addPhotosOptional": "புகைப்படங்களைச் சேர்க்கவும் (விருப்பம், அதிகபட்சம் 3)",
  "camera": "கேமரா",
  "gallery": "கேலரி",
  "postReview": "விமர்சனத்தைப் பதிவிடு",
  "reviewPostedThankYou": "விமர்சனம் பதிவிடப்பட்டது. நன்றி!",
  "thisPlaceNoLongerExists": "இந்த இடம் இப்போது இல்லை.",
  "addAPlace": "இடத்தைச் சேர்க்கவும்",
  "addPlace": "இடம் சேர்",
  "nameRequired": "பெயர் தேவை",
  "category": "வகை",
  "pickACategory": "ஒரு வகையைத் தேர்ந்தெடுக்கவும்.",
  "district": "மாவட்டம்",
  "chooseADistrict": "ஒரு மாவட்டத்தைத் தேர்ந்தெடுக்கவும்",
  "districtRequired": "மாவட்டம் தேவை",
  "descriptionOptional": "விளக்கம் (விருப்பம்)",
  "photoOptional": "புகைப்படம் (விருப்பம்)",
  "locationTapMap": "இடம் — வரைபடத்தைத் தட்டவும் அல்லது உங்கள் இருப்பிடத்தைப் பயன்படுத்தவும்",
  "searchTownOrLandmark": "ஊர் அல்லது அடையாள இடத்தைத் தேடுங்கள்",
  "searchExampleHint": "எ.கா: எல்ல, காலி கோட்டை",
  "useMyCurrentLocation": "என் தற்போதைய இருப்பிடத்தைப் பயன்படுத்து",
  "enableLocationToUse": "உங்கள் இருப்பிடத்தைப் பயன்படுத்த இருப்பிடச் சேவையை இயக்கவும்.",
  "dropAPin": "இடத்திற்காக ஒரு பின்னை வைக்கவும்.",
  "openingHoursOptional": "திறக்கும் நேரங்கள் (விருப்பம்)",
  "opensAt": "திறக்கும் நேரம்",
  "closesAt": "மூடும் நேரம்",
  "couldNotAddPlace": "இடத்தைச் சேர்க்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.",
  "leaderboard": "தரவரிசைப் பட்டியல்",
  "couldNotLoadLeaderboard": "தரவரிசைப் பட்டியலை ஏற்ற முடியவில்லை.",
  "nPts": "{points} புள்ளிகள்",
  "ptsToReach": "#{rank} ஐ அடைய {points} புள்ளிகள்",
  "darkMode": "இருண்ட பயன்முறை",
  "language": "மொழி",
  "systemDefault": "கணினி இயல்புநிலை",
  "yourReviews": "உங்கள் விமர்சனங்கள்",
  "yourFavorites": "உங்கள் பிடித்தவை",
  "couldNotLoadYourReviews": "உங்கள் விமர்சனங்களை ஏற்ற முடியவில்லை.",
  "couldNotLoadYourFavorites": "உங்கள் பிடித்தவற்றை ஏற்ற முடியவில்லை.",
  "noReviewsYetVisit": "இன்னும் விமர்சனங்கள் இல்லை. ஒரு இடத்திற்குச் சென்று உங்கள் அனுபவத்தைப் பகிருங்கள்!",
  "signOut": "வெளியேறு",
  "map": "வரைபடம்",
  "couldNotLoadMap": "வரைபடத்தை ஏற்ற முடியவில்லை.",
  "categoryAll": "அனைத்தும்",
  "categoryAllPlaces": "அனைத்து இடங்களும்",
  "categoryFood": "உணவு",
  "categoryNature": "இயற்கை",
  "categoryBeaches": "கடற்கரைகள்",
  "categoryHotels": "ஹோட்டல்கள்",
  "categoryTemples": "கோவில்கள்",
  "categoryShopping": "கடைத்தொகுப்பு"
}
```

- [ ] **Step 4: Generate and create the `context.l10n` extension**

Run: `flutter pub get && flutter gen-l10n`
Expected: `lib/l10n/generated/app_localizations.dart` (plus `_en/_si/_ta` files) created, no errors.

Create `app/lib/core/l10n_ext.dart`:

```dart
import 'package:flutter/widgets.dart';

import '../l10n/generated/app_localizations.dart';

export '../l10n/generated/app_localizations.dart' show AppLocalizations;

/// Shorthand for the generated localizations: `context.l10n.someKey`.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
```

- [ ] **Step 5: Wire delegates into `MaterialApp`**

In `app/lib/main.dart`, add import `import 'core/l10n_ext.dart';` and inside the `MaterialApp(...)` (after `title:`):

```dart
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
```

- [ ] **Step 6: Write a failing-then-passing localization smoke test**

Append to `test/ceylon_review_test.dart` a new group:

```dart
group('Localization', () {
  testWidgets('resolves Sinhala and Tamil strings', (tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('si'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(builder: (context) => Text(context.l10n.language)),
    ));
    await tester.pumpAndSettle();
    expect(find.text('භාෂාව'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ta'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(builder: (context) => Text(context.l10n.language)),
    ));
    await tester.pumpAndSettle();
    expect(find.text('மொழி'), findsOneWidget);
  });
});
```

Add the import `import 'package:app/core/l10n_ext.dart';` using the same package prefix the test file already uses for other app imports (check its existing imports and match them exactly).

- [ ] **Step 7: Update the shared `themed(...)` test helper**

In `test/ceylon_review_test.dart`, the `themed(...)` helper (~line 559) wraps widgets in a `MaterialApp`. Add to that `MaterialApp`:

```dart
localizationsDelegates: AppLocalizations.localizationsDelegates,
supportedLocales: AppLocalizations.supportedLocales,
```

so later-migrated widgets resolve `context.l10n` in every existing test.

- [ ] **Step 8: Verify and commit**

Run: `flutter analyze` → no issues. `flutter test` → all pass (existing count + 1 new).

```bash
git add pubspec.yaml pubspec.lock l10n.yaml lib/l10n lib/core/l10n_ext.dart lib/main.dart test/ceylon_review_test.dart
git commit -m "Add gen-l10n scaffolding with en/si/ta ARB files"
```

(Generated files under `lib/l10n/generated/` ARE committed — the repo's CI has no gen step.)

---

### Task 2: Locale provider with persistence

**Files:**
- Modify: `app/pubspec.yaml` (add `shared_preferences: ^2.3.0`)
- Create: `app/lib/application/locale_provider.dart`
- Modify: `app/lib/main.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: nothing from Task 1 at runtime (independent of ARB content).
- Produces: `localeProvider` (`NotifierProvider<LocaleNotifier, Locale?>`) with `Future<void> setLocale(Locale? locale)` — `null` means "system default". Task 3's picker calls `setLocale`; `main.dart` watches it.

- [ ] **Step 1: Write the failing tests**

Append to `test/ceylon_review_test.dart`:

```dart
group('localeProvider', () {
  test('defaults to null and restores persisted locale', () async {
    SharedPreferences.setMockInitialValues({});
    var container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(localeProvider), isNull);

    await container.read(localeProvider.notifier).setLocale(const Locale('si'));
    expect(container.read(localeProvider), const Locale('si'));

    // A fresh container simulates an app restart reading the same prefs.
    container = ProviderContainer();
    addTearDown(container.dispose);
    // Allow the async restore to complete.
    container.read(localeProvider);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(localeProvider), const Locale('si'));
  });

  test('setLocale(null) clears persistence', () async {
    SharedPreferences.setMockInitialValues({'app_locale': 'ta'});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(localeProvider.notifier).setLocale(null);
    expect(container.read(localeProvider), isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_locale'), isNull);
  });
});
```

Imports to add (matching the file's existing prefix style): `shared_preferences.dart` and `application/locale_provider.dart`.

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test --plain-name localeProvider`
Expected: FAIL — `localeProvider` undefined.

- [ ] **Step 3: Implement `locale_provider.dart`**

```dart
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localePrefKey = 'app_locale';
const supportedLanguageCodes = ['en', 'si', 'ta'];

/// The user's chosen app language. `null` means "follow device language".
/// Persisted across launches in [SharedPreferences].
class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    // Restore asynchronously; the first frame renders with the device
    // locale and snaps to the saved one as soon as prefs load.
    SharedPreferences.getInstance().then((prefs) {
      final code = prefs.getString(_localePrefKey);
      if (code != null && supportedLanguageCodes.contains(code)) {
        state = Locale(code);
      }
    });
    return null;
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_localePrefKey);
    } else {
      await prefs.setString(_localePrefKey, locale.languageCode);
    }
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);
```

Add `shared_preferences: ^2.3.0` to `app/pubspec.yaml` dependencies and run `flutter pub get`.

- [ ] **Step 4: Wire into `MaterialApp`**

In `app/lib/main.dart` add `import 'application/locale_provider.dart';`, inside `build()` add `final locale = ref.watch(localeProvider);`, and inside `MaterialApp(...)` add:

```dart
      locale: locale,
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test --plain-name localeProvider` → PASS. Then full `flutter test` → all green, `flutter analyze` → clean.

- [ ] **Step 6: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/application/locale_provider.dart lib/main.dart test/ceylon_review_test.dart
git commit -m "Add persisted localeProvider wired into MaterialApp"
```

---

### Task 3: Language picker (Profile row + Login globe)

**Files:**
- Create: `app/lib/presentation/widgets/language_picker.dart`
- Modify: `app/lib/presentation/screens/profile/profile_screen.dart` (after the Dark Mode `SwitchListTile`, ~line 60-70)
- Modify: `app/lib/presentation/screens/login/login_screen.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: `localeProvider` / `setLocale(Locale?)` from Task 2; `context.l10n.language` and `context.l10n.systemDefault` from Task 1.
- Produces: `showLanguagePicker(BuildContext context)` — a top-level function opening a modal bottom sheet.

- [ ] **Step 1: Write the failing test**

```dart
group('LanguagePicker', () {
  testWidgets('selecting Sinhala updates localeProvider', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showLanguagePicker(context),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('සිංහල'));
    await tester.pumpAndSettle();
    expect(container.read(localeProvider), const Locale('si'));
  });
});
```

- [ ] **Step 2: Run to verify it fails** — `flutter test --plain-name LanguagePicker` → FAIL, `showLanguagePicker` undefined.

- [ ] **Step 3: Implement `language_picker.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/locale_provider.dart';
import '../../core/l10n_ext.dart';

/// Modal sheet listing System default / English / සිංහල / தமிழ், with the
/// active choice checked. Selecting persists via [localeProvider].
Future<void> showLanguagePicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => Consumer(
      builder: (context, ref, _) {
        final current = ref.watch(localeProvider);
        void select(Locale? locale) {
          ref.read(localeProvider.notifier).setLocale(locale);
          Navigator.of(sheetContext).pop();
        }

        Widget option(String label, Locale? locale) => ListTile(
              title: Text(label),
              trailing: current == locale
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () => select(locale),
            );

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  context.l10n.language,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              option(context.l10n.systemDefault, null),
              option('English', const Locale('en')),
              option('සිංහල', const Locale('si')),
              option('தமிழ்', const Locale('ta')),
            ],
          ),
        );
      },
    ),
  );
}
```

- [ ] **Step 4: Add the Profile row**

In `profile_screen.dart`, directly after the Dark Mode `SwitchListTile`, add (with imports for `language_picker.dart` and `l10n_ext.dart`):

```dart
ListTile(
  leading: const Icon(Icons.language_rounded),
  title: Text(context.l10n.language),
  trailing: const Icon(Icons.chevron_right_rounded),
  onTap: () => showLanguagePicker(context),
),
```

Match the surrounding tiles' styling (if Dark Mode's tile uses `secondary:`/padding, mirror it).

- [ ] **Step 5: Add the Login globe button**

In `login_screen.dart`'s `Scaffold`, wrap the existing `SafeArea` body in a `Stack` and add a positioned button (or simpler: give the `Scaffold` an `appBar: AppBar(...)`-free approach by adding to the `Stack`):

```dart
body: SafeArea(
  child: Stack(
    children: [
      Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: IconButton(
            tooltip: context.l10n.language,
            icon: const Icon(Icons.language_rounded),
            onPressed: () => showLanguagePicker(context),
          ),
        ),
      ),
      Center(
        child: SingleChildScrollView(
          // ...existing content unchanged...
        ),
      ),
    ],
  ),
),
```

- [ ] **Step 6: Verify** — `flutter test` all green, `flutter analyze` clean. Manually confirm the sheet lists 4 options with the current one checked.

- [ ] **Step 7: Commit**

```bash
git add lib/presentation/widgets/language_picker.dart lib/presentation/screens/profile/profile_screen.dart lib/presentation/screens/login/login_screen.dart test/ceylon_review_test.dart
git commit -m "Add language picker in Profile and Login"
```

---

### Task 4: Migrate auth screens (login, reset password, splash)

**Files:**
- Modify: `app/lib/presentation/screens/login/login_screen.dart`
- Modify: `app/lib/presentation/screens/login/reset_password_screen.dart`
- Modify: `app/lib/presentation/screens/splash/splash_screen.dart`
- Test: `app/test/ceylon_review_test.dart` (existing tests keep passing; no rewrites)

**Interfaces:**
- Consumes: `context.l10n` (Task 1). All key names below exist in the ARB files.
- Produces: nothing new.

- [ ] **Step 1: Replace every hardcoded string with its key**

Import `../../../core/l10n_ext.dart` in each file. Mapping (literal → `context.l10n.` key):

| Literal | Key |
|---|---|
| `'Ceylon Review'` | `appTitle` |
| `'Places you'll love, across the island'` | `tagline` |
| `'Name'` | `name` |
| `'Enter your name'` | `enterYourName` |
| `'Email'` | `email` |
| `'Enter a valid email'` | `enterValidEmail` |
| `'Password'` | `password` |
| `'Password must be at least 6 characters'` | `passwordMin6` |
| `'Forgot password?'` | `forgotPassword` |
| `'Explore'` | `explore` |
| `'Create account'` | `createAccount` |
| `'Already have an account? Sign in'` | `alreadyHaveAccountSignIn` |
| `'New here? Create an account'` | `newHereCreateAccount` |
| `'Account created! Check your email to confirm, then sign in.'` (the two-part string) | `accountCreatedCheckEmail` |
| `'Something went wrong. Check your connection and try again.'` (two-part, appears in dialog too) | `genericConnectionError` |
| `'Reset your password'` | `resetYourPassword` |
| `'Send reset link'` | `sendResetLink` |
| `'Cancel'` | `cancel` |
| `'Check your email'` | `checkYourEmail` |
| `'If an account exists for $_emailText, …'` | `resetLinkSent(_emailText)` |
| `'Done'` | `done` |
| `'Set a new password'` | `setNewPassword` |
| `'New password'` | `newPassword` |
| `'Confirm password'` | `confirmPassword` |
| `'Passwords don't match'` | `passwordsDontMatch` |
| `'Update password'` | `updatePassword` |
| `'Could not update your password. Try again.'` | `couldNotUpdatePassword` |
| `'DISCOVER SRI LANKA'` (splash) | `discoverSriLanka` |

Notes:
- Validators and `const` decorations lose `const` when they call `context.l10n` — remove only the `const` keywords that stop compiling.
- `_showMessage` calls inside `catch` blocks run after `await`; they already guard with `if (mounted)` — keep that pattern and read `context.l10n` inside the guarded branch.

- [ ] **Step 2: Verify** — `flutter analyze` clean; `flutter test` all green (default locale is `en`, so existing English assertions still match).

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/screens/login lib/presentation/screens/splash
git commit -m "Localize login, reset-password, and splash screens"
```

---

### Task 5: Migrate home/category/map/shell + shared widgets + category labels

**Files:**
- Create: `app/lib/presentation/l10n/category_labels.dart`
- Modify: `app/lib/presentation/shell/app_shell.dart`
- Modify: `app/lib/presentation/screens/home/home_screen.dart`
- Modify: `app/lib/presentation/screens/category/category_screen.dart`
- Modify: `app/lib/presentation/screens/map/map_screen.dart`
- Modify: `app/lib/presentation/widgets/place_card.dart`, `review_tile.dart`, `section_header.dart`, `category_pill_row.dart`, `user_avatar.dart`, `filters_bottom_sheet.dart`

**Interfaces:**
- Consumes: `context.l10n` (Task 1); `PlaceCategory` from `app/lib/domain/models/category.dart` (do NOT modify the domain enum — its `label`/`displayName` getters stay for any non-UI use).
- Produces: extension `PlaceCategoryLabels` with `String localizedLabel(AppLocalizations l10n)` (ALL-CAPS chip style via `.toUpperCase()`) and `String localizedDisplayName(AppLocalizations l10n)`.

- [ ] **Step 1: Create `category_labels.dart`**

```dart
import '../../core/l10n_ext.dart';
import '../../domain/models/category.dart';

/// UI-layer localized names for [PlaceCategory]. The domain enum's English
/// getters remain for non-UI uses; widgets use these instead.
extension PlaceCategoryLabels on PlaceCategory {
  String localizedDisplayName(AppLocalizations l10n) => switch (this) {
        PlaceCategory.home => l10n.categoryAllPlaces,
        PlaceCategory.food => l10n.categoryFood,
        PlaceCategory.nature => l10n.categoryNature,
        PlaceCategory.beach => l10n.categoryBeaches,
        PlaceCategory.hotels => l10n.categoryHotels,
        PlaceCategory.temples => l10n.categoryTemples,
        PlaceCategory.shopping => l10n.categoryShopping,
      };

  /// ALL-CAPS chip/overline style (no-op for Sinhala/Tamil scripts).
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        PlaceCategory.home => l10n.categoryAll.toUpperCase(),
        _ => localizedDisplayName(l10n).toUpperCase(),
      };
}
```

- [ ] **Step 2: Swap category label call sites**

Find every UI use: `grep -rn "\.label\b\|\.displayName\b" lib/presentation/` — replace `category.label` with `category.localizedLabel(context.l10n)` and `category.displayName` with `category.localizedDisplayName(context.l10n)` (import the extension).

- [ ] **Step 3: Replace remaining literals**

Mapping for these files:

| Literal | Key |
|---|---|
| Nav `'Home'`/`'Map'`/`'Ranks'`/`'Post'`/`'Feed'`/`'Profile'` | `navHome`/`navMap`/`navRanks`/`navPost`/`navFeed`/`navProfile` |
| `'Ayubowan…'` greeting | `user != null ? l10n.ayubowanUser(firstName) : l10n.ayubowan` (keep the existing first-name extraction) |
| `'Where to next in Sri Lanka?'` | `whereToNext` |
| `'Search places, beaches, food…'` | `searchHint` |
| `'Trending This Week'` | `trendingThisWeek` |
| `'Could not load places.'` | `couldNotLoadPlaces` |
| `'Something went wrong. Pull to refresh.'` | `pullToRefreshError` |
| `'No places found for "$query"'` | `noPlacesFound(query)` |
| `'COMMUNITY'` / `'· COMMUNITY'` | `community` / `'· ${context.l10n.community}'` |
| `'Filters'` | `filters` |
| `'Sort by'` | `sortBy` |
| `'Price'` | `price` |
| `'Price level'` | `priceLevel` |
| `'Open now'` | `openNow` |
| `'Closed'` | `closed` |
| `'Opens ${_hhmm(...)}'` / `'Closes ${_hhmm(...)}'` | `opensTime(_hhmm(...))` / `closesTime(_hhmm(...))` |
| `'Reset'` | `reset` |
| `'Apply'` | `apply` |
| `'Could not load the map.'` | `couldNotLoadMap` |
| `'${place.reviewCountLabel} reviews'` | `nReviews(place.reviewCountLabel)` |
| `'${place.ratingLabel} · ${place.reviewCountLabel} reviews'` | `'${place.ratingLabel} · ${context.l10n.nReviews(place.reviewCountLabel)}'` |
| `'You: N★'` badge (place_card) | `youRated('$rating')` |
| `'View Place'` | `viewPlace` |

Leave `Key('...')` widget keys, asset paths, and semantic identifiers untouched — only user-visible text migrates.

- [ ] **Step 4: Verify** — `flutter analyze` clean; `flutter test` all green.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation
git commit -m "Localize home, category, map, shell, and shared widgets"
```

---

### Task 6: Migrate place detail, add place, write review

**Files:**
- Modify: `app/lib/presentation/screens/place_detail/place_detail_screen.dart`
- Modify: `app/lib/presentation/screens/add_place/add_place_screen.dart`
- Modify: `app/lib/presentation/screens/write_review/write_review_screen.dart`
- Modify: `app/lib/presentation/widgets/photo_viewer.dart` (only if it has visible strings)

**Interfaces:** Consumes `context.l10n` (Task 1). Produces nothing new.

- [ ] **Step 1: Replace literals per mapping**

| Literal | Key |
|---|---|
| `'Reviews'` | `reviews` |
| `'Photos'` | `photos` |
| `'Hours'` | `hours` |
| `'Get Directions'` | `getDirections` |
| `'Directions open in the Map tab.'` | `directionsOpenInMapTab` |
| `'Write a Review'` | `writeAReview` |
| `'Could not load this place.'` | `couldNotLoadThisPlace` |
| `'Could not load reviews.'` | `couldNotLoadReviews` |
| `'No reviews yet — be the first to share your visit!'` | `noReviewsYetBeFirst` |
| `'Place'` | `place` |
| `'Choose a place'` | `chooseAPlace` |
| `'Choose a place to review.'` | `chooseAPlaceToReview` |
| `'Your rating'` | `yourRating` |
| `'Tap the stars to rate your visit.'` | `tapStarsToRate` |
| `'Your review'` | `yourReview` |
| `'Share what you loved — the food, the views, the welcome…'` | `shareWhatYouLoved` |
| `'Tell us a little more — at least 10 characters.'` | `tellUsMore` |
| `'Add photos (optional, up to 3)'` | `addPhotosOptional` |
| `'Camera'` | `camera` |
| `'Gallery'` | `gallery` |
| `'Post Review'` | `postReview` |
| `'Review posted. Thank you!'` | `reviewPostedThankYou` |
| `'This place no longer exists.'` | `thisPlaceNoLongerExists` |
| `'Add a Place'` | `addAPlace` |
| `'Add Place'` | `addPlace` |
| `'Name'` / `'Name is required'` | `name` / `nameRequired` |
| `'Category'` / `'Pick a category.'` | `category` / `pickACategory` |
| `'District'` / `'Choose a district'` / `'District is required'` | `district` / `chooseADistrict` / `districtRequired` |
| `'Description (optional)'` | `descriptionOptional` |
| `'Photo (optional)'` | `photoOptional` |
| `'Location — tap the map or use your position'` | `locationTapMap` |
| `'Search a town or landmark'` | `searchTownOrLandmark` |
| `'e.g. Ella, Galle Fort'` | `searchExampleHint` |
| `'Use my current location'` | `useMyCurrentLocation` |
| `'Enable location to use your position.'` | `enableLocationToUse` |
| `'Drop a pin for the location.'` | `dropAPin` |
| `'Opening hours (optional)'` | `openingHoursOptional` |
| `'Opens at'` / `'Closes at'` | `opensAt` / `closesAt` |
| `'Opens ${_hhmm(_opensAt)}'` / `'Closes ${_hhmm(_closesAt)}'` | `opensTime(...)` / `closesTime(...)` |
| `'Could not add the place. Please try again.'` | `couldNotAddPlace` |

District VALUES from `sriLankaDistricts` stay English (Global Constraints). If a literal in these files isn't in this table or the ARB, add a new key to ALL THREE ARB files (translate in the same register as neighboring keys), re-run `flutter gen-l10n`, and note it in your report.

- [ ] **Step 2: Verify** — `flutter analyze` clean; `flutter test` all green.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation lib/l10n
git commit -m "Localize place detail, add place, and write review screens"
```

---

### Task 7: Migrate leaderboard + profile

**Files:**
- Modify: `app/lib/presentation/screens/leaderboard/leaderboard_screen.dart`
- Modify: `app/lib/presentation/screens/profile/profile_screen.dart`

**Interfaces:** Consumes `context.l10n` (Task 1). Produces nothing new.

- [ ] **Step 1: Replace literals per mapping**

| Literal | Key |
|---|---|
| `'Leaderboard'` | `leaderboard` |
| `'Could not load the leaderboard.'` | `couldNotLoadLeaderboard` |
| `'${entry.points} pts'` / `'${widget.entry.points} pts'` | `nPts('${entry.points}')` |
| `'$pointsToNext pts to reach #${entry.rank - 1}'` | `ptsToReach('$pointsToNext', '${entry.rank - 1}')` |
| `'Profile'` | `navProfile` |
| `'Dark Mode'` | `darkMode` |
| `'Your Reviews'` | `yourReviews` |
| `'Your Favorites'` | `yourFavorites` |
| `'Could not load your reviews.'` | `couldNotLoadYourReviews` |
| `'Could not load your favorites.'` | `couldNotLoadYourFavorites` |
| `'No reviews yet. Visit a place and share your experience!'` | `noReviewsYetVisit` |
| `'Sign Out'` | `signOut` |

Rank markers like `'#${entry.rank}'` are numeric, not prose — leave as-is. Same rule as Task 6 for any unlisted literal: add the key to all three ARBs.

- [ ] **Step 2: Verify** — `flutter analyze` clean; `flutter test` all green.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation lib/l10n
git commit -m "Localize leaderboard and profile screens"
```

---

### Task 8: Locale-switch tests, final verification, README

**Files:**
- Modify: `app/test/ceylon_review_test.dart`
- Modify: `README.md` and/or `app/README.md` (feature list + tech stack)

**Interfaces:** Consumes everything prior. Produces nothing new.

- [ ] **Step 1: Write the end-to-end locale test**

```dart
group('Locale end-to-end', () {
  testWidgets('login screen renders in Sinhala and Tamil', (tester) async {
    for (final (locale, expected) in [
      (const Locale('si'), 'ගවේෂණය කරන්න'),
      (const Locale('ta'), 'ஆராயுங்கள்'),
    ]) {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(SampleAuthRepository()),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LoginScreen(),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text(expected), findsOneWidget,
          reason: 'Explore button should be translated for $locale');
    }
  });
});
```

(Check how existing tests override `authRepositoryProvider` — if `LoginScreen` pumps fine without an override there, drop the override; mirror the existing pattern in the file.)

- [ ] **Step 2: Full verification**

Run: `flutter analyze` → 0 issues. `flutter test` → ALL green; report the final count.
Run: `grep -rnE "Text\('[A-Z]" lib/presentation/ | grep -v "l10n"` → review every hit; each must be either non-UI (keys, asset paths) or a deliberate exception (brand name, district values). List leftovers in your report.

- [ ] **Step 3: Update READMEs**

Add to the feature list: "3 languages — English, Sinhala (සිංහල), Tamil (தமிழ்) — switchable in-app, persisted". Add `flutter_localizations`/`intl`/`shared_preferences` to the tech-stack section if one exists.

- [ ] **Step 4: Commit**

```bash
git add test/ceylon_review_test.dart ../README.md README.md 2>/dev/null
git commit -m "Add locale end-to-end tests and document 3-language support"
```

---

## Self-Review Notes

- Spec coverage: languages (T1), gen-l10n approach (T1), locale state + persistence (T2), picker in Profile + Login (T3), full string migration (T4–T7), fonts (no work — spec), error handling (unsupported persisted value guarded in T2 `build()`), testing (T1 smoke, T2 unit, T3 picker, T8 end-to-end). ✅
- All key names cross-checked between ARB (T1) and mapping tables (T4–T7). ✅
- Placeholder types are `String` everywhere callers pass interpolations — callers stringify at the call site. ✅
