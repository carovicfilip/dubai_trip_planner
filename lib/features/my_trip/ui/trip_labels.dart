import 'package:dubai_trip_planner/l10n/l10n.dart';

/// What the screens show for the values of the trip form. The values themselves
/// stay in English: they are saved with a plan and sent to the trip planner.
extension TripLabels on AppLocalizations {
  String interestLabel(String interest) => switch (interest) {
        'Restaurants' => interestRestaurants,
        'Attractions' => interestAttractions,
        'Cafes' => interestCafes,
        'Breakfast and brunch' => interestBreakfast,
        'Bakeries' => interestBakeries,
        'Bars' => interestBars,
        'Shopping' => interestShopping,
        'Nightlife' => interestNightlife,
        'Museums' => interestMuseums,
        'Art museums' => interestArtMuseums,
        'Science & space museums' => interestScienceMuseums,
        'Theme parks' => interestThemeParks,
        'Arts and culture' => interestArtsCulture,
        'Parks and gardens' => interestParks,
        'Beaches' => interestBeaches,
        'Pools' => interestPools,
        'Asian food' => interestAsianFood,
        'Sushi' => interestSushi,
        'Pizzas' => interestPizzas,
        'Gelato' => interestGelato,
        'Desserts' => interestDesserts,
        'Rooftops' => interestRooftops,
        'Fun things to do' => interestFun,
        'Spas' => interestSpas,
        _ => interest,
      };

  /// [area] can also be what the user typed, which stays as it is.
  String areaLabel(String area) => switch (area) {
        'Dubai Marina' => areaDubaiMarina,
        'Palm Jumeirah' => areaPalmJumeirah,
        'Oud Metha' => areaOudMetha,
        'Al Barsha' => areaAlBarsha,
        'Bur Dubai' => areaBurDubai,
        'Jumeirah' => areaJumeirah,
        'Dubai World Trade Centre (DWTC)' => areaTradeCentre,
        'Deira' => areaDeira,
        'Jebel Ali' => areaJebelAli,
        'Downtown Dubai' => areaDowntownDubai,
        _ => area,
      };
}
