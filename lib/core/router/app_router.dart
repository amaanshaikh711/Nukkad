import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nukkad/features/home/presentation/screens/home_feed_screen.dart';
import 'package:nukkad/features/home/presentation/screens/splash_screen.dart';
import 'package:nukkad/features/listing/presentation/screens/create_listing_screen.dart';
import 'package:nukkad/features/listing/presentation/screens/listing_details_screen.dart';
import 'package:nukkad/features/saved/presentation/screens/saved_listings_screen.dart';
import 'package:nukkad/features/settings/presentation/screens/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeFeedScreen(),
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
            onPressed: () => context.go('/home'),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    ),
  ),
);
