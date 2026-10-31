import 'package:dubai_trip_planner/features/categories/ui/categories_screen.dart';
import 'package:dubai_trip_planner/features/explore/ui/explore_screen.dart';
import 'package:dubai_trip_planner/features/my_trip/ui/my_trip_screen.dart';
import 'package:dubai_trip_planner/features/profile/ui/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainScaffold extends StatefulWidget {
  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  final _screens = [
    ExploreScreen(),
    MyTripScreen(),
    CategoryScreen(),
    ProfileScreen(),
  ];

  Widget _buildNavItem({required Widget icon, required int index}) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.all(10), // veći padding = veći krug
        decoration: isSelected
            ? BoxDecoration(
          color: const Color(0xFF101A26),
          shape: BoxShape.circle,
        )
            : null,
        child: IconTheme(
          data: IconThemeData(
            color: isSelected ? Colors.white : Colors.black38,
            size: 30,
          ),
          child: icon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        height: 80, // povećana visina bara
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -3))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(icon: const Icon(Icons.home_filled), index: 0),
            _buildNavItem(
              icon: SvgPicture.asset(
                'assets/icons/my_trip.svg',
                height: 38,
                colorFilter: ColorFilter.mode(
                  _currentIndex == 1 ? Colors.white : Colors.black38,
                  BlendMode.srcIn,
                ),
              ),
              index: 1,
            ),
            _buildNavItem(icon: const Icon(Icons.explore_outlined), index: 2),
            _buildNavItem(icon: const Icon(Icons.person), index: 3),
          ],
        ),
      ),
    );
  }
}
