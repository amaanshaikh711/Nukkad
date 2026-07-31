# Local AI Isolation Architecture & Future Migration Note

## Architectural Goal

The **AI Listing Assistant** must remain strictly decoupled from the UI, presentation, and data storage layers.

```
       ┌──────────────────────────────────────┐
       │             UI Layer                 │
       │    (CreateListingScreen / Notifier)  │
       └──────────────────┬───────────────────┘
                          │
                          ▼
       ┌──────────────────────────────────────┐
       │         LocalAiService (Abstract)    │
       │ reviewListingDraft(...) -> AiFeedback│
       └──────────────────┬───────────────────┘
                          │
            ┌─────────────┴─────────────┐
            ▼                           ▼
┌──────────────────────┐    ┌──────────────────────┐
│FallbackLocalAiService│    │ OnDeviceLlmAiService │
│ (Rule-Based Offline) │    │  (ExecuTorch/Gemma)  │
└──────────────────────┘    └──────────────────────┘
```

## Initial Implementation: `FallbackLocalAiService`

The initial service uses deterministic rule-based evaluation:
- **Title Evaluation**: Checks length against `AppConstants.minTitleLength` (10 chars).
- **Description Evaluation**: Checks detail depth against `AppConstants.minDescriptionLength` (20 chars).
- **Metadata Check**: Verifies Category, Locality Area, and Contact Preference.
- **Scoring Engine**: Calculates quality score (0 to 100) and assigns an `AiQualityTier` (`needsWork`, `acceptable`, `great`).

## Future AI Model Migration

If an on-device LLM model (e.g. MediaPipe LLM Inference / ExecuTorch / Gemma 2B) is added in the future:
1. Create a class implementing `LocalAiService` (e.g., `OnDeviceLlmAiService`).
2. Update `localAiServiceProvider` in `lib/features/ai/presentation/providers/ai_providers.dart`:
   ```dart
   final localAiServiceProvider = Provider<LocalAiService>((ref) {
     return OnDeviceLlmAiService();
   });
   ```
3. Zero changes will be required in `CreateListingScreen`, `AiFeedbackCard`, or `CreateListingNotifier`.
