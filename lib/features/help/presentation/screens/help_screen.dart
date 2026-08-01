import 'package:flutter/material.dart';
import 'package:nukkad/core/constants/app_constants.dart';
import 'package:nukkad/shared/widgets/marketplace_screen_template.dart';

/// Help/Request Marketplace Screen — Displays Help items only.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MarketplaceScreenTemplate(
      categoryFilter: AppConstants.categoryHelp,
      title: 'Help & Service Requests',
      subtitle: 'Community assistance and local service requests',
      headerIcon: AppConstants.getCategoryIcon(AppConstants.categoryHelp),
      headerColor: AppConstants.getCategoryColor(AppConstants.categoryHelp),
    );
  }
}
