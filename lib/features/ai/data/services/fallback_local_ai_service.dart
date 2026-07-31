import 'package:nukkad/core/constants/app_constants.dart';
import 'package:nukkad/features/ai/domain/models/ai_feedback.dart';
import 'package:nukkad/features/ai/domain/models/ai_insights.dart';
import 'package:nukkad/features/ai/domain/services/local_ai_service.dart';
import 'package:nukkad/features/listing/domain/models/listing.dart';

/// Fallback offline AI service using deterministic rule-based logic.
/// Operates completely locally without internet, API keys, or cloud services.
class FallbackLocalAiService implements LocalAiService {
  @override
  AiFeedback reviewListingDraft({
    required String title,
    required String description,
    required String category,
    required String approximateArea,
    required String contactPreference,
  }) {
    final List<String> suggestions = [];
    final List<String> highlights = [];
    int score = 0;

    final trimmedTitle = title.trim();
    final trimmedDesc = description.trim();

    // 1. Title Evaluation (Max 30 pts)
    if (trimmedTitle.isEmpty) {
      suggestions.add('Title is missing. Give your listing a clear title.');
    } else if (trimmedTitle.length < AppConstants.minTitleLength) {
      suggestions.add('Title is too short (${trimmedTitle.length}/${AppConstants.minTitleLength} chars). Be more descriptive.');
      score += 10;
    } else {
      score += 30;
      highlights.add('Good title length');
    }

    // 2. Description Evaluation (Max 35 pts)
    if (trimmedDesc.isEmpty) {
      suggestions.add('Description is empty. Add item condition, timing, or details.');
    } else if (trimmedDesc.length < AppConstants.minDescriptionLength) {
      suggestions.add('Description needs more details (${trimmedDesc.length}/${AppConstants.minDescriptionLength} chars). Explain item state or request details.');
      score += 15;
    } else {
      score += 35;
      highlights.add('Detailed description provided');
    }

    // 3. Category Check (Max 15 pts)
    if (category.isEmpty) {
      suggestions.add('Add a category so neighbors can filter easily.');
    } else {
      score += 15;
      highlights.add('Category selected ($category)');
    }

    // 4. Locality Area Check (Max 10 pts)
    if (approximateArea.isEmpty) {
      suggestions.add('Select an approximate area for neighbor safety and context.');
    } else {
      score += 10;
      highlights.add('Approximate area specified');
    }

    // 5. Contact Preference Check (Max 10 pts)
    if (contactPreference.isEmpty) {
      suggestions.add('Select how neighbors should reach out to you.');
    } else {
      score += 10;
      highlights.add('Contact method specified');
    }

    AiQualityTier tier;
    String summary;

    if (score < 50) {
      tier = AiQualityTier.needsWork;
      summary = 'Listing Needs Work';
    } else if (score < 80) {
      tier = AiQualityTier.acceptable;
      summary = 'Acceptable Quality';
    } else {
      tier = AiQualityTier.great;
      summary = 'Great Listing!';
    }

    if (suggestions.isEmpty) {
      suggestions.add('Looks good! Your listing is clear and neighborhood-friendly.');
    }

    return AiFeedback(
      qualityScore: score,
      tier: tier,
      statusSummary: summary,
      suggestions: suggestions,
      highlights: highlights,
    );
  }

  @override
  AiListingInsights analyzeListingForBuyer(Listing listing) {
    final List<AiInsightItem> insights = [];
    int score = 0;

    // 1. Title Analysis
    if (listing.title.trim().length >= 10) {
      score += 25;
      insights.add(const AiInsightItem(
        message: 'Clear and descriptive product title',
        isPositive: true,
      ));
    } else {
      score += 10;
      insights.add(const AiInsightItem(
        message: 'Listing title is relatively brief',
        isPositive: false,
      ));
    }

    // 2. Description Analysis
    if (listing.description.trim().length >= 30) {
      score += 30;
      insights.add(const AiInsightItem(
        message: 'Detailed item condition & usage description',
        isPositive: true,
      ));
    } else {
      score += 10;
      insights.add(const AiInsightItem(
        message: 'Limited listing description details provided',
        isPositive: false,
      ));
    }

    // 3. Product Photo Check
    if (listing.imageUrl.isNotEmpty) {
      score += 25;
      insights.add(const AiInsightItem(
        message: 'Product photo reference uploaded',
        isPositive: true,
      ));
    } else {
      insights.add(const AiInsightItem(
        message: 'No custom photo uploaded by seller',
        isPositive: false,
      ));
    }

    // 4. Locality & Contact Safety
    if (listing.approximateArea.isNotEmpty) {
      score += 10;
      insights.add(AiInsightItem(
        message: 'Locality specified (${listing.approximateArea})',
        isPositive: true,
      ));
    }

    // 5. Offer / Price Transparency
    if (listing.hasDiscount) {
      score += 10;
      insights.add(const AiInsightItem(
        message: 'Transparent offer price with original strikethrough value',
        isPositive: true,
      ));
    } else {
      score += 5;
      insights.add(const AiInsightItem(
        message: 'Standard pricing terms stated',
        isPositive: true,
      ));
    }

    // Cap score at 100
    if (score > 100) score = 100;

    AiQualityTier tier;
    String recommendation;

    if (score >= 80) {
      tier = AiQualityTier.great;
      recommendation =
          'This listing appears complete, transparent, and highly trustworthy for neighborhood trading.';
    } else if (score >= 50) {
      tier = AiQualityTier.acceptable;
      recommendation =
          'Good overall listing quality. Feel free to connect with the seller to clarify any specific item details.';
    } else {
      tier = AiQualityTier.needsWork;
      recommendation =
          'Ask the seller for additional photos or condition details before finalizing a transaction.';
    }

    return AiListingInsights(
      qualityScore: score,
      tier: tier,
      insights: insights,
      recommendation: recommendation,
    );
  }
}
