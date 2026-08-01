import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nukkad/core/constants/app_constants.dart';
import 'package:nukkad/features/listing/presentation/providers/listing_providers.dart';
import 'package:nukkad/shared/widgets/listing_card.dart';
import 'package:nukkad/shared/widgets/premium_search_bar.dart';

/// Reusable template for Marketplace tab screens (All, Buy, Sell, Lend, Help).
/// Maintains page state and handles search, category filtering, theme styling,
/// pull-to-refresh, empty states, and standard navigation headers.
class MarketplaceScreenTemplate extends ConsumerStatefulWidget {
  final String? categoryFilter;
  final String title;
  final String subtitle;
  final IconData headerIcon;
  final Color headerColor;

  const MarketplaceScreenTemplate({
    super.key,
    required this.categoryFilter,
    required this.title,
    required this.subtitle,
    required this.headerIcon,
    required this.headerColor,
  });

  @override
  ConsumerState<MarketplaceScreenTemplate> createState() =>
      _MarketplaceScreenTemplateState();
}

class _MarketplaceScreenTemplateState
    extends ConsumerState<MarketplaceScreenTemplate>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true; // Preserve page state when switching tabs!

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter listings based on categoryFilter & search query
    final listState = ref.watch(listingListNotifierProvider);
    final searchQuery = ref.watch(searchQueryProvider).trim().toLowerCase();
    final savedListings = ref.watch(savedListingsProvider);

    final filteredListings = listState.listings.where((listing) {
      if (widget.categoryFilter != null &&
          listing.category != widget.categoryFilter) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final titleMatch = listing.title.toLowerCase().contains(searchQuery);
        final descMatch =
            listing.description.toLowerCase().contains(searchQuery);
        final areaMatch =
            listing.approximateArea.toLowerCase().contains(searchQuery);
        return titleMatch || descMatch || areaMatch;
      }
      return true;
    }).toList();

    final bgColor = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final surfaceColor = isDark
        ? const Color(0xFF1E293B)
        : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final titleTextColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 1.5,
        shadowColor: isDark ? Colors.black45 : Colors.black.withOpacity(0.05),
        toolbarHeight: 66,
        titleSpacing: 16,
        title: Row(
          children: [
            // Custom Brand Logo
            Container(
              width: 42,
              height: 42,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: widget.headerColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(8),
                    color: theme.colorScheme.primary,
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),

            // App Title & Subtitle Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        AppConstants.appName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: titleTextColor,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: widget.headerColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: widget.headerColor.withOpacity(0.35),
                          ),
                        ),
                        child: Text(
                          widget.categoryFilter?.toUpperCase() ?? 'ALL',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: widget.headerColor,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: widget.headerColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          widget.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Saved Items Action Button with Badge
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: 20,
                    icon: Icon(
                      Icons.bookmark_outline_rounded,
                      color: titleTextColor,
                    ),
                    tooltip: 'Saved Listings',
                    onPressed: () => context.push('/saved'),
                  ),
                  if (savedListings.isNotEmpty)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF059669), Color(0xFF10B981)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF059669).withOpacity(0.4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${savedListings.length}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Settings Action Button
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 20,
                icon: Icon(
                  Icons.settings_outlined,
                  color: titleTextColor,
                ),
                tooltip: 'Settings',
                onPressed: () => context.push('/settings'),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: () async {
          await ref.read(listingListNotifierProvider.notifier).loadListings();
        },
        child: Column(
          children: [
            // Search Bar & Filter Header Container
            Container(
              color: surfaceColor,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Column(
                children: [
                  PremiumSearchBar(
                    controller: _searchController,
                    hintText: widget.categoryFilter == null
                        ? 'Search all items, areas, keywords...'
                        : 'Search in ${widget.categoryFilter}...',
                    onChanged: (val) {
                      ref.read(searchQueryProvider.notifier).state = val;
                    },
                    onClear: () {
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  ),
                  const SizedBox(height: 10),
                  // Category Status Pill & Count Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(widget.headerIcon,
                              size: 16, color: widget.headerColor),
                          const SizedBox(width: 6),
                          Text(
                            widget.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.headerColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${filteredListings.length} ${filteredListings.length == 1 ? 'item' : 'items'}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: widget.headerColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: borderColor),

            // Listings List or Empty State
            Expanded(
              child: listState.isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : filteredListings.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.search_off_rounded,
                                    size: 56,
                                    color: isDark
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  widget.categoryFilter == null
                                      ? 'No neighborhood listings found'
                                      : 'No ${widget.categoryFilter} listings available',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: titleTextColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try adjusting your search query or check back later.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredListings.length,
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 80),
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
    );
  }
}
