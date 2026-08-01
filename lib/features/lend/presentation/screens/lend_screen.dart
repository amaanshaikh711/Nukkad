import 'package:flutter/material.dart';
import 'package:nukkad/core/constants/app_constants.dart';
import 'package:nukkad/shared/widgets/marketplace_screen_template.dart';

/// Lend Marketplace Screen — Displays Lend items only.
class LendScreen extends StatelessWidget {
  const LendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MarketplaceScreenTemplate(
      categoryFilter: AppConstants.categoryLend,
      title: 'Lend Listings',
      subtitle: 'Tools, gear, and items to borrow & share',
      headerIcon: AppConstants.getCategoryIcon(AppConstants.categoryLend),
      headerColor: AppConstants.getCategoryColor(AppConstants.categoryLend),
    );
  }
}
