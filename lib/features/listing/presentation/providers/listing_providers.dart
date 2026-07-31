import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nukkad/features/listing/data/datasources/listing_local_datasource.dart';
import 'package:nukkad/features/listing/data/repositories/listing_repository.dart';
import 'package:nukkad/features/listing/domain/models/listing.dart';

final listingDatasourceProvider = Provider<ListingLocalDatasource>((ref) {
  return HiveListingLocalDatasource();
});

final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  final datasource = ref.watch(listingDatasourceProvider);
  return ListingRepositoryImpl(datasource: datasource);
});

// Category Filter Provider (null = All)
final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);

// Search Query Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered Listings List State
class ListingListState {
  final List<Listing> listings;
  final bool isLoading;
  final String? errorMessage;

  ListingListState({
    required this.listings,
    this.isLoading = false,
    this.errorMessage,
  });

  ListingListState copyWith({
    List<Listing>? listings,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ListingListState(
      listings: listings ?? this.listings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ListingListNotifier extends StateNotifier<ListingListState> {
  final ListingRepository _repository;

  ListingListNotifier(this._repository)
      : super(ListingListState(listings: [], isLoading: true)) {
    loadListings();
  }

  Future<void> loadListings() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _repository.fetchListings();
      state = state.copyWith(listings: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load listings: $e',
      );
    }
  }

  Future<void> toggleSave(String id) async {
    await _repository.toggleSaveStatus(id);
    await loadListings();
  }

  Future<void> updateStatus(String id, String status) async {
    await _repository.updateStatus(id, status);
    await loadListings();
  }

  Future<void> deleteListing(String id) async {
    await _repository.deleteListing(id);
    await loadListings();
  }
}

final listingListNotifierProvider =
    StateNotifierProvider<ListingListNotifier, ListingListState>((ref) {
  final repository = ref.watch(listingRepositoryProvider);
  return ListingListNotifier(repository);
});

// Filtered Listings Provider (combining Search & Category Filters)
final filteredListingsProvider = Provider<List<Listing>>((ref) {
  final listState = ref.watch(listingListNotifierProvider);
  final selectedCategory = ref.watch(selectedCategoryFilterProvider);
  final searchQuery = ref.watch(searchQueryProvider).trim().toLowerCase();

  return listState.listings.where((listing) {
    // Category match
    if (selectedCategory != null && listing.category != selectedCategory) {
      return false;
    }
    // Search match
    if (searchQuery.isNotEmpty) {
      final titleMatch = listing.title.toLowerCase().contains(searchQuery);
      final descMatch = listing.description.toLowerCase().contains(searchQuery);
      final areaMatch = listing.approximateArea.toLowerCase().contains(searchQuery);
      return titleMatch || descMatch || areaMatch;
    }
    return true;
  }).toList();
});

// Saved Listings Provider
final savedListingsProvider = Provider<List<Listing>>((ref) {
  final listState = ref.watch(listingListNotifierProvider);
  return listState.listings.where((item) => item.isSaved).toList();
});
