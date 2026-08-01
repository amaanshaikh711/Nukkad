import 'package:flutter/material.dart';
import 'package:nukkad/core/theme/app_theme.dart';
import 'package:nukkad/shared/widgets/marketplace_screen_template.dart';

/// Complete Marketplace Feed ("All" Tab) Screen.
class AllFeedScreen extends StatelessWidget {
  const AllFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MarketplaceScreenTemplate(
      categoryFilter: null,
      title: 'Complete Marketplace Feed',
      subtitle: 'Buy, Sell, Lend & Help in your area',
      headerIcon: Icons.grid_view_rounded,
      headerColor: AppTheme.primarySeed,
    );
  }
}
