import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nukkad/core/constants/app_constants.dart';
import 'package:nukkad/features/ai/domain/models/ai_feedback.dart';
import 'package:nukkad/features/ai/domain/services/local_ai_service.dart';
import 'package:nukkad/features/ai/presentation/providers/ai_providers.dart';
import 'package:nukkad/features/listing/domain/models/listing.dart';
import 'package:nukkad/features/listing/presentation/providers/listing_providers.dart';
import 'package:uuid/uuid.dart';

class CreateListingState {
  final String title;
  final String description;
  final String category;
  final String price;
  final String imageUrl;
  final String approximateArea;
  final String contactPreference;
  final AiFeedback aiFeedback;
  final bool isSubmitting;
  final String? errorMessage;

  CreateListingState({
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.approximateArea,
    required this.contactPreference,
    required this.aiFeedback,
    this.isSubmitting = false,
    this.errorMessage,
  });

  CreateListingState copyWith({
    String? title,
    String? description,
    String? category,
    String? price,
    String? imageUrl,
    String? approximateArea,
    String? contactPreference,
    AiFeedback? aiFeedback,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return CreateListingState(
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      approximateArea: approximateArea ?? this.approximateArea,
      contactPreference: contactPreference ?? this.contactPreference,
      aiFeedback: aiFeedback ?? this.aiFeedback,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class CreateListingNotifier extends StateNotifier<CreateListingState> {
  final LocalAiService _aiService;
  final Ref _ref;

  CreateListingNotifier(this._aiService, this._ref)
      : super(
          CreateListingState(
            title: '',
            description: '',
            category: AppConstants.categorySell,
            price: '₹1,500',
            imageUrl: '',
            approximateArea: AppConstants.approximateAreas.first,
            contactPreference: AppConstants.contactPreferences.first,
            aiFeedback: _aiService.reviewListingDraft(
              title: '',
              description: '',
              category: AppConstants.categorySell,
              approximateArea: AppConstants.approximateAreas.first,
              contactPreference: AppConstants.contactPreferences.first,
            ),
          ),
        );

  void updateTitle(String newTitle) {
    state = state.copyWith(title: newTitle);
    _reevaluateAi();
  }

  void updateDescription(String newDescription) {
    state = state.copyWith(description: newDescription);
    _reevaluateAi();
  }

  void updateCategory(String newCategory) {
    state = state.copyWith(category: newCategory);
    _reevaluateAi();
  }

  void updatePrice(String newPrice) {
    state = state.copyWith(price: newPrice);
  }

  void updateImageUrl(String newUrl) {
    state = state.copyWith(imageUrl: newUrl);
  }

  void updateArea(String newArea) {
    state = state.copyWith(approximateArea: newArea);
    _reevaluateAi();
  }

  void updateContactPreference(String newPreference) {
    state = state.copyWith(contactPreference: newPreference);
    _reevaluateAi();
  }

  void _reevaluateAi() {
    final feedback = _aiService.reviewListingDraft(
      title: state.title,
      description: state.description,
      category: state.category,
      approximateArea: state.approximateArea,
      contactPreference: state.contactPreference,
    );
    state = state.copyWith(aiFeedback: feedback);
  }

  Future<bool> submitListing() async {
    if (state.title.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter a listing title');
      return false;
    }
    if (state.description.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter a description');
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final now = DateTime.now();
      final newListing = Listing(
        id: const Uuid().v4(),
        title: state.title.trim(),
        description: state.description.trim(),
        category: state.category,
        price: state.price.trim().isEmpty ? 'Contact for details' : state.price.trim(),
        imageUrl: state.imageUrl.trim(),
        approximateArea: state.approximateArea,
        contactPreference: state.contactPreference,
        status: AppConstants.statusActive,
        isSaved: false,
        createdAt: now,
        updatedAt: now,
      );

      final repository = _ref.read(listingRepositoryProvider);
      await repository.createListing(newListing);

      await _ref.read(listingListNotifierProvider.notifier).loadListings();

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to create listing: $e',
      );
      return false;
    }
  }

  void resetForm() {
    state = CreateListingState(
      title: '',
      description: '',
      category: AppConstants.categorySell,
      price: '₹1,500',
      imageUrl: '',
      approximateArea: AppConstants.approximateAreas.first,
      contactPreference: AppConstants.contactPreferences.first,
      aiFeedback: _aiService.reviewListingDraft(
        title: '',
        description: '',
        category: AppConstants.categorySell,
        approximateArea: AppConstants.approximateAreas.first,
        contactPreference: AppConstants.contactPreferences.first,
      ),
    );
  }
}

final createListingNotifierProvider =
    StateNotifierProvider.autoDispose<CreateListingNotifier, CreateListingState>((ref) {
  final aiService = ref.watch(localAiServiceProvider);
  return CreateListingNotifier(aiService, ref);
});
