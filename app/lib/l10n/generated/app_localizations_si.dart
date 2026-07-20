import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sinhala Sinhalese (`si`).
class AppLocalizationsSi extends AppLocalizations {
  AppLocalizationsSi([String locale = 'si']) : super(locale);

  @override
  String get appTitle => 'Ceylon Review';

  @override
  String get tagline => 'දිවයින පුරා ඔබ ප්‍රිය කරන ස්ථාන';

  @override
  String get navHome => 'මුල් පිටුව';

  @override
  String get navMap => 'සිතියම';

  @override
  String get navRanks => 'ශ්‍රේණි';

  @override
  String get navPost => 'පළ කරන්න';

  @override
  String get navFeed => 'ෆීඩ්';

  @override
  String get navProfile => 'පැතිකඩ';

  @override
  String get name => 'නම';

  @override
  String get email => 'විද්‍යුත් තැපෑල';

  @override
  String get password => 'මුරපදය';

  @override
  String get enterYourName => 'ඔබේ නම ඇතුළත් කරන්න';

  @override
  String get enterValidEmail => 'වලංගු විද්‍යුත් තැපෑලක් ඇතුළත් කරන්න';

  @override
  String get passwordMin6 => 'මුරපදය අවම වශයෙන් අක්ෂර 6ක් විය යුතුය';

  @override
  String get explore => 'ගවේෂණය කරන්න';

  @override
  String get createAccount => 'ගිණුමක් සාදන්න';

  @override
  String get alreadyHaveAccountSignIn => 'දැනටමත් ගිණුමක් තිබේද? පුරන්න';

  @override
  String get newHereCreateAccount => 'අලුත්ද? ගිණුමක් සාදන්න';

  @override
  String get forgotPassword => 'මුරපදය අමතකද?';

  @override
  String get accountCreatedCheckEmail => 'ගිණුම සෑදුවා! තහවුරු කිරීමට ඔබේ විද්‍යුත් තැපෑල බලා, පසුව පුරන්න.';

  @override
  String get genericConnectionError => 'යමක් වැරදුණා. සම්බන්ධතාවය පරීක්ෂා කර නැවත උත්සාහ කරන්න.';

  @override
  String get resetYourPassword => 'මුරපදය යළි සකසන්න';

  @override
  String get sendResetLink => 'යළි සැකසීමේ සබැඳිය යවන්න';

  @override
  String get cancel => 'අවලංගු කරන්න';

  @override
  String get checkYourEmail => 'ඔබේ විද්‍යුත් තැපෑල බලන්න';

  @override
  String resetLinkSent(String email) {
    return '$email සඳහා ගිණුමක් තිබේ නම්, යළි සැකසීමේ සබැඳියක් එවා ඇත.';
  }

  @override
  String get done => 'හරි';

  @override
  String get setNewPassword => 'නව මුරපදයක් සකසන්න';

  @override
  String get newPassword => 'නව මුරපදය';

  @override
  String get confirmPassword => 'මුරපදය තහවුරු කරන්න';

  @override
  String get passwordsDontMatch => 'මුරපද නොගැලපේ';

  @override
  String get updatePassword => 'මුරපදය යාවත්කාලීන කරන්න';

  @override
  String get couldNotUpdatePassword => 'මුරපදය යාවත්කාලීන කළ නොහැකි විය. නැවත උත්සාහ කරන්න.';

  @override
  String get discoverSriLanka => 'ශ්‍රී ලංකාව සොයා යන්න';

  @override
  String get ayubowan => 'ආයුබෝවන්!';

  @override
  String ayubowanUser(String name) {
    return 'ආයුබෝවන්, $name!';
  }

  @override
  String get whereToNext => 'ශ්‍රී ලංකාවේ ඊළඟට කොහෙද?';

  @override
  String get searchHint => 'ස්ථාන, වෙරළ, කෑම සොයන්න…';

  @override
  String get trendingThisWeek => 'මේ සතියේ ජනප්‍රිය';

  @override
  String get couldNotLoadPlaces => 'ස්ථාන පූරණය කළ නොහැකි විය.';

  @override
  String get pullToRefreshError => 'යමක් වැරදුණා. නැවුම් කිරීමට පහළට අදින්න.';

  @override
  String noPlacesFound(String query) {
    return '\"$query\" සඳහා ස්ථාන හමු නොවීය';
  }

  @override
  String get community => 'ප්‍රජාව';

  @override
  String get filters => 'පෙරහන්';

  @override
  String get sortBy => 'අනුපිළිවෙල';

  @override
  String get price => 'මිල';

  @override
  String get priceLevel => 'මිල මට්ටම';

  @override
  String get openNow => 'දැන් විවෘතයි';

  @override
  String get closed => 'වසා ඇත';

  @override
  String opensTime(String time) {
    return '$time ට විවෘත වේ';
  }

  @override
  String closesTime(String time) {
    return '$time ට වැසේ';
  }

  @override
  String get reset => 'යළි සකසන්න';

  @override
  String get apply => 'යොදන්න';

  @override
  String get reviews => 'සමාලෝචන';

  @override
  String get photos => 'ඡායාරූප';

  @override
  String get hours => 'වේලාවන්';

  @override
  String get getDirections => 'මාර්ග උපදෙස්';

  @override
  String get directionsOpenInMapTab => 'මාර්ග උපදෙස් සිතියම් පටිත්තෙන් විවෘත වේ.';

  @override
  String get writeAReview => 'සමාලෝචනයක් ලියන්න';

  @override
  String get couldNotLoadThisPlace => 'මෙම ස්ථානය පූරණය කළ නොහැකි විය.';

  @override
  String get couldNotLoadReviews => 'සමාලෝචන පූරණය කළ නොහැකි විය.';

  @override
  String get noReviewsYetBeFirst => 'තවම සමාලෝචන නැත — ඔබේ සංචාරය බෙදාගන්නා පළමුවැන්නා වන්න!';

  @override
  String nReviews(String count) {
    return 'සමාලෝචන $count';
  }

  @override
  String youRated(String rating) {
    return 'ඔබ: $rating★';
  }

  @override
  String get viewPlace => 'ස්ථානය බලන්න';

  @override
  String get place => 'ස්ථානය';

  @override
  String get chooseAPlace => 'ස්ථානයක් තෝරන්න';

  @override
  String get chooseAPlaceToReview => 'සමාලෝචනය කිරීමට ස්ථානයක් තෝරන්න.';

  @override
  String get yourRating => 'ඔබේ ශ්‍රේණිගත කිරීම';

  @override
  String get tapStarsToRate => 'ඔබේ සංචාරය ශ්‍රේණිගත කිරීමට තරු ස්පර්ශ කරන්න.';

  @override
  String get yourReview => 'ඔබේ සමාලෝචනය';

  @override
  String get shareWhatYouLoved => 'ඔබ ප්‍රිය කළ දේ බෙදාගන්න — කෑම, දර්ශන, පිළිගැනීම…';

  @override
  String get tellUsMore => 'තව ටිකක් කියන්න — අවම වශයෙන් අක්ෂර 10ක්.';

  @override
  String get addPhotosOptional => 'ඡායාරූප එක් කරන්න (අත්‍යවශ්‍ය නොවේ, උපරිම 3)';

  @override
  String get camera => 'කැමරාව';

  @override
  String get gallery => 'ගැලරිය';

  @override
  String get postReview => 'සමාලෝචනය පළ කරන්න';

  @override
  String get reviewPostedThankYou => 'සමාලෝචනය පළ විය. ස්තූතියි!';

  @override
  String get thisPlaceNoLongerExists => 'මෙම ස්ථානය තවදුරටත් නොපවතී.';

  @override
  String get addAPlace => 'ස්ථානයක් එක් කරන්න';

  @override
  String get addPlace => 'ස්ථානය එක් කරන්න';

  @override
  String get nameRequired => 'නම අවශ්‍යයි';

  @override
  String get category => 'වර්ගය';

  @override
  String get pickACategory => 'වර්ගයක් තෝරන්න.';

  @override
  String get district => 'දිස්ත්‍රික්කය';

  @override
  String get chooseADistrict => 'දිස්ත්‍රික්කයක් තෝරන්න';

  @override
  String get districtRequired => 'දිස්ත්‍රික්කය අවශ්‍යයි';

  @override
  String get descriptionOptional => 'විස්තරය (අත්‍යවශ්‍ය නොවේ)';

  @override
  String get photoOptional => 'ඡායාරූපය (අත්‍යවශ්‍ය නොවේ)';

  @override
  String get locationTapMap => 'පිහිටීම — සිතියම ස්පර්ශ කරන්න හෝ ඔබේ පිහිටීම භාවිතා කරන්න';

  @override
  String get searchTownOrLandmark => 'නගරයක් හෝ ස්ථානයක් සොයන්න';

  @override
  String get searchExampleHint => 'උදා: ඇල්ල, ගාලු කොටුව';

  @override
  String get useMyCurrentLocation => 'මගේ වත්මන් පිහිටීම භාවිතා කරන්න';

  @override
  String get enableLocationToUse => 'ඔබේ පිහිටීම භාවිතා කිරීමට ස්ථාන සේවාව සක්‍රීය කරන්න.';

  @override
  String get dropAPin => 'පිහිටීම සඳහා පින් එකක් තබන්න.';

  @override
  String get openingHoursOptional => 'විවෘත වේලාවන් (අත්‍යවශ්‍ය නොවේ)';

  @override
  String get opensAt => 'විවෘත වන වේලාව';

  @override
  String get closesAt => 'වැසෙන වේලාව';

  @override
  String get couldNotAddPlace => 'ස්ථානය එක් කළ නොහැකි විය. නැවත උත්සාහ කරන්න.';

  @override
  String get leaderboard => 'ප්‍රමුඛ ලැයිස්තුව';

  @override
  String get couldNotLoadLeaderboard => 'ප්‍රමුඛ ලැයිස්තුව පූරණය කළ නොහැකි විය.';

  @override
  String nPts(String points) {
    return 'ලකුණු $points';
  }

  @override
  String ptsToReach(String points, String rank) {
    return '#$rank වෙත ළඟා වීමට ලකුණු $points';
  }

  @override
  String get darkMode => 'අඳුරු තේමාව';

  @override
  String get language => 'භාෂාව';

  @override
  String get systemDefault => 'පද්ධති නිතිය';

  @override
  String get yourReviews => 'ඔබේ සමාලෝචන';

  @override
  String get yourFavorites => 'ඔබේ ප්‍රියතම';

  @override
  String get couldNotLoadYourReviews => 'ඔබේ සමාලෝචන පූරණය කළ නොහැකි විය.';

  @override
  String get couldNotLoadYourFavorites => 'ඔබේ ප්‍රියතම පූරණය කළ නොහැකි විය.';

  @override
  String get noReviewsYetVisit => 'තවම සමාලෝචන නැත. ස්ථානයකට ගොස් ඔබේ අත්දැකීම බෙදාගන්න!';

  @override
  String get signOut => 'වරන්න';

  @override
  String get map => 'සිතියම';

  @override
  String get couldNotLoadMap => 'සිතියම පූරණය කළ නොහැකි විය.';

  @override
  String get categoryAll => 'සියල්ල';

  @override
  String get categoryAllPlaces => 'සියලු ස්ථාන';

  @override
  String get categoryFood => 'කෑම';

  @override
  String get categoryNature => 'සොබාදහම';

  @override
  String get categoryBeaches => 'වෙරළ';

  @override
  String get categoryHotels => 'හෝටල්';

  @override
  String get categoryTemples => 'පන්සල්';

  @override
  String get categoryShopping => 'සාප්පු';

  @override
  String get placesYoullLove => 'ඔබ ප්‍රිය කරන ස්ථාන';

  @override
  String get exploreSriLanka => 'ශ්‍රී ලංකාව ගවේෂණය කරන්න';

  @override
  String get cantFindAddPlace => 'සොයාගත නොහැකිද? මෙම ස්ථානය එක් කරන්න';

  @override
  String get locationAccessSortByDistance => 'දුර අනුව අනුපිළිවෙල කිරීමට ස්ථාන ප්‍රවේශය සක්‍රීය කරන්න.';
}
