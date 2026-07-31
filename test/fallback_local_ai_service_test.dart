import 'package:flutter_test/flutter_test.dart';
import 'package:nukkad/features/ai/data/services/fallback_local_ai_service.dart';
import 'package:nukkad/features/ai/domain/models/ai_feedback.dart';
import 'package:nukkad/features/listing/domain/models/listing.dart';

void main() {
  group('FallbackLocalAiService Unit Tests', () {
    late FallbackLocalAiService aiService;

    setUp(() {
      aiService = FallbackLocalAiService();
    });

    test('Short title and description trigger warnings and low quality score', () {
      final feedback = aiService.reviewListingDraft(
        title: 'Table',
        description: 'Used table.',
        category: '',
        approximateArea: '',
        contactPreference: '',
      );

      expect(feedback.tier, equals(AiQualityTier.needsWork));
      expect(feedback.qualityScore, lessThan(50));
      expect(feedback.suggestions, contains(contains('Title is too short')));
      expect(feedback.suggestions, contains(contains('Description needs more details')));
      expect(feedback.suggestions, contains(contains('Add a category')));
    });

    test('Detailed draft produces high quality score and Great tier', () {
      final feedback = aiService.reviewListingDraft(
        title: 'Solid Oak Dining Table with 4 Wooden Chairs',
        description: 'Excellent condition oak wood dining table. Used for 1 year, no scratches or stains.',
        category: 'Sell',
        approximateArea: 'Sector 15 Main Market',
        contactPreference: 'WhatsApp Message',
      );

      expect(feedback.tier, equals(AiQualityTier.great));
      expect(feedback.qualityScore, equals(100));
      expect(feedback.isReadyToPublish, isTrue);
      expect(feedback.highlights, contains('Good title length'));
      expect(feedback.highlights, contains('Detailed description provided'));
    });

    test('analyzeListingForBuyer generates AI Trust Insights & Recommendation', () {
      final now = DateTime.now();
      final listing = Listing(
        id: 'test-ai-1',
        title: 'Samsung 24-inch Full HD IPS LED Monitor',
        description: 'Samsung 24-inch borderless IPS display with 75Hz refresh rate, HDMI, and DisplayPort cables included. Crisp colors.',
        category: 'Sell',
        price: '₹4,800',
        originalPrice: '₹6,500',
        imageUrl: 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf',
        approximateArea: 'Green Park Blocks A-D',
        contactPreference: 'Phone Call',
        createdAt: now,
        updatedAt: now,
      );

      final insights = aiService.analyzeListingForBuyer(listing);

      expect(insights.qualityScore, greaterThanOrEqualTo(80));
      expect(insights.tier, equals(AiQualityTier.great));
      expect(insights.insights.length, greaterThanOrEqualTo(3));
      expect(insights.recommendation, contains('trustworthy'));
    });
  });
}
