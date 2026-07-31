import 'package:flutter/material.dart';

enum AiQualityTier {
  needsWork,
  acceptable,
  great,
}

/// Model representing AI analysis of a listing draft.
class AiFeedback {
  final int qualityScore; // 0 to 100
  final AiQualityTier tier;
  final String statusSummary;
  final List<String> suggestions;
  final List<String> highlights;

  const AiFeedback({
    required this.qualityScore,
    required this.tier,
    required this.statusSummary,
    required this.suggestions,
    required this.highlights,
  });

  bool get isReadyToPublish => qualityScore >= 60;

  Color get tierColor {
    switch (tier) {
      case AiQualityTier.needsWork:
        return const Color(0xFFE53935); // Red
      case AiQualityTier.acceptable:
        return const Color(0xFFFB8C00); // Orange
      case AiQualityTier.great:
        return const Color(0xFF43A047); // Green
    }
  }

  IconData get tierIcon {
    switch (tier) {
      case AiQualityTier.needsWork:
        return Icons.warning_amber_rounded;
      case AiQualityTier.acceptable:
        return Icons.info_outline;
      case AiQualityTier.great:
        return Icons.check_circle_outline;
    }
  }
}
