import 'package:flutter/material.dart';

/// Centralized application constants for Nukkad.
class AppConstants {
  AppConstants._();

  static const String appName = 'Nukkad';
  static const String appTagline = 'Buy, Sell, Lend & Help';

  // Storage Keys
  static const String listingsBoxName = 'nukkad_listings_box';
  static const String settingsBoxName = 'nukkad_settings_box';

  // Categories
  static const String categoryBuy = 'Buy';
  static const String categorySell = 'Sell';
  static const String categoryLend = 'Lend';
  static const String categoryHelp = 'Help';

  static const List<String> categories = [
    categoryBuy,
    categorySell,
    categoryLend,
    categoryHelp,
  ];

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case categoryBuy:
        return Icons.shopping_bag_outlined;
      case categorySell:
        return Icons.sell_outlined;
      case categoryLend:
        return Icons.handshake_outlined;
      case categoryHelp:
        return Icons.volunteer_activism_outlined;
      default:
        return Icons.local_offer_outlined;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category) {
      case categoryBuy:
        return const Color(0xFF1E88E5); // Blue
      case categorySell:
        return const Color(0xFF43A047); // Green
      case categoryLend:
        return const Color(0xFFFB8C00); // Orange
      case categoryHelp:
        return const Color(0xFF8E24AA); // Purple
      default:
        return const Color(0xFF5E35B1);
    }
  }

  // Locality Areas (Approximate only - Privacy focus)
  static const List<String> approximateAreas = [
    'Sector 15 Main Market',
    'Green Park Blocks A-D',
    'Station Road & West End',
    'Civil Lines Locality',
    'University North Campus',
    'Old Town Square',
  ];

  // Contact Preferences
  static const String contactPrefWhatsApp = 'WhatsApp Message';
  static const String contactPrefCall = 'Phone Call';
  static const String contactPrefInPerson = 'In-Person Meetup';

  static const List<String> contactPreferences = [
    contactPrefWhatsApp,
    contactPrefCall,
    contactPrefInPerson,
  ];

  // Listing Statuses
  static const String statusActive = 'Active';
  static const String statusContacted = 'Contacted';
  static const String statusClosed = 'Closed';

  // Quality Thresholds for AI
  static const int minTitleLength = 10;
  static const int minDescriptionLength = 20;
}
