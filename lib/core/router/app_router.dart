import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nukkad/features/all/presentation/screens/all_feed_screen.dart';
import 'package:nukkad/features/buy/presentation/screens/buy_screen.dart';
import 'package:nukkad/features/game_zone/presentation/screens/game_zone_screen.dart';
import 'package:nukkad/features/help/presentation/screens/help_screen.dart';
import 'package:nukkad/features/home/presentation/screens/main_navigation_shell.dart';
import 'package:nukkad/features/home/presentation/screens/splash_screen.dart';
import 'package:nukkad/features/lend/presentation/screens/lend_screen.dart';
import 'package:nukkad/features/listing/presentation/screens/create_listing_screen.dart';
import 'package:nukkad/features/listing/presentation/screens/listing_details_screen.dart';
import 'package:nukkad/features/saved/presentation/screens/saved_listings_screen.dart';
import 'package:nukkad/features/sell/presentation/screens/sell_screen.dart';
import 'package:nukkad/features/settings/presentation/screens/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/all',
    ),
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      redirect: (context, state) => '/all',
    ),

    // Primary Stateful Navigation Shell with Material 3 Bottom Navigation Bar
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainNavigationShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: All Marketplace Feed
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/all',
              name: 'all',
              builder: (context, state) => const AllFeedScreen(),
            ),
          ],
        ),
        // Tab 1: Buy Listings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/buy',
              name: 'buy',
              builder: (context, state) => const BuyScreen(),
            ),
          ],
        ),
        // Tab 2: Sell Listings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/sell',
              name: 'sell',
              builder: (context, state) => const SellScreen(),
            ),
          ],
        ),
        // Tab 3: Lend & Borrow Listings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/lend',
              name: 'lend',
              builder: (context, state) => const LendScreen(),
            ),
          ],
        ),
        // Tab 4: Help & Service Requests
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/help',
              name: 'help',
              builder: (context, state) => const HelpScreen(),
            ),
          ],
        ),
        // Tab 5: Game Zone
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/games',
              name: 'games',
              builder: (context, state) => const GameZoneScreen(),
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: '/create',
      name: 'create',
      builder: (context, state) => const CreateListingScreen(),
    ),
    GoRoute(
      path: '/details/:id',
      name: 'details',
      builder: (context, state) {
        final listingId = state.pathParameters['id'] ?? '';
        return ListingDetailsScreen(listingId: listingId);
      },
    ),
    GoRoute(
      path: '/saved',
      name: 'saved',
      builder: (context, state) => const SavedListingsScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Page Not Found')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Route not found: ${state.uri.path}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/all'),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    ),
  ),
);
