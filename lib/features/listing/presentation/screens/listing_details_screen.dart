import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nukkad/core/constants/app_constants.dart';
import 'package:nukkad/features/ai/presentation/providers/ai_providers.dart';
import 'package:nukkad/features/ai/presentation/widgets/ai_insights_card.dart';
import 'package:nukkad/features/listing/domain/models/listing.dart';
import 'package:nukkad/features/listing/presentation/providers/listing_providers.dart';

class ListingDetailsScreen extends ConsumerWidget {
  final String listingId;

  const ListingDetailsScreen({
    super.key,
    required this.listingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final listState = ref.watch(listingListNotifierProvider);
    final aiService = ref.watch(localAiServiceProvider);

    final listingMatches =
        listState.listings.where((item) => item.id == listingId);
    if (listingMatches.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Listing Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Listing not found or deleted.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Back to Feed'),
              ),
            ],
          ),
        ),
      );
    }

    final listing = listingMatches.first;
    final categoryColor = AppConstants.getCategoryColor(listing.category);
    final categoryIcon = AppConstants.getCategoryIcon(listing.category);
    final isClosed = listing.status == AppConstants.statusClosed;
    final isContacted = listing.status == AppConstants.statusContacted;

    // Generate AI Insights for the current listing using isolated LocalAiService
    final aiInsights = aiService.analyzeListingForBuyer(listing);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Hero Product Image Header
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0F172A),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.95),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            actions: [
              // Share Button
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.95),
                  child: IconButton(
                    icon: const Icon(Icons.share_outlined,
                        color: Color(0xFF0F172A)),
                    tooltip: 'Share Listing',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                          text:
                              'Check out this listing on Nukkad: ${listing.title} for ${listing.price} in ${listing.approximateArea}'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Listing link copied to clipboard!'),
                          backgroundColor: Color(0xFF059669),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Save / Bookmark Action Button
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.95),
                  child: IconButton(
                    icon: Icon(
                      listing.isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: listing.isSaved
                          ? theme.colorScheme.primary
                          : const Color(0xFF0F172A),
                    ),
                    tooltip: listing.isSaved ? 'Unsave' : 'Save',
                    onPressed: () {
                      ref
                          .read(listingListNotifierProvider.notifier)
                          .toggleSave(listing.id);
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildHeaderImage(listing.title, listing.imageUrl,
                      categoryColor, categoryIcon),

                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // Category Pill Overlay
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(categoryIcon, size: 14, color: categoryColor),
                          const SizedBox(width: 6),
                          Text(
                            listing.category.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Detailed Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Tag & Posted Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (isClosed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle,
                                  size: 15, color: Color(0xFF64748B)),
                              SizedBox(width: 4),
                              Text('Closed Listing',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF64748B),
                                      fontSize: 12)),
                            ],
                          ),
                        )
                      else if (isContacted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.mark_email_read,
                                  size: 15, color: Color(0xFFD97706)),
                              SizedBox(width: 4),
                              Text('Contact Initiated',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFD97706),
                                      fontSize: 12)),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.fiber_manual_record,
                                  size: 12, color: Color(0xFF059669)),
                              SizedBox(width: 4),
                              Text('Active Local Item',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF059669),
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      Text(
                        'Posted ${DateFormat('MMM d, h:mm a').format(listing.createdAt)}',
                        style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Listing Title
                  Text(
                    listing.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                      decoration:
                          isClosed ? TextDecoration.lineThrough : null,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // PRICE SECTION WITH STRIKETHROUGH OFFER SLASH
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'OFFER PRICE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF64748B),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                alignment: WrapAlignment.start,
                                spacing: 10,
                                runSpacing: 4,
                                children: [
                                  // Current Deal Price
                                  Text(
                                    listing.price,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF059669),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  // Original Strikethrough Price Slash
                                  if (listing.hasDiscount) ...[
                                    Text(
                                      listing.originalPrice,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF94A3B8),
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: Color(0xFFDC2626),
                                        decorationThickness: 2.5,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (listing.hasDiscount)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFF87171)),
                            ),
                            child: const Column(
                              children: [
                                Text(
                                  'NEIGHBOR',
                                  style: TextStyle(
                                    color: Color(0xFFDC2626),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'OFFER',
                                  style: TextStyle(
                                    color: Color(0xFFDC2626),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Locality & Privacy Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.location_on_rounded,
                              color: Color(0xFF059669)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Approximate Locality',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                listing.approximateArea,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Privacy guaranteed: Exact address is never collected.',
                                style: TextStyle(
                                    fontSize: 11, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Description Card
                  const Text(
                    'Item Description & Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      listing.description,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // PREFERRED CONTACT METHOD SECTION (BRAND STYLED)
                  const Text(
                    'Preferred Contact Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),

                  _buildContactCard(context, listing),

                  const SizedBox(height: 26),

                  // 🤖 AI Insights & Trust Section
                  AiInsightsCard(insights: aiInsights),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),

      // STICKY BOTTOM ACTION BAR (MEANINGFUL & USEFUL BUTTONS)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Button 1 (Left): Bookmark / Save Item Toggle
              Expanded(
                flex: 4,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: listing.isSaved
                          ? theme.colorScheme.primary
                          : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  onPressed: () {
                    ref
                        .read(listingListNotifierProvider.notifier)
                        .toggleSave(listing.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(listing.isSaved
                            ? 'Removed from saved listings'
                            : 'Saved to offline listings!'),
                        backgroundColor: theme.colorScheme.primary,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: Icon(
                    listing.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: listing.isSaved
                        ? theme.colorScheme.primary
                        : const Color(0xFF334155),
                    size: 20,
                  ),
                  label: Text(
                    listing.isSaved ? 'Saved' : 'Save Item',
                    style: TextStyle(
                      color: listing.isSaved
                          ? theme.colorScheme.primary
                          : const Color(0xFF334155),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Button 2 (Right - Primary): Connect with Seller / Neighbor
              Expanded(
                flex: 6,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    _showContactModalSheet(context, ref, listing);
                  },
                  icon: Icon(
                    listing.contactPreference.contains('WhatsApp')
                        ? Icons.chat_rounded
                        : listing.contactPreference.contains('Call')
                            ? Icons.phone_rounded
                            : Icons.handshake_rounded,
                    size: 20,
                  ),
                  label: Text(
                    listing.contactPreference.contains('WhatsApp')
                        ? 'WhatsApp Seller'
                        : listing.contactPreference.contains('Call')
                            ? 'Call Seller Now'
                            : 'Arrange Meetup',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Status Menu Trigger (Overflow Options)
              IconButton(
                icon: const Icon(Icons.more_vert_rounded,
                    color: Color(0xFF64748B)),
                tooltip: 'Listing Options & Status',
                onPressed: () {
                  _showStatusOptionsDialog(context, ref, listing);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, Listing listing) {
    final isWhatsApp = listing.contactPreference.contains('WhatsApp');
    final isCall = listing.contactPreference.contains('Call');

    final color = isWhatsApp
        ? const Color(0xFF25D366) // WhatsApp Green
        : isCall
            ? const Color(0xFF2563EB) // Phone Blue
            : const Color(0xFFD97706); // Amber

    final icon = isWhatsApp
        ? Icons.chat_rounded
        : isCall
            ? Icons.phone_rounded
            : Icons.handshake_rounded;

    final btnLabel = isWhatsApp
        ? 'Message on WhatsApp'
        : isCall
            ? 'Call Neighbor Now'
            : 'Plan In-Person Meetup';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.contactPreference,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isWhatsApp
                          ? 'Instant messaging & photo verification'
                          : isCall
                              ? 'Direct mobile audio call with seller'
                              : 'Local pickup in ${listing.approximateArea}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                _showContactModalSheet(context, null, listing);
              },
              icon: Icon(icon, size: 18),
              label: Text(
                btnLabel,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactModalSheet(
      BuildContext context, WidgetRef? ref, Listing listing) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final isWhatsApp = listing.contactPreference.contains('WhatsApp');
        final isCall = listing.contactPreference.contains('Call');

        final brandColor = isWhatsApp
            ? const Color(0xFF25D366)
            : isCall
                ? const Color(0xFF2563EB)
                : const Color(0xFFD97706);

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Connect with Seller',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: brandColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: brandColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isWhatsApp
                          ? Icons.chat_rounded
                          : isCall
                              ? Icons.phone_rounded
                              : Icons.handshake_rounded,
                      color: brandColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Preference: ${listing.contactPreference}\nLocality: ${listing.approximateArea}',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action buttons in modal
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (ref != null) {
                      ref
                          .read(listingListNotifierProvider.notifier)
                          .updateStatus(listing.id, AppConstants.statusContacted);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isWhatsApp
                              ? 'Opening WhatsApp chat for "${listing.title}"...'
                              : isCall
                                  ? 'Initiating phone call to neighbor...'
                                  : 'In-person meeting preference noted!',
                        ),
                        backgroundColor: brandColor,
                      ),
                    );
                  },
                  icon: Icon(
                    isWhatsApp
                        ? Icons.chat_rounded
                        : isCall
                            ? Icons.phone_rounded
                            : Icons.handshake_rounded,
                  ),
                  label: Text(
                    isWhatsApp
                        ? 'Open WhatsApp Chat'
                        : isCall
                            ? 'Dial Phone Call'
                            : 'Confirm In-Person Meetup',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showStatusOptionsDialog(
      BuildContext context, WidgetRef ref, Listing listing) {
    final isClosed = listing.status == AppConstants.statusClosed;
    final isContacted = listing.status == AppConstants.statusContacted;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.tune_rounded, color: Color(0xFF059669)),
            SizedBox(width: 8),
            Text('Listing State Options'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current status: ${listing.status}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.fiber_manual_record, color: Colors.green),
              title: const Text('Mark as Active'),
              subtitle: const Text('Visible in neighborhood feed'),
              onTap: () {
                Navigator.pop(ctx);
                ref
                    .read(listingListNotifierProvider.notifier)
                    .updateStatus(listing.id, AppConstants.statusActive);
              },
            ),
            ListTile(
              leading: const Icon(Icons.mark_email_read, color: Colors.orange),
              title: const Text('Mark as Contacted'),
              subtitle: const Text('Contact initiated with seller'),
              selected: isContacted,
              onTap: () {
                Navigator.pop(ctx);
                ref
                    .read(listingListNotifierProvider.notifier)
                    .updateStatus(listing.id, AppConstants.statusContacted);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.red),
              title: const Text('Mark as Closed'),
              subtitle: const Text('Item sold, lent, or resolved'),
              selected: isClosed,
              onTap: () {
                Navigator.pop(ctx);
                ref
                    .read(listingListNotifierProvider.notifier)
                    .updateStatus(listing.id, AppConstants.statusClosed);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage(
      String title, String imageUrl, Color color, IconData icon) {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildFallbackHeader(title, color, icon),
      );
    }
    return _buildFallbackHeader(title, color, icon);
  }

  Widget _buildFallbackHeader(String title, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.9),
            color,
            const Color(0xFF0F172A),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withOpacity(0.4), width: 2),
              ),
              child: Icon(icon, size: 56, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
