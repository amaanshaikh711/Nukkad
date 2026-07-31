import 'package:flutter/material.dart';
import 'package:nukkad/features/ai/domain/models/ai_feedback.dart';

class AiInsightItem {
  final String message;
  final bool isPositive;

  const AiInsightItem({
    required this.message,
    required this.isPositive,
  });

  IconData get icon =>
      isPositive ? Icons.check_circle_rounded : Icons.warning_rounded;

  Color get color =>
      isPositive ? const Color(0xFF059669) : const Color(0xFFD97706);
}

class AiListingInsights {
  final int qualityScore;
  final AiQualityTier tier;
  final List<AiInsightItem> insights;
  final String recommendation;

  const AiListingInsights({
    required this.qualityScore,
    required this.tier,
    required this.insights,
    required this.recommendation,
  });

  Color get scoreColor {
    if (qualityScore >= 80) return const Color(0xFF059669);
    if (qualityScore >= 50) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  String get scoreBadgeText {
    if (qualityScore >= 80) return 'High Trust & Quality';
    if (qualityScore >= 50) return 'Moderate Quality';
    return 'Needs Verification';
  }
}
