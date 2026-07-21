import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Ceylon Review'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Places you\'ll love, across the island'**
  String get tagline;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navRanks.
  ///
  /// In en, this message translates to:
  /// **'Ranks'**
  String get navRanks;

  /// No description provided for @navPost.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get navPost;

  /// No description provided for @navFeed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get navFeed;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @passwordMin6.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMin6;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccountSignIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccountSignIn;

  /// No description provided for @newHereCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get newHereCreateAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @accountCreatedCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'Account created! Check your email to confirm, then sign in.'**
  String get accountCreatedCheckEmail;

  /// No description provided for @genericConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Check your connection and try again.'**
  String get genericConnectionError;

  /// No description provided for @resetYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetYourPassword;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkYourEmail;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for {email}, a reset link is on its way.'**
  String resetLinkSent(String email);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get setNewPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePassword;

  /// No description provided for @couldNotUpdatePassword.
  ///
  /// In en, this message translates to:
  /// **'Could not update your password. Try again.'**
  String get couldNotUpdatePassword;

  /// No description provided for @discoverSriLanka.
  ///
  /// In en, this message translates to:
  /// **'DISCOVER SRI LANKA'**
  String get discoverSriLanka;

  /// No description provided for @ayubowan.
  ///
  /// In en, this message translates to:
  /// **'Ayubowan!'**
  String get ayubowan;

  /// No description provided for @ayubowanUser.
  ///
  /// In en, this message translates to:
  /// **'Ayubowan, {name}!'**
  String ayubowanUser(String name);

  /// No description provided for @whereToNext.
  ///
  /// In en, this message translates to:
  /// **'Where to next in Sri Lanka?'**
  String get whereToNext;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search places, beaches, food…'**
  String get searchHint;

  /// No description provided for @trendingThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Trending This Week'**
  String get trendingThisWeek;

  /// No description provided for @couldNotLoadPlaces.
  ///
  /// In en, this message translates to:
  /// **'Could not load places.'**
  String get couldNotLoadPlaces;

  /// No description provided for @pullToRefreshError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Pull to refresh.'**
  String get pullToRefreshError;

  /// No description provided for @noPlacesFound.
  ///
  /// In en, this message translates to:
  /// **'No places found for \"{query}\"'**
  String noPlacesFound(String query);

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'COMMUNITY'**
  String get community;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @priceLevel.
  ///
  /// In en, this message translates to:
  /// **'Price level'**
  String get priceLevel;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get openNow;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @opensTime.
  ///
  /// In en, this message translates to:
  /// **'Opens {time}'**
  String opensTime(String time);

  /// No description provided for @closesTime.
  ///
  /// In en, this message translates to:
  /// **'Closes {time}'**
  String closesTime(String time);

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get getDirections;

  /// No description provided for @directionsOpenInMapTab.
  ///
  /// In en, this message translates to:
  /// **'Directions open in the Map tab.'**
  String get directionsOpenInMapTab;

  /// No description provided for @writeAReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeAReview;

  /// No description provided for @couldNotLoadThisPlace.
  ///
  /// In en, this message translates to:
  /// **'Could not load this place.'**
  String get couldNotLoadThisPlace;

  /// No description provided for @couldNotLoadReviews.
  ///
  /// In en, this message translates to:
  /// **'Could not load reviews.'**
  String get couldNotLoadReviews;

  /// No description provided for @noReviewsYetBeFirst.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet — be the first to share your visit!'**
  String get noReviewsYetBeFirst;

  /// No description provided for @nReviews.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String nReviews(String count);

  /// No description provided for @youRated.
  ///
  /// In en, this message translates to:
  /// **'You: {rating}★'**
  String youRated(String rating);

  /// No description provided for @viewPlace.
  ///
  /// In en, this message translates to:
  /// **'View Place'**
  String get viewPlace;

  /// No description provided for @place.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get place;

  /// No description provided for @chooseAPlace.
  ///
  /// In en, this message translates to:
  /// **'Choose a place'**
  String get chooseAPlace;

  /// No description provided for @chooseAPlaceToReview.
  ///
  /// In en, this message translates to:
  /// **'Choose a place to review.'**
  String get chooseAPlaceToReview;

  /// No description provided for @yourRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get yourRating;

  /// No description provided for @tapStarsToRate.
  ///
  /// In en, this message translates to:
  /// **'Tap the stars to rate your visit.'**
  String get tapStarsToRate;

  /// No description provided for @yourReview.
  ///
  /// In en, this message translates to:
  /// **'Your review'**
  String get yourReview;

  /// No description provided for @shareWhatYouLoved.
  ///
  /// In en, this message translates to:
  /// **'Share what you loved — the food, the views, the welcome…'**
  String get shareWhatYouLoved;

  /// No description provided for @tellUsMore.
  ///
  /// In en, this message translates to:
  /// **'Tell us a little more — at least 10 characters.'**
  String get tellUsMore;

  /// No description provided for @addPhotosOptional.
  ///
  /// In en, this message translates to:
  /// **'Add photos (optional, up to 3)'**
  String get addPhotosOptional;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @postReview.
  ///
  /// In en, this message translates to:
  /// **'Post Review'**
  String get postReview;

  /// No description provided for @reviewPostedThankYou.
  ///
  /// In en, this message translates to:
  /// **'Review posted. Thank you!'**
  String get reviewPostedThankYou;

  /// No description provided for @thisPlaceNoLongerExists.
  ///
  /// In en, this message translates to:
  /// **'This place no longer exists.'**
  String get thisPlaceNoLongerExists;

  /// No description provided for @addAPlace.
  ///
  /// In en, this message translates to:
  /// **'Add a Place'**
  String get addAPlace;

  /// No description provided for @addPlace.
  ///
  /// In en, this message translates to:
  /// **'Add Place'**
  String get addPlace;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @pickACategory.
  ///
  /// In en, this message translates to:
  /// **'Pick a category.'**
  String get pickACategory;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @chooseADistrict.
  ///
  /// In en, this message translates to:
  /// **'Choose a district'**
  String get chooseADistrict;

  /// No description provided for @districtRequired.
  ///
  /// In en, this message translates to:
  /// **'District is required'**
  String get districtRequired;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @photoOptional.
  ///
  /// In en, this message translates to:
  /// **'Photo (optional)'**
  String get photoOptional;

  /// No description provided for @locationTapMap.
  ///
  /// In en, this message translates to:
  /// **'Location — tap the map or use your position'**
  String get locationTapMap;

  /// No description provided for @searchTownOrLandmark.
  ///
  /// In en, this message translates to:
  /// **'Search a town or landmark'**
  String get searchTownOrLandmark;

  /// No description provided for @searchExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Ella, Galle Fort'**
  String get searchExampleHint;

  /// No description provided for @useMyCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get useMyCurrentLocation;

  /// No description provided for @enableLocationToUse.
  ///
  /// In en, this message translates to:
  /// **'Enable location to use your position.'**
  String get enableLocationToUse;

  /// No description provided for @dropAPin.
  ///
  /// In en, this message translates to:
  /// **'Drop a pin for the location.'**
  String get dropAPin;

  /// No description provided for @openingHoursOptional.
  ///
  /// In en, this message translates to:
  /// **'Opening hours (optional)'**
  String get openingHoursOptional;

  /// No description provided for @opensAt.
  ///
  /// In en, this message translates to:
  /// **'Opens at'**
  String get opensAt;

  /// No description provided for @closesAt.
  ///
  /// In en, this message translates to:
  /// **'Closes at'**
  String get closesAt;

  /// No description provided for @couldNotAddPlace.
  ///
  /// In en, this message translates to:
  /// **'Could not add the place. Please try again.'**
  String get couldNotAddPlace;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @couldNotLoadLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Could not load the leaderboard.'**
  String get couldNotLoadLeaderboard;

  /// No description provided for @nPts.
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String nPts(String points);

  /// No description provided for @ptsToReach.
  ///
  /// In en, this message translates to:
  /// **'{points} pts to reach #{rank}'**
  String ptsToReach(String points, String rank);

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @yourReviews.
  ///
  /// In en, this message translates to:
  /// **'Your Reviews'**
  String get yourReviews;

  /// No description provided for @yourFavorites.
  ///
  /// In en, this message translates to:
  /// **'Your Favorites'**
  String get yourFavorites;

  /// No description provided for @couldNotLoadYourReviews.
  ///
  /// In en, this message translates to:
  /// **'Could not load your reviews.'**
  String get couldNotLoadYourReviews;

  /// No description provided for @couldNotLoadYourFavorites.
  ///
  /// In en, this message translates to:
  /// **'Could not load your favorites.'**
  String get couldNotLoadYourFavorites;

  /// No description provided for @noReviewsYetVisit.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet. Visit a place and share your experience!'**
  String get noReviewsYetVisit;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @couldNotLoadMap.
  ///
  /// In en, this message translates to:
  /// **'Could not load the map.'**
  String get couldNotLoadMap;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryAllPlaces.
  ///
  /// In en, this message translates to:
  /// **'All Places'**
  String get categoryAllPlaces;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get categoryNature;

  /// No description provided for @categoryBeaches.
  ///
  /// In en, this message translates to:
  /// **'Beaches'**
  String get categoryBeaches;

  /// No description provided for @categoryHotels.
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get categoryHotels;

  /// No description provided for @categoryTemples.
  ///
  /// In en, this message translates to:
  /// **'Temples'**
  String get categoryTemples;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @placesYoullLove.
  ///
  /// In en, this message translates to:
  /// **'Places You\'ll Love'**
  String get placesYoullLove;

  /// No description provided for @exploreSriLanka.
  ///
  /// In en, this message translates to:
  /// **'Explore Sri Lanka'**
  String get exploreSriLanka;

  /// No description provided for @cantFindAddPlace.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find it? Add this place'**
  String get cantFindAddPlace;

  /// No description provided for @locationAccessSortByDistance.
  ///
  /// In en, this message translates to:
  /// **'Enable location access to sort by distance.'**
  String get locationAccessSortByDistance;

  /// No description provided for @noResultsFoundForQuery.
  ///
  /// In en, this message translates to:
  /// **'No results found for \"{query}\".'**
  String noResultsFoundForQuery(String query);

  /// No description provided for @searchFailedCheckConnection.
  ///
  /// In en, this message translates to:
  /// **'Search failed — check your connection.'**
  String get searchFailedCheckConnection;

  /// No description provided for @leaderboardEmptyState.
  ///
  /// In en, this message translates to:
  /// **'Be the first to post a review and claim #1!'**
  String get leaderboardEmptyState;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @noFavoritesYetTapHeart.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet. Tap the heart on a place you love!'**
  String get noFavoritesYetTapHeart;

  /// No description provided for @aPlace.
  ///
  /// In en, this message translates to:
  /// **'A place'**
  String get aPlace;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
