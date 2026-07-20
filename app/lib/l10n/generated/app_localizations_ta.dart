import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'Ceylon Review';

  @override
  String get tagline => 'தீவு முழுவதும் நீங்கள் விரும்பும் இடங்கள்';

  @override
  String get navHome => 'முகப்பு';

  @override
  String get navMap => 'வரைபடம்';

  @override
  String get navRanks => 'தரவரிசை';

  @override
  String get navPost => 'பதிவிடு';

  @override
  String get navFeed => 'ஃபீடு';

  @override
  String get navProfile => 'சுயவிவரம்';

  @override
  String get name => 'பெயர்';

  @override
  String get email => 'மின்னஞ்சல்';

  @override
  String get password => 'கடவுச்சொல்';

  @override
  String get enterYourName => 'உங்கள் பெயரை உள்ளிடவும்';

  @override
  String get enterValidEmail => 'சரியான மின்னஞ்சலை உள்ளிடவும்';

  @override
  String get passwordMin6 => 'கடவுச்சொல் குறைந்தது 6 எழுத்துகள் இருக்க வேண்டும்';

  @override
  String get explore => 'ஆராயுங்கள்';

  @override
  String get createAccount => 'கணக்கை உருவாக்கவும்';

  @override
  String get alreadyHaveAccountSignIn => 'ஏற்கனவே கணக்கு உள்ளதா? உள்நுழையவும்';

  @override
  String get newHereCreateAccount => 'புதியவரா? கணக்கை உருவாக்கவும்';

  @override
  String get forgotPassword => 'கடவுச்சொல் மறந்துவிட்டதா?';

  @override
  String get accountCreatedCheckEmail => 'கணக்கு உருவாக்கப்பட்டது! உறுதிப்படுத்த உங்கள் மின்னஞ்சலைப் பார்த்து, பின் உள்நுழையவும்.';

  @override
  String get genericConnectionError => 'ஏதோ தவறு நடந்தது. இணைப்பைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get resetYourPassword => 'கடவுச்சொல்லை மீட்டமைக்கவும்';

  @override
  String get sendResetLink => 'மீட்டமைப்பு இணைப்பை அனுப்பவும்';

  @override
  String get cancel => 'ரத்துசெய்';

  @override
  String get checkYourEmail => 'உங்கள் மின்னஞ்சலைப் பார்க்கவும்';

  @override
  String resetLinkSent(String email) {
    return '$email க்கு கணக்கு இருந்தால், மீட்டமைப்பு இணைப்பு அனுப்பப்பட்டுள்ளது.';
  }

  @override
  String get done => 'முடிந்தது';

  @override
  String get setNewPassword => 'புதிய கடவுச்சொல்லை அமைக்கவும்';

  @override
  String get newPassword => 'புதிய கடவுச்சொல்';

  @override
  String get confirmPassword => 'கடவுச்சொல்லை உறுதிப்படுத்தவும்';

  @override
  String get passwordsDontMatch => 'கடவுச்சொற்கள் பொருந்தவில்லை';

  @override
  String get updatePassword => 'கடவுச்சொல்லைப் புதுப்பிக்கவும்';

  @override
  String get couldNotUpdatePassword => 'கடவுச்சொல்லைப் புதுப்பிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get discoverSriLanka => 'இலங்கையைக் கண்டறியுங்கள்';

  @override
  String get ayubowan => 'வணக்கம்!';

  @override
  String ayubowanUser(String name) {
    return 'வணக்கம், $name!';
  }

  @override
  String get whereToNext => 'இலங்கையில் அடுத்து எங்கே?';

  @override
  String get searchHint => 'இடங்கள், கடற்கரைகள், உணவு தேடுங்கள்…';

  @override
  String get trendingThisWeek => 'இந்த வாரம் பிரபலமானவை';

  @override
  String get couldNotLoadPlaces => 'இடங்களை ஏற்ற முடியவில்லை.';

  @override
  String get pullToRefreshError => 'ஏதோ தவறு நடந்தது. புதுப்பிக்க கீழே இழுக்கவும்.';

  @override
  String noPlacesFound(String query) {
    return '\"$query\" க்கு இடங்கள் கிடைக்கவில்லை';
  }

  @override
  String get community => 'சமூகம்';

  @override
  String get filters => 'வடிப்பான்கள்';

  @override
  String get sortBy => 'வரிசைப்படுத்து';

  @override
  String get price => 'விலை';

  @override
  String get priceLevel => 'விலை நிலை';

  @override
  String get openNow => 'இப்போது திறந்துள்ளது';

  @override
  String get closed => 'மூடப்பட்டுள்ளது';

  @override
  String opensTime(String time) {
    return '$time க்கு திறக்கும்';
  }

  @override
  String closesTime(String time) {
    return '$time க்கு மூடும்';
  }

  @override
  String get reset => 'மீட்டமை';

  @override
  String get apply => 'பயன்படுத்து';

  @override
  String get reviews => 'விமர்சனங்கள்';

  @override
  String get photos => 'புகைப்படங்கள்';

  @override
  String get hours => 'நேரங்கள்';

  @override
  String get getDirections => 'வழிகாட்டுதல்';

  @override
  String get directionsOpenInMapTab => 'வழிகாட்டுதல் வரைபடத் தாவலில் திறக்கும்.';

  @override
  String get writeAReview => 'விமர்சனம் எழுதுங்கள்';

  @override
  String get couldNotLoadThisPlace => 'இந்த இடத்தை ஏற்ற முடியவில்லை.';

  @override
  String get couldNotLoadReviews => 'விமர்சனங்களை ஏற்ற முடியவில்லை.';

  @override
  String get noReviewsYetBeFirst => 'இன்னும் விமர்சனங்கள் இல்லை — உங்கள் வருகையைப் பகிரும் முதல் நபராகுங்கள்!';

  @override
  String nReviews(String count) {
    return '$count விமர்சனங்கள்';
  }

  @override
  String youRated(String rating) {
    return 'நீங்கள்: $rating★';
  }

  @override
  String get viewPlace => 'இடத்தைப் பார்க்கவும்';

  @override
  String get place => 'இடம்';

  @override
  String get chooseAPlace => 'ஒரு இடத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get chooseAPlaceToReview => 'விமர்சிக்க ஒரு இடத்தைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get yourRating => 'உங்கள் மதிப்பீடு';

  @override
  String get tapStarsToRate => 'உங்கள் வருகையை மதிப்பிட நட்சத்திரங்களைத் தட்டவும்.';

  @override
  String get yourReview => 'உங்கள் விமர்சனம்';

  @override
  String get shareWhatYouLoved => 'நீங்கள் விரும்பியதைப் பகிருங்கள் — உணவு, காட்சிகள், வரவேற்பு…';

  @override
  String get tellUsMore => 'இன்னும் கொஞ்சம் சொல்லுங்கள் — குறைந்தது 10 எழுத்துகள்.';

  @override
  String get addPhotosOptional => 'புகைப்படங்களைச் சேர்க்கவும் (விருப்பம், அதிகபட்சம் 3)';

  @override
  String get camera => 'கேமரா';

  @override
  String get gallery => 'கேலரி';

  @override
  String get postReview => 'விமர்சனத்தைப் பதிவிடு';

  @override
  String get reviewPostedThankYou => 'விமர்சனம் பதிவிடப்பட்டது. நன்றி!';

  @override
  String get thisPlaceNoLongerExists => 'இந்த இடம் இப்போது இல்லை.';

  @override
  String get addAPlace => 'இடத்தைச் சேர்க்கவும்';

  @override
  String get addPlace => 'இடம் சேர்';

  @override
  String get nameRequired => 'பெயர் தேவை';

  @override
  String get category => 'வகை';

  @override
  String get pickACategory => 'ஒரு வகையைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get district => 'மாவட்டம்';

  @override
  String get chooseADistrict => 'ஒரு மாவட்டத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get districtRequired => 'மாவட்டம் தேவை';

  @override
  String get descriptionOptional => 'விளக்கம் (விருப்பம்)';

  @override
  String get photoOptional => 'புகைப்படம் (விருப்பம்)';

  @override
  String get locationTapMap => 'இடம் — வரைபடத்தைத் தட்டவும் அல்லது உங்கள் இருப்பிடத்தைப் பயன்படுத்தவும்';

  @override
  String get searchTownOrLandmark => 'ஊர் அல்லது அடையாள இடத்தைத் தேடுங்கள்';

  @override
  String get searchExampleHint => 'எ.கா: எல்ல, காலி கோட்டை';

  @override
  String get useMyCurrentLocation => 'என் தற்போதைய இருப்பிடத்தைப் பயன்படுத்து';

  @override
  String get enableLocationToUse => 'உங்கள் இருப்பிடத்தைப் பயன்படுத்த இருப்பிடச் சேவையை இயக்கவும்.';

  @override
  String get dropAPin => 'இடத்திற்காக ஒரு பின்னை வைக்கவும்.';

  @override
  String get openingHoursOptional => 'திறக்கும் நேரங்கள் (விருப்பம்)';

  @override
  String get opensAt => 'திறக்கும் நேரம்';

  @override
  String get closesAt => 'மூடும் நேரம்';

  @override
  String get couldNotAddPlace => 'இடத்தைச் சேர்க்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get leaderboard => 'தரவரிசைப் பட்டியல்';

  @override
  String get couldNotLoadLeaderboard => 'தரவரிசைப் பட்டியலை ஏற்ற முடியவில்லை.';

  @override
  String nPts(String points) {
    return '$points புள்ளிகள்';
  }

  @override
  String ptsToReach(String points, String rank) {
    return '#$rank ஐ அடைய $points புள்ளிகள்';
  }

  @override
  String get darkMode => 'இருண்ட பயன்முறை';

  @override
  String get language => 'மொழி';

  @override
  String get systemDefault => 'கணினி இயல்புநிலை';

  @override
  String get yourReviews => 'உங்கள் விமர்சனங்கள்';

  @override
  String get yourFavorites => 'உங்கள் பிடித்தவை';

  @override
  String get couldNotLoadYourReviews => 'உங்கள் விமர்சனங்களை ஏற்ற முடியவில்லை.';

  @override
  String get couldNotLoadYourFavorites => 'உங்கள் பிடித்தவற்றை ஏற்ற முடியவில்லை.';

  @override
  String get noReviewsYetVisit => 'இன்னும் விமர்சனங்கள் இல்லை. ஒரு இடத்திற்குச் சென்று உங்கள் அனுபவத்தைப் பகிருங்கள்!';

  @override
  String get signOut => 'வெளியேறு';

  @override
  String get map => 'வரைபடம்';

  @override
  String get couldNotLoadMap => 'வரைபடத்தை ஏற்ற முடியவில்லை.';

  @override
  String get categoryAll => 'அனைத்தும்';

  @override
  String get categoryAllPlaces => 'அனைத்து இடங்களும்';

  @override
  String get categoryFood => 'உணவு';

  @override
  String get categoryNature => 'இயற்கை';

  @override
  String get categoryBeaches => 'கடற்கரைகள்';

  @override
  String get categoryHotels => 'ஹோட்டல்கள்';

  @override
  String get categoryTemples => 'கோவில்கள்';

  @override
  String get categoryShopping => 'கடைத்தொகுப்பு';

  @override
  String get placesYoullLove => 'நீங்கள் விரும்பும் இடங்கள்';

  @override
  String get exploreSriLanka => 'இலங்கையை ஆராயுங்கள்';

  @override
  String get cantFindAddPlace => 'கண்டுபிடிக்க முடியவில்லையா? இந்த இடத்தைச் சேர்க்கவும்';

  @override
  String get locationAccessSortByDistance => 'தூரத்தின்படி வரிசைப்படுத்த இருப்பிட அணுகலை இயக்கவும்.';

  @override
  String noResultsFoundForQuery(String query) {
    return '\"$query\" க்கு முடிவுகள் இல்லை.';
  }

  @override
  String get searchFailedCheckConnection => 'தேடல் தோல்வியடைந்தது — உங்கள் இணைப்பைச் சரிபார்க்கவும்.';
}
