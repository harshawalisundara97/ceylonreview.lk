import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ceylon Review';

  @override
  String get tagline => 'Places you\'ll love, across the island';

  @override
  String get navHome => 'Home';

  @override
  String get navMap => 'Map';

  @override
  String get navRanks => 'Ranks';

  @override
  String get navPost => 'Post';

  @override
  String get navFeed => 'Feed';

  @override
  String get navProfile => 'Profile';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get passwordMin6 => 'Password must be at least 6 characters';

  @override
  String get explore => 'Explore';

  @override
  String get createAccount => 'Create account';

  @override
  String get alreadyHaveAccountSignIn => 'Already have an account? Sign in';

  @override
  String get newHereCreateAccount => 'New here? Create an account';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get accountCreatedCheckEmail => 'Account created! Check your email to confirm, then sign in.';

  @override
  String get genericConnectionError => 'Something went wrong. Check your connection and try again.';

  @override
  String get resetYourPassword => 'Reset your password';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get cancel => 'Cancel';

  @override
  String get checkYourEmail => 'Check your email';

  @override
  String resetLinkSent(String email) {
    return 'If an account exists for $email, a reset link is on its way.';
  }

  @override
  String get done => 'Done';

  @override
  String get setNewPassword => 'Set a new password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match';

  @override
  String get updatePassword => 'Update password';

  @override
  String get couldNotUpdatePassword => 'Could not update your password. Try again.';

  @override
  String get discoverSriLanka => 'DISCOVER SRI LANKA';

  @override
  String get ayubowan => 'Ayubowan!';

  @override
  String ayubowanUser(String name) {
    return 'Ayubowan, $name!';
  }

  @override
  String get whereToNext => 'Where to next in Sri Lanka?';

  @override
  String get searchHint => 'Search places, beaches, food…';

  @override
  String get trendingThisWeek => 'Trending This Week';

  @override
  String get couldNotLoadPlaces => 'Could not load places.';

  @override
  String get pullToRefreshError => 'Something went wrong. Pull to refresh.';

  @override
  String noPlacesFound(String query) {
    return 'No places found for \"$query\"';
  }

  @override
  String get community => 'COMMUNITY';

  @override
  String get filters => 'Filters';

  @override
  String get sortBy => 'Sort by';

  @override
  String get price => 'Price';

  @override
  String get priceLevel => 'Price level';

  @override
  String get openNow => 'Open now';

  @override
  String get closed => 'Closed';

  @override
  String opensTime(String time) {
    return 'Opens $time';
  }

  @override
  String closesTime(String time) {
    return 'Closes $time';
  }

  @override
  String get reset => 'Reset';

  @override
  String get apply => 'Apply';

  @override
  String get reviews => 'Reviews';

  @override
  String get photos => 'Photos';

  @override
  String get hours => 'Hours';

  @override
  String get getDirections => 'Get Directions';

  @override
  String get directionsOpenInMapTab => 'Directions open in the Map tab.';

  @override
  String get writeAReview => 'Write a Review';

  @override
  String get couldNotLoadThisPlace => 'Could not load this place.';

  @override
  String get couldNotLoadReviews => 'Could not load reviews.';

  @override
  String get noReviewsYetBeFirst => 'No reviews yet — be the first to share your visit!';

  @override
  String nReviews(String count) {
    return '$count reviews';
  }

  @override
  String youRated(String rating) {
    return 'You: $rating★';
  }

  @override
  String get viewPlace => 'View Place';

  @override
  String get place => 'Place';

  @override
  String get chooseAPlace => 'Choose a place';

  @override
  String get chooseAPlaceToReview => 'Choose a place to review.';

  @override
  String get yourRating => 'Your rating';

  @override
  String get tapStarsToRate => 'Tap the stars to rate your visit.';

  @override
  String get yourReview => 'Your review';

  @override
  String get shareWhatYouLoved => 'Share what you loved — the food, the views, the welcome…';

  @override
  String get tellUsMore => 'Tell us a little more — at least 10 characters.';

  @override
  String get addPhotosOptional => 'Add photos (optional, up to 3)';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get postReview => 'Post Review';

  @override
  String get reviewPostedThankYou => 'Review posted. Thank you!';

  @override
  String get thisPlaceNoLongerExists => 'This place no longer exists.';

  @override
  String get addAPlace => 'Add a Place';

  @override
  String get addPlace => 'Add Place';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get category => 'Category';

  @override
  String get pickACategory => 'Pick a category.';

  @override
  String get district => 'District';

  @override
  String get chooseADistrict => 'Choose a district';

  @override
  String get districtRequired => 'District is required';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get photoOptional => 'Photo (optional)';

  @override
  String get locationTapMap => 'Location — tap the map or use your position';

  @override
  String get searchTownOrLandmark => 'Search a town or landmark';

  @override
  String get searchExampleHint => 'e.g. Ella, Galle Fort';

  @override
  String get useMyCurrentLocation => 'Use my current location';

  @override
  String get enableLocationToUse => 'Enable location to use your position.';

  @override
  String get dropAPin => 'Drop a pin for the location.';

  @override
  String get openingHoursOptional => 'Opening hours (optional)';

  @override
  String get opensAt => 'Opens at';

  @override
  String get closesAt => 'Closes at';

  @override
  String get couldNotAddPlace => 'Could not add the place. Please try again.';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get couldNotLoadLeaderboard => 'Could not load the leaderboard.';

  @override
  String nPts(String points) {
    return '$points pts';
  }

  @override
  String ptsToReach(String points, String rank) {
    return '$points pts to reach #$rank';
  }

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System default';

  @override
  String get yourReviews => 'Your Reviews';

  @override
  String get yourFavorites => 'Your Favorites';

  @override
  String get couldNotLoadYourReviews => 'Could not load your reviews.';

  @override
  String get couldNotLoadYourFavorites => 'Could not load your favorites.';

  @override
  String get noReviewsYetVisit => 'No reviews yet. Visit a place and share your experience!';

  @override
  String get signOut => 'Sign Out';

  @override
  String get map => 'Map';

  @override
  String get couldNotLoadMap => 'Could not load the map.';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryAllPlaces => 'All Places';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryNature => 'Nature';

  @override
  String get categoryBeaches => 'Beaches';

  @override
  String get categoryHotels => 'Hotels';

  @override
  String get categoryTemples => 'Temples';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get placesYoullLove => 'Places You\'ll Love';

  @override
  String get exploreSriLanka => 'Explore Sri Lanka';

  @override
  String get cantFindAddPlace => 'Can\'t find it? Add this place';

  @override
  String get locationAccessSortByDistance => 'Enable location access to sort by distance.';
}
