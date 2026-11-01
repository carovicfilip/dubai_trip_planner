import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ru.dart';

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
    Locale('ar'),
    Locale('de'),
    Locale('fr'),
    Locale('ru'),
  ];

  /// The name of the app in the task switcher.
  ///
  /// In en, this message translates to:
  /// **'Dubai Trip Planner'**
  String get appTitle;

  /// Read out by screen readers for the language button.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// A short widely spaced label under titles, in capitals where the script has them.
  ///
  /// In en, this message translates to:
  /// **'DUBAI'**
  String get dubaiLabel;

  /// Button that goes on to the next page or step.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Between the items of a short list, with its trailing space.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get listSeparator;

  /// Tab of the bottom bar, at most about 11 characters.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// Tab of the bottom bar, at most about 11 characters.
  ///
  /// In en, this message translates to:
  /// **'My Trip'**
  String get navMyTrip;

  /// Tab of the bottom bar, at most about 11 characters.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get navCategories;

  /// Tab of the bottom bar, at most about 11 characters.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// First line of the big title on the home screen.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get exploreHeroLight;

  /// Second, bold line of the big title on the home screen.
  ///
  /// In en, this message translates to:
  /// **'Dubai!'**
  String get exploreHeroBold;

  /// No description provided for @mostPopularTitle.
  ///
  /// In en, this message translates to:
  /// **'Most Popular Places'**
  String get mostPopularTitle;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @recommendedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommendedTitle;

  /// No description provided for @weatherTitle.
  ///
  /// In en, this message translates to:
  /// **'Weather Forecast'**
  String get weatherTitle;

  /// No description provided for @tipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Hack & Tips'**
  String get tipsTitle;

  /// Title of a tip card, two short lines at most.
  ///
  /// In en, this message translates to:
  /// **'Use Nol Card for Transport'**
  String get tipNolCardTitle;

  /// Text of a tip card, three short lines at most.
  ///
  /// In en, this message translates to:
  /// **'Pay less for metro, buses, and water taxis by using a Nol card.'**
  String get tipNolCardText;

  /// Title of a tip card, two short lines at most.
  ///
  /// In en, this message translates to:
  /// **'Burj Khalifa Sunset View'**
  String get tipSunsetTitle;

  /// Text of a tip card, three short lines at most.
  ///
  /// In en, this message translates to:
  /// **'Visit around 4–5 PM to catch both daylight and sunset views.'**
  String get tipSunsetText;

  /// Title of a tip card, two short lines at most.
  ///
  /// In en, this message translates to:
  /// **'Stay Hydrated'**
  String get tipWaterTitle;

  /// Text of a tip card, three short lines at most.
  ///
  /// In en, this message translates to:
  /// **'Dubai heat is intense! Always carry water while exploring.'**
  String get tipWaterText;

  /// Title of a tip card, two short lines at most.
  ///
  /// In en, this message translates to:
  /// **'Book Desert Safari Early'**
  String get tipSafariTitle;

  /// Text of a tip card, three short lines at most.
  ///
  /// In en, this message translates to:
  /// **'Book online in advance to get better deals and avoid scams.'**
  String get tipSafariText;

  /// Title of a tip card, two short lines at most.
  ///
  /// In en, this message translates to:
  /// **'Use Careem App'**
  String get tipCareemTitle;

  /// Text of a tip card, three short lines at most.
  ///
  /// In en, this message translates to:
  /// **'Cheaper than Uber and better tailored for Dubai.'**
  String get tipCareemText;

  /// Title of a tip card, two short lines at most.
  ///
  /// In en, this message translates to:
  /// **'Respect Dress Code'**
  String get tipDressTitle;

  /// Text of a tip card, three short lines at most.
  ///
  /// In en, this message translates to:
  /// **'Wear modest clothes in malls and religious places.'**
  String get tipDressText;

  /// Title of a tip card, two short lines at most.
  ///
  /// In en, this message translates to:
  /// **'Bargain in Gold Souk'**
  String get tipBargainTitle;

  /// Text of a tip card, three short lines at most.
  ///
  /// In en, this message translates to:
  /// **'Negotiating is expected. Don\'t accept the first price!'**
  String get tipBargainText;

  /// Title of a tip card, two short lines at most.
  ///
  /// In en, this message translates to:
  /// **'Souks Open Late on Fridays'**
  String get tipFridayTitle;

  /// Text of a tip card, three short lines at most.
  ///
  /// In en, this message translates to:
  /// **'Many Gold Souk shops open only in the afternoon on Fridays.'**
  String get tipFridayText;

  /// Title of a tip card, two short lines at most.
  ///
  /// In en, this message translates to:
  /// **'Ask for Tax-Free Shopping'**
  String get tipTaxFreeTitle;

  /// Text of a tip card, three short lines at most.
  ///
  /// In en, this message translates to:
  /// **'Get VAT refunds at the airport with a tax-free receipt.'**
  String get tipTaxFreeText;

  /// Title of a tip card, two short lines at most.
  ///
  /// In en, this message translates to:
  /// **'Ride an Abra'**
  String get tipAbraTitle;

  /// Text of a tip card, three short lines at most.
  ///
  /// In en, this message translates to:
  /// **'Cross Dubai Creek for 1 AED on a traditional wooden boat.'**
  String get tipAbraText;

  /// Two lines, each at most about 28 characters.
  ///
  /// In en, this message translates to:
  /// **'Your perfect Dubai trip,\nplanned in minutes'**
  String get promoTitle;

  /// Two short lines next to the button.
  ///
  /// In en, this message translates to:
  /// **'Dates, hotel, interests.\nWe do the rest.'**
  String get promoText;

  /// A small button, at most about 12 characters.
  ///
  /// In en, this message translates to:
  /// **'Plan My Trip'**
  String get promoButton;

  /// One widely spaced word, in capitals where the script has them.
  ///
  /// In en, this message translates to:
  /// **'DISCOVER'**
  String get onboardingDiscoverLabel;

  /// Two lines in very large type, each at most about 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Dubai\'s Best,\nAll in One Place'**
  String get onboardingDiscoverTitle;

  /// No description provided for @onboardingDiscoverText.
  ///
  /// In en, this message translates to:
  /// **'No more endless searching. Top places, handpicked and ready to explore.'**
  String get onboardingDiscoverText;

  /// One widely spaced word, in capitals where the script has them.
  ///
  /// In en, this message translates to:
  /// **'EXPLORE'**
  String get onboardingExploreLabel;

  /// Two lines in very large type, each at most about 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Find Your Way\nAround Dubai'**
  String get onboardingExploreTitle;

  /// No description provided for @onboardingExploreText.
  ///
  /// In en, this message translates to:
  /// **'Opening hours, locations, your favorites and the weather, all at hand.'**
  String get onboardingExploreText;

  /// One widely spaced word, in capitals where the script has them.
  ///
  /// In en, this message translates to:
  /// **'PLAN'**
  String get onboardingPlanLabel;

  /// Two lines in very large type, each at most about 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Your Days,\nPlanned for You'**
  String get onboardingPlanTitle;

  /// No description provided for @onboardingPlanText.
  ///
  /// In en, this message translates to:
  /// **'A day-by-day itinerary built around your hotel and your interests.'**
  String get onboardingPlanText;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @splashTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get splashTitle;

  /// No description provided for @splashText.
  ///
  /// In en, this message translates to:
  /// **'Your next adventure is waiting. Let\'s pick up where you left off.'**
  String get splashText;

  /// First line of the big title on the Profile tab.
  ///
  /// In en, this message translates to:
  /// **'Your'**
  String get profileHeroLight;

  /// Second, bold line of the big title on the Profile tab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileHeroBold;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any favorites yet.'**
  String get favoritesEmpty;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get darkTheme;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @categoriesScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore Categories'**
  String get categoriesScreenTitle;

  /// No description provided for @categoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No places found for this category yet.'**
  String get categoryEmpty;

  /// A category of places.
  ///
  /// In en, this message translates to:
  /// **'Must-See'**
  String get categoryMustSee;

  /// A category of places.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get categoryRestaurants;

  /// A category of places.
  ///
  /// In en, this message translates to:
  /// **'Nightlife'**
  String get categoryNightlife;

  /// A category of places.
  ///
  /// In en, this message translates to:
  /// **'Beaches & Pools'**
  String get categoryBeachesPools;

  /// A category of places.
  ///
  /// In en, this message translates to:
  /// **'Culture & Museums'**
  String get categoryCultureMuseums;

  /// A category of places.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// A category of places.
  ///
  /// In en, this message translates to:
  /// **'Desert Adventure'**
  String get categoryDesertAdventure;

  /// A category of places.
  ///
  /// In en, this message translates to:
  /// **'Family Fun'**
  String get categoryFamilyFun;

  /// Button, at most about 24 characters.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get addToFavorites;

  /// Button, at most about 24 characters.
  ///
  /// In en, this message translates to:
  /// **'Saved to Favorites'**
  String get savedToFavorites;

  /// Heading of the description of a place.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get placeAbout;

  /// Heading of the rating of a place.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get placeRating;

  /// Heading of the opening hours of a place.
  ///
  /// In en, this message translates to:
  /// **'Opening hours'**
  String get placeOpeningHours;

  /// No description provided for @noReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviews;

  /// How many reviews a place has; formatted is the same number written short, like 166k.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{formatted} review} other{{formatted} reviews}}'**
  String reviewCount(int count, String formatted);

  /// A rating with its reviews, like 4.7 (166k reviews).
  ///
  /// In en, this message translates to:
  /// **'{rating} ({reviews})'**
  String reviewSummary(String rating, String reviews);

  /// No description provided for @weatherUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The forecast is unavailable right now.'**
  String get weatherUnavailable;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// An intl DateFormat pattern for the day and month on a forecast card. Not a text.
  ///
  /// In en, this message translates to:
  /// **'d MMMM'**
  String get weatherDatePattern;

  /// No description provided for @ratingQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do you like\nthe app so far?'**
  String get ratingQuestion;

  /// Read out by screen readers for the unhappy face.
  ///
  /// In en, this message translates to:
  /// **'I don\'t like it'**
  String get ratingBad;

  /// Read out by screen readers for the neutral face.
  ///
  /// In en, this message translates to:
  /// **'It\'s okay'**
  String get ratingOkay;

  /// Read out by screen readers for the happy face.
  ///
  /// In en, this message translates to:
  /// **'I love it'**
  String get ratingGood;

  /// Title of the trip form, at most about 22 characters.
  ///
  /// In en, this message translates to:
  /// **'Plan Your Trip'**
  String get tripTitle;

  /// Read out by screen readers.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String tripStepLabel(int step, int total);

  /// No description provided for @tripPlanning.
  ///
  /// In en, this message translates to:
  /// **'Planning your trip…'**
  String get tripPlanning;

  /// No description provided for @tripShowResults.
  ///
  /// In en, this message translates to:
  /// **'Show Results'**
  String get tripShowResults;

  /// No description provided for @deleteTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Trip?'**
  String get deleteTripTitle;

  /// No description provided for @deleteTripText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this trip? This action cannot be undone.'**
  String get deleteTripText;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// The length of a stay.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String tripDays(int count);

  /// No description provided for @savedPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Tailored Itinerary'**
  String get savedPlanTitle;

  /// Title of an itinerary; location is what the user typed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1-day stay in {location}} other{{count}-day stay in {location}}}'**
  String itineraryStay(int count, String location);

  /// No description provided for @plannerErrorOffline.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the trip planner. Check your internet connection and try again.'**
  String get plannerErrorOffline;

  /// No description provided for @plannerErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The trip planner took too long to answer. Please try again.'**
  String get plannerErrorTimeout;

  /// No description provided for @plannerErrorBusy.
  ///
  /// In en, this message translates to:
  /// **'The trip planner is busy right now. Please try again in a minute.'**
  String get plannerErrorBusy;

  /// No description provided for @plannerErrorServer.
  ///
  /// In en, this message translates to:
  /// **'The trip planner is having problems. Please try again later.'**
  String get plannerErrorServer;

  /// No description provided for @plannerErrorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The trip planner is unavailable right now. Please try again later.'**
  String get plannerErrorUnavailable;

  /// No description provided for @plannerErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'We could not create your plan this time. Please try again.'**
  String get plannerErrorGeneric;

  /// No description provided for @planFreeTime.
  ///
  /// In en, this message translates to:
  /// **'Free time: relax near your accommodation or go back to a favorite place from the other days.'**
  String get planFreeTime;

  /// No description provided for @planDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Day {number}'**
  String planDayTitle(int number);

  /// No description provided for @planDayThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Day {number}: {theme}'**
  String planDayThemeTitle(int number, String theme);

  /// No description provided for @planFreeDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Day {number}: Free day'**
  String planFreeDayTitle(int number);

  /// No description provided for @planGettingThere.
  ///
  /// In en, this message translates to:
  /// **'Getting there: {travel}'**
  String planGettingThere(String travel);

  /// Starts an activity of an itinerary, with its colon.
  ///
  /// In en, this message translates to:
  /// **'Breakfast:'**
  String get planBreakfast;

  /// Starts an activity of an itinerary, with its colon.
  ///
  /// In en, this message translates to:
  /// **'Morning:'**
  String get planMorning;

  /// Starts an activity of an itinerary, with its colon.
  ///
  /// In en, this message translates to:
  /// **'Lunch:'**
  String get planLunch;

  /// Starts an activity of an itinerary, with its colon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon:'**
  String get planAfternoon;

  /// Starts an activity of an itinerary, with its colon.
  ///
  /// In en, this message translates to:
  /// **'Dinner:'**
  String get planDinner;

  /// Starts an activity of an itinerary, with its colon.
  ///
  /// In en, this message translates to:
  /// **'Evening:'**
  String get planEvening;

  /// Starts an activity of an itinerary, with its colon.
  ///
  /// In en, this message translates to:
  /// **'Night:'**
  String get planNight;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get interestRestaurants;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Attractions'**
  String get interestAttractions;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Cafes'**
  String get interestCafes;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Breakfast and brunch'**
  String get interestBreakfast;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Bakeries'**
  String get interestBakeries;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Bars'**
  String get interestBars;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get interestShopping;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Nightlife'**
  String get interestNightlife;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Museums'**
  String get interestMuseums;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Art museums'**
  String get interestArtMuseums;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Science & space museums'**
  String get interestScienceMuseums;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Theme parks'**
  String get interestThemeParks;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Arts and culture'**
  String get interestArtsCulture;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Parks and gardens'**
  String get interestParks;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Beaches'**
  String get interestBeaches;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Pools'**
  String get interestPools;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Asian food'**
  String get interestAsianFood;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Sushi'**
  String get interestSushi;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Pizzas'**
  String get interestPizzas;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Gelato'**
  String get interestGelato;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Desserts'**
  String get interestDesserts;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Rooftops'**
  String get interestRooftops;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Fun things to do'**
  String get interestFun;

  /// Something a traveler can be interested in, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Spas'**
  String get interestSpas;

  /// The name of a part of Dubai, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Dubai Marina'**
  String get areaDubaiMarina;

  /// The name of a part of Dubai, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Palm Jumeirah'**
  String get areaPalmJumeirah;

  /// The name of a part of Dubai, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Oud Metha'**
  String get areaOudMetha;

  /// The name of a part of Dubai, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Al Barsha'**
  String get areaAlBarsha;

  /// The name of a part of Dubai, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Bur Dubai'**
  String get areaBurDubai;

  /// The name of a part of Dubai, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Jumeirah'**
  String get areaJumeirah;

  /// The name of a part of Dubai, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Dubai World Trade Centre (DWTC)'**
  String get areaTradeCentre;

  /// The name of a part of Dubai, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Deira'**
  String get areaDeira;

  /// The name of a part of Dubai, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Jebel Ali'**
  String get areaJebelAli;

  /// The name of a part of Dubai, on a small selectable chip.
  ///
  /// In en, this message translates to:
  /// **'Downtown Dubai'**
  String get areaDowntownDubai;

  /// No description provided for @tripArrivalTitle.
  ///
  /// In en, this message translates to:
  /// **'When do you arrive?'**
  String get tripArrivalTitle;

  /// No description provided for @tripArrivalText.
  ///
  /// In en, this message translates to:
  /// **'Pick your arrival day and length of stay.'**
  String get tripArrivalText;

  /// No description provided for @tripHowManyDays.
  ///
  /// In en, this message translates to:
  /// **'How many days?'**
  String get tripHowManyDays;

  /// days is always the longest stay one plan can cover, 15; date is a short date.
  ///
  /// In en, this message translates to:
  /// **'Staying longer? Plan these {days} days first, then start a new plan from {date}.'**
  String tripStayingLonger(int days, String date);

  /// No description provided for @tripLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Where are you staying?'**
  String get tripLocationTitle;

  /// No description provided for @tripLocationText.
  ///
  /// In en, this message translates to:
  /// **'Your hotel or area, so days start close by.'**
  String get tripLocationText;

  /// No description provided for @tripLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Hotel name or area'**
  String get tripLocationHint;

  /// No description provided for @tripPopularAreas.
  ///
  /// In en, this message translates to:
  /// **'Popular areas'**
  String get tripPopularAreas;

  /// No description provided for @tripInterestsTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you love?'**
  String get tripInterestsTitle;

  /// No description provided for @tripInterestsText.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one to shape your days.'**
  String get tripInterestsText;

  /// No description provided for @tripInterestsGenerating.
  ///
  /// In en, this message translates to:
  /// **'This can take a minute or two.'**
  String get tripInterestsGenerating;

  /// No description provided for @tripMostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most popular'**
  String get tripMostPopular;

  /// No description provided for @tripMoreCategories.
  ///
  /// In en, this message translates to:
  /// **'More categories'**
  String get tripMoreCategories;

  /// No description provided for @itineraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Itinerary'**
  String get itineraryTitle;

  /// No description provided for @itineraryShowGrid.
  ///
  /// In en, this message translates to:
  /// **'Show as a grid'**
  String get itineraryShowGrid;

  /// No description provided for @itineraryShowDeck.
  ///
  /// In en, this message translates to:
  /// **'Show as a deck'**
  String get itineraryShowDeck;

  /// No description provided for @itineraryDayOf.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of {total}'**
  String itineraryDayOf(int day, int total);

  /// No description provided for @itineraryPreviousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get itineraryPreviousDay;

  /// No description provided for @itineraryNextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get itineraryNextDay;

  /// No description provided for @itineraryEditDay.
  ///
  /// In en, this message translates to:
  /// **'Edit this day'**
  String get itineraryEditDay;

  /// No description provided for @itineraryDoneEditing.
  ///
  /// In en, this message translates to:
  /// **'Done editing'**
  String get itineraryDoneEditing;

  /// No description provided for @itineraryDoneCount.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String itineraryDoneCount(int done, int total);

  /// No description provided for @itineraryEmptyDay.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned for this day yet.'**
  String get itineraryEmptyDay;

  /// No description provided for @itineraryAddToDay.
  ///
  /// In en, this message translates to:
  /// **'Add to this day'**
  String get itineraryAddToDay;

  /// No description provided for @itineraryAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to Day {number}'**
  String itineraryAddTitle(int number);

  /// No description provided for @itineraryAddHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Coffee at the Marina'**
  String get itineraryAddHint;

  /// No description provided for @itineraryAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get itineraryAdd;

  /// No description provided for @itineraryItemRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from this day'**
  String get itineraryItemRemoved;

  /// No description provided for @itineraryUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get itineraryUndo;

  /// No description provided for @itineraryMoveItem.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get itineraryMoveItem;
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
      <String>['ar', 'de', 'en', 'fr', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
