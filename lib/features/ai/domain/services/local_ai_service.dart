import 'package:nukkad/features/ai/domain/models/ai_feedback.dart';
import 'package:nukkad/features/ai/domain/models/ai_insights.dart';
import 'package:nukkad/features/listing/domain/models/listing.dart';

/// Abstract interface for isolated Local AI services.
/// The UI and presentation layers depend ONLY on this abstraction.
abstract class LocalAiService {
  /// Evaluates a draft listing during creation and returns actionable feedback.
  AiFeedback reviewListingDraft({
    required String title,
    required String description,
    required String category,
    required String approximateArea,
    required String contactPreference,
  });

  /// Evaluates a published listing for buyers on the Listing Details page.
  AiListingInsights analyzeListingForBuyer(Listing listing);
}
