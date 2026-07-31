import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nukkad/features/listing/presentation/providers/listing_providers.dart';
import 'package:nukkad/shared/widgets/listing_card.dart';

class SavedListingsScreen extends ConsumerWidget {
  const SavedListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final savedListings = ref.watch(savedListingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Listings'),
      ),
      body: savedListings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved listings yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the bookmark icon on any listing to save it offline.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Browse Feed'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: savedListings.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final listing = savedListings[index];
                return ListingCard(
                  listing: listing,
                  onTap: () => context.push('/details/${listing.id}'),
                  onToggleSave: () {
                    ref.read(listingListNotifierProvider.notifier).toggleSave(listing.id);
                  },
                );
              },
            ),
    );
  }
}
