import 'package:flutter/material.dart';
import 'package:nukkad/core/constants/app_constants.dart';
import 'package:nukkad/shared/widgets/marketplace_screen_template.dart';

/// Buy Marketplace Screen — Displays Buy items only.
class BuyScreen extends StatelessWidget {
  const BuyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MarketplaceScreenTemplate(
      categoryFilter: AppConstants.categoryBuy,
      title: 'Buy Listings',
      subtitle: 'Items requested by local buyers',
      headerIcon: AppConstants.getCategoryIcon(AppConstants.categoryBuy),
      headerColor: AppConstants.getCategoryColor(AppConstants.categoryBuy),
    );
  }
}
