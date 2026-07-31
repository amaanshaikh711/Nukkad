import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nukkad/core/constants/app_constants.dart';
import 'package:nukkad/features/listing/presentation/providers/listing_providers.dart';
import 'package:nukkad/shared/widgets/listing_card.dart';

class HomeFeedScreen extends ConsumerStatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  ConsumerState<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredListings = ref.watch(filteredListingsProvider);
    final selectedCategory = ref.watch(selectedCategoryFilterProvider);
    final savedListings = ref.watch(savedListingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.storefront_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Offline Local Loop',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Saved Items Action
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.bookmark_outline_rounded,
                    color: Color(0xFF0F172A)),
                tooltip: 'Saved Listings',
                onPressed: () => context.push('/saved'),
              ),
              if (savedListings.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${savedListings.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon:
                const Icon(Icons.settings_outlined, color: Color(0xFF0F172A)),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: () async {
          await ref.read(listingListNotifierProvider.notifier).loadListings();
        },
        child: Column(
          children: [
            // Locality Header Banner & Search Box
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Field
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        ref.read(searchQueryProvider.notifier).state = val;
                      },
                      decoration: InputDecoration(
                        hintText: 'Search items, area, or keywords...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(Icons.search,
                            color: Color(0xFF64748B)),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    color: Color(0xFF64748B)),
                                onPressed: () {
                                  _searchController.clear();
                                  ref
                                      .read(searchQueryProvider.notifier)
                                      .state = '';
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Category Filter Horizontal Bar
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // "All" Chip
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: const Text('All Feed'),
                            selected: selectedCategory == null,
                            selectedColor: theme.colorScheme.primary,
                            labelStyle: TextStyle(
                              color: selectedCategory == null
                                  ? Colors.white
                                  : const Color(0xFF334155),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            onSelected: (_) {
                              ref
                                  .read(selectedCategoryFilterProvider.notifier)
                                  .state = null;
                            },
                          ),
                        ),
                        // Individual Categories
                        ...AppConstants.categories.map((cat) {
                          final isSelected = selectedCategory == cat;
                          final categoryColor =
                              AppConstants.getCategoryColor(cat);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              avatar: Icon(
                                AppConstants.getCategoryIcon(cat),
                                size: 16,
                                color: isSelected ? Colors.white : categoryColor,
                              ),
                              label: Text(cat),
                              selected: isSelected,
                              selectedColor: categoryColor,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF334155),
                                fontWeight: isSelected ? FontWeight.bold : null,
                                fontSize: 13,
                              ),
                              onSelected: (_) {
                                ref
                                    .read(selectedCategoryFilterProvider.notifier)
                                    .state = isSelected ? null : cat;
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Feed Content List
            Expanded(
              child: filteredListings.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.search_off_rounded,
                                size: 56,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No neighborhood listings found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search query or switching categories.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredListings.length,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemBuilder: (context, index) {
                        final listing = filteredListings[index];
                        return ListingCard(
                          listing: listing,
                          onTap: () => context.push('/details/${listing.id}'),
                          onToggleSave: () {
                            ref
                                .read(listingListNotifierProvider.notifier)
                                .toggleSave(listing.id);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create'),
        icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
        label: const Text(
          'Post Listing',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        tooltip: 'Create a new local listing',
      ),
    );
  }
}
