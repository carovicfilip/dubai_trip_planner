import 'package:dubai_trip_planner/app/theme/app_theme.dart';
import 'package:dubai_trip_planner/app/theme/theme_cubit.dart';
import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:dubai_trip_planner/core/widgets/gradient_hero.dart';
import 'package:dubai_trip_planner/core/widgets/places_card.dart';
import 'package:dubai_trip_planner/features/favorites/cubit/favorites_cubit.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/widgets/promo_banner.dart';
import 'package:dubai_trip_planner/features/place_details/ui/place_details_screen.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesState = context.watch<FavoritesCubit>().state;
    final favoritePlaces = favoritesState.favoritesList;
    final palette = context.palette;
    final l10n = context.l10n;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Over the dark header, in both themes.
      value: AppTheme.statusBarOnDark,
      child: Scaffold(
        body: HeroListView(
          statusBarOverPage: AppTheme.statusBarFor(context),
          padding: const EdgeInsets.only(bottom: 10),
          children: [
            GradientHero(lightTitle: l10n.profileHeroLight, boldTitle: l10n.profileHeroBold, child: const PromoBanner()),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.favoritesTitle, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  if (favoritePlaces.isEmpty)
                    Container(
                      height: 160,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: palette.card,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: palette.hairline),
                      ),
                      child: Text(l10n.favoritesEmpty, style: TextStyle(color: palette.muted)),
                    )
                  else
                    SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: favoritePlaces.length,
                        itemBuilder: (context, index) {
                          final place = favoritePlaces[index];
                          return Padding(
                            padding: const EdgeInsetsDirectional.only(end: 16),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => PlaceDetailsScreen(place: place)),
                                );
                              },
                              child: PlacesCard(
                                place: place,
                                isFavorite: favoritesState.isFavorite(place.id),
                                onFavoriteToggle: () => context.read<FavoritesCubit>().toggleFavorite(place),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: Text(l10n.darkTheme),
                    value: context.watch<ThemeCubit>().state == ThemeMode.dark,
                    onChanged: context.read<ThemeCubit>().setDark,
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: Text(l10n.privacyPolicy),
                    onTap: () async {
                      final uri = Uri.parse('https://dubai-trip-planner.com/privacy-policy');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: Text(l10n.termsOfUse),
                    onTap: () async {
                      final uri = Uri.parse('https://dubai-trip-planner.com/terms-of-use');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  // ListTile(leading: Icon(Icons.support_agent), title: Text("Support"), onTap: () {}),
                  // ListTile(leading: Icon(Icons.star_rate), title: Text("Rate the app"), onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
