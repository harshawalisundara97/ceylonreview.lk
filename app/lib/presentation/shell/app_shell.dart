import 'package:flutter/material.dart';

import '../screens/category/category_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/leaderboard/leaderboard_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/write_review/write_review_screen.dart';

/// Signed-in shell: 5-tab bottom navigation per the design system —
/// Home, Map, Post Review (center, filled primary), Feed, Profile.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _tabs = [
    HomeScreen(),
    MapScreen(),
    LeaderboardScreen(),
    WriteReviewScreen(),
    CategoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Map',
          ),
          const NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard_rounded),
            label: 'Ranks',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_rounded,
                color: scheme.primary, size: 32),
            label: 'Post',
          ),
          const NavigationDestination(
            icon: Icon(Icons.dynamic_feed_outlined),
            selectedIcon: Icon(Icons.dynamic_feed_rounded),
            label: 'Feed',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
