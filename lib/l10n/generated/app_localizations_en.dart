// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dubai Trip Planner';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get dubaiLabel => 'DUBAI';

  @override
  String get next => 'Next';

  @override
  String get listSeparator => ', ';

  @override
  String get navExplore => 'Explore';

  @override
  String get navMyTrip => 'My Trip';

  @override
  String get navCategories => 'Categories';

  @override
  String get navProfile => 'Profile';

  @override
  String get exploreHeroLight => 'Welcome to';

  @override
  String get exploreHeroBold => 'Dubai!';

  @override
  String get mostPopularTitle => 'Most Popular Places';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get recommendedTitle => 'Recommended';

  @override
  String get weatherTitle => 'Weather Forecast';

  @override
  String get tipsTitle => 'Hack & Tips';

  @override
  String get tipNolCardTitle => 'Use Nol Card for Transport';

  @override
  String get tipNolCardText =>
      'Pay less for metro, buses, and water taxis by using a Nol card.';

  @override
  String get tipSunsetTitle => 'Burj Khalifa Sunset View';

  @override
  String get tipSunsetText =>
      'Visit around 4–5 PM to catch both daylight and sunset views.';

  @override
  String get tipWaterTitle => 'Stay Hydrated';

  @override
  String get tipWaterText =>
      'Dubai heat is intense! Always carry water while exploring.';

  @override
  String get tipSafariTitle => 'Book Desert Safari Early';

  @override
  String get tipSafariText =>
      'Book online in advance to get better deals and avoid scams.';

  @override
  String get tipCareemTitle => 'Use Careem App';

  @override
  String get tipCareemText =>
      'Cheaper than Uber and better tailored for Dubai.';

  @override
  String get tipDressTitle => 'Respect Dress Code';

  @override
  String get tipDressText =>
      'Wear modest clothes in malls and religious places.';

  @override
  String get tipBargainTitle => 'Bargain in Gold Souk';

  @override
  String get tipBargainText =>
      'Negotiating is expected. Don\'t accept the first price!';

  @override
  String get tipFridayTitle => 'Souks Open Late on Fridays';

  @override
  String get tipFridayText =>
      'Many Gold Souk shops open only in the afternoon on Fridays.';

  @override
  String get tipTaxFreeTitle => 'Ask for Tax-Free Shopping';

  @override
  String get tipTaxFreeText =>
      'Get VAT refunds at the airport with a tax-free receipt.';

  @override
  String get tipAbraTitle => 'Ride an Abra';

  @override
  String get tipAbraText =>
      'Cross Dubai Creek for 1 AED on a traditional wooden boat.';

  @override
  String get promoTitle => 'Your perfect Dubai trip,\nplanned in minutes';

  @override
  String get promoText => 'Dates, hotel, interests.\nWe do the rest.';

  @override
  String get promoButton => 'Plan My Trip';

  @override
  String get onboardingDiscoverLabel => 'DISCOVER';

  @override
  String get onboardingDiscoverTitle => 'Dubai\'s Best,\nAll in One Place';

  @override
  String get onboardingDiscoverText =>
      'No more endless searching. Top places, handpicked and ready to explore.';

  @override
  String get onboardingExploreLabel => 'EXPLORE';

  @override
  String get onboardingExploreTitle => 'Find Your Way\nAround Dubai';

  @override
  String get onboardingExploreText =>
      'Opening hours, locations, your favorites and the weather, all at hand.';

  @override
  String get onboardingPlanLabel => 'PLAN';

  @override
  String get onboardingPlanTitle => 'Your Days,\nPlanned for You';

  @override
  String get onboardingPlanText =>
      'A day-by-day itinerary built around your hotel and your interests.';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get splashTitle => 'Welcome Back';

  @override
  String get splashText =>
      'Your next adventure is waiting. Let\'s pick up where you left off.';

  @override
  String get profileHeroLight => 'Your';

  @override
  String get profileHeroBold => 'Profile';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesEmpty => 'You haven\'t added any favorites yet.';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get categoriesScreenTitle => 'Explore Categories';

  @override
  String get categoryEmpty => 'No places found for this category yet.';

  @override
  String get categoryMustSee => 'Must-See';

  @override
  String get categoryRestaurants => 'Restaurants';

  @override
  String get categoryNightlife => 'Nightlife';

  @override
  String get categoryBeachesPools => 'Beaches & Pools';

  @override
  String get categoryCultureMuseums => 'Culture & Museums';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryDesertAdventure => 'Desert Adventure';

  @override
  String get categoryFamilyFun => 'Family Fun';

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get savedToFavorites => 'Saved to Favorites';

  @override
  String get placeAbout => 'About';

  @override
  String get placeRating => 'Rating';

  @override
  String get placeOpeningHours => 'Opening hours';

  @override
  String get noReviews => 'No reviews yet';

  @override
  String reviewCount(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted reviews',
      one: '$formatted review',
    );
    return '$_temp0';
  }

  @override
  String reviewSummary(String rating, String reviews) {
    return '$rating ($reviews)';
  }

  @override
  String get weatherUnavailable => 'The forecast is unavailable right now.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get weatherDatePattern => 'd MMMM';

  @override
  String get ratingQuestion => 'How do you like\nthe app so far?';

  @override
  String get ratingBad => 'I don\'t like it';

  @override
  String get ratingOkay => 'It\'s okay';

  @override
  String get ratingGood => 'I love it';

  @override
  String get tripTitle => 'Plan Your Trip';

  @override
  String tripStepLabel(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get tripPlanning => 'Planning your trip…';

  @override
  String get tripShowResults => 'Show Results';

  @override
  String get deleteTripTitle => 'Delete Trip?';

  @override
  String get deleteTripText =>
      'Are you sure you want to delete this trip? This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String tripDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get savedPlanTitle => 'Your Tailored Itinerary';

  @override
  String itineraryStay(int count, String location) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-day stay in $location',
      one: '1-day stay in $location',
    );
    return '$_temp0';
  }

  @override
  String get plannerErrorOffline =>
      'Could not reach the trip planner. Check your internet connection and try again.';

  @override
  String get plannerErrorTimeout =>
      'The trip planner took too long to answer. Please try again.';

  @override
  String get plannerErrorBusy =>
      'The trip planner is busy right now. Please try again in a minute.';

  @override
  String get plannerErrorServer =>
      'The trip planner is having problems. Please try again later.';

  @override
  String get plannerErrorUnavailable =>
      'The trip planner is unavailable right now. Please try again later.';

  @override
  String get plannerErrorGeneric =>
      'We could not create your plan this time. Please try again.';

  @override
  String get planFreeTime =>
      'Free time: relax near your accommodation or go back to a favorite place from the other days.';

  @override
  String planDayTitle(int number) {
    return 'Day $number';
  }

  @override
  String planDayThemeTitle(int number, String theme) {
    return 'Day $number: $theme';
  }

  @override
  String planFreeDayTitle(int number) {
    return 'Day $number: Free day';
  }

  @override
  String planGettingThere(String travel) {
    return 'Getting there: $travel';
  }

  @override
  String get planBreakfast => 'Breakfast:';

  @override
  String get planMorning => 'Morning:';

  @override
  String get planLunch => 'Lunch:';

  @override
  String get planAfternoon => 'Afternoon:';

  @override
  String get planDinner => 'Dinner:';

  @override
  String get planEvening => 'Evening:';

  @override
  String get planNight => 'Night:';

  @override
  String get interestRestaurants => 'Restaurants';

  @override
  String get interestAttractions => 'Attractions';

  @override
  String get interestCafes => 'Cafes';

  @override
  String get interestBreakfast => 'Breakfast and brunch';

  @override
  String get interestBakeries => 'Bakeries';

  @override
  String get interestBars => 'Bars';

  @override
  String get interestShopping => 'Shopping';

  @override
  String get interestNightlife => 'Nightlife';

  @override
  String get interestMuseums => 'Museums';

  @override
  String get interestArtMuseums => 'Art museums';

  @override
  String get interestScienceMuseums => 'Science & space museums';

  @override
  String get interestThemeParks => 'Theme parks';

  @override
  String get interestArtsCulture => 'Arts and culture';

  @override
  String get interestParks => 'Parks and gardens';

  @override
  String get interestBeaches => 'Beaches';

  @override
  String get interestPools => 'Pools';

  @override
  String get interestAsianFood => 'Asian food';

  @override
  String get interestSushi => 'Sushi';

  @override
  String get interestPizzas => 'Pizzas';

  @override
  String get interestGelato => 'Gelato';

  @override
  String get interestDesserts => 'Desserts';

  @override
  String get interestRooftops => 'Rooftops';

  @override
  String get interestFun => 'Fun things to do';

  @override
  String get interestSpas => 'Spas';

  @override
  String get areaDubaiMarina => 'Dubai Marina';

  @override
  String get areaPalmJumeirah => 'Palm Jumeirah';

  @override
  String get areaOudMetha => 'Oud Metha';

  @override
  String get areaAlBarsha => 'Al Barsha';

  @override
  String get areaBurDubai => 'Bur Dubai';

  @override
  String get areaJumeirah => 'Jumeirah';

  @override
  String get areaTradeCentre => 'Dubai World Trade Centre (DWTC)';

  @override
  String get areaDeira => 'Deira';

  @override
  String get areaJebelAli => 'Jebel Ali';

  @override
  String get areaDowntownDubai => 'Downtown Dubai';

  @override
  String get tripArrivalTitle => 'When do you arrive?';

  @override
  String get tripArrivalText => 'Pick your arrival day and length of stay.';

  @override
  String get tripHowManyDays => 'How many days?';

  @override
  String tripStayingLonger(int days, String date) {
    return 'Staying longer? Plan these $days days first, then start a new plan from $date.';
  }

  @override
  String get tripLocationTitle => 'Where are you staying?';

  @override
  String get tripLocationText => 'Your hotel or area, so days start close by.';

  @override
  String get tripLocationHint => 'Hotel name or area';

  @override
  String get tripPopularAreas => 'Popular areas';

  @override
  String get tripInterestsTitle => 'What do you love?';

  @override
  String get tripInterestsText => 'Pick at least one to shape your days.';

  @override
  String get tripInterestsGenerating => 'This can take a minute or two.';

  @override
  String get tripMostPopular => 'Most popular';

  @override
  String get tripMoreCategories => 'More categories';

  @override
  String get itineraryTitle => 'Your Itinerary';

  @override
  String get itineraryShowGrid => 'Show as a grid';

  @override
  String get itineraryShowDeck => 'Show as a deck';

  @override
  String itineraryDayOf(int day, int total) {
    return 'Day $day of $total';
  }

  @override
  String get itineraryPreviousDay => 'Previous day';

  @override
  String get itineraryNextDay => 'Next day';

  @override
  String get itineraryEditDay => 'Edit this day';

  @override
  String get itineraryDoneEditing => 'Done editing';

  @override
  String itineraryDoneCount(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get itineraryEmptyDay => 'Nothing planned for this day yet.';

  @override
  String get itineraryAddToDay => 'Add to this day';

  @override
  String itineraryAddTitle(int number) {
    return 'Add to Day $number';
  }

  @override
  String get itineraryAddHint => 'e.g. Coffee at the Marina';

  @override
  String get itineraryAdd => 'Add';

  @override
  String get itineraryItemRemoved => 'Removed from this day';

  @override
  String get itineraryUndo => 'Undo';

  @override
  String get itineraryMoveItem => 'Move';
}
