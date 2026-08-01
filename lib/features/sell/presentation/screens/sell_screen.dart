import 'package:flutter/material.dart';
import 'package:nukkad/core/constants/app_constants.dart';
import 'package:nukkad/shared/widgets/marketplace_screen_template.dart';

/// Sell Marketplace Screen — Displays Sell items only.
class SellScreen extends StatelessWidget {
  const SellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MarketplaceScreenTemplate(
      categoryFilter: AppConstants.categorySell,
      title: 'Sell Listings',
      subtitle: 'Items for sale in your neighborhood',
      headerIcon: AppConstants.getCategoryIcon(AppConstants.categorySell),
      headerColor: AppConstants.getCategoryColor(AppConstants.categorySell),
    );
  }
}
