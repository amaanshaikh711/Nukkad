import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nukkad/core/constants/app_constants.dart';
import 'package:nukkad/features/listing/domain/models/listing.dart';

abstract class ListingLocalDatasource {
  Future<List<Listing>> getListings();
  Future<Listing?> getListingById(String id);
  Future<void> saveListing(Listing listing);
  Future<void> updateListing(Listing listing);
  Future<void> deleteListing(String id);
  Future<void> clearAllData();
  Future<void> seedInitialDataIfEmpty();
}

class HiveListingLocalDatasource implements ListingLocalDatasource {
  Box? _box;
  final Map<String, Map<String, dynamic>> _inMemoryStore = {};
  bool _useInMemoryFallback = false;

  Future<Box?> _getBox() async {
    if (_useInMemoryFallback) return null;
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    try {
      _box = await Hive.openBox(AppConstants.listingsBoxName);
      return _box!;
    } catch (e) {
      if (kDebugMode) {
        print('Hive openBox error, falling back to in-memory: $e');
      }
      _useInMemoryFallback = true;
      return null;
    }
  }

  @override
  Future<List<Listing>> getListings() async {
    final box = await _getBox();
    if (box != null) {
      final items = <Listing>[];
      for (final value in box.values) {
        if (value is Map) {
          try {
            items.add(Listing.fromMap(Map<dynamic, dynamic>.from(value)));
          } catch (_) {}
        }
      }
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    } else {
      final items = _inMemoryStore.values
          .map((map) => Listing.fromMap(map))
          .toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    }
  }

  @override
  Future<Listing?> getListingById(String id) async {
    final box = await _getBox();
    if (box != null) {
      final val = box.get(id);
      if (val is Map) {
        return Listing.fromMap(Map<dynamic, dynamic>.from(val));
      }
      return null;
    } else {
      final map = _inMemoryStore[id];
      if (map != null) return Listing.fromMap(map);
      return null;
    }
  }

  @override
  Future<void> saveListing(Listing listing) async {
    final box = await _getBox();
    if (box != null) {
      await box.put(listing.id, listing.toMap());
    } else {
      _inMemoryStore[listing.id] = listing.toMap();
    }
  }

  @override
  Future<void> updateListing(Listing listing) async {
    final box = await _getBox();
    if (box != null) {
      await box.put(listing.id, listing.toMap());
    } else {
      _inMemoryStore[listing.id] = listing.toMap();
    }
  }

  @override
  Future<void> deleteListing(String id) async {
    final box = await _getBox();
    if (box != null) {
      await box.delete(id);
    } else {
      _inMemoryStore.remove(id);
    }
  }

  @override
  Future<void> clearAllData() async {
    final box = await _getBox();
    if (box != null) {
      await box.clear();
    }
    _inMemoryStore.clear();
  }

  @override
  Future<void> seedInitialDataIfEmpty() async {
    final box = await _getBox();
    final count = box != null ? box.length : _inMemoryStore.length;

    // Clear and reload seed catalog if count is less than 10 to ensure originalPrice offer tags exist
    if (count < 10) {
      if (box != null) {
        await box.clear();
      } else {
        _inMemoryStore.clear();
      }

      final now = DateTime.now();
      final seedListings = [
        // ==========================================
        // SELL CATEGORY (6 Products)
        // ==========================================
        Listing(
          id: 'sell-1',
          title: 'Solid Teak Wooden Study Desk & Ergonomic Chair',
          description:
              'Premium solid teak-wood study desk with 3 lockable drawers and an ergonomic high-back mesh chair. Ideal for work from home or student study setup. Mint condition.',
          category: AppConstants.categorySell,
          price: '₹3,200',
          originalPrice: '₹5,000',
          imageUrl:
              'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=800&auto=format&fit=crop&q=80',
          approximateArea: 'Sector 15 Main Market',
          contactPreference: AppConstants.contactPrefWhatsApp,
          status: AppConstants.statusActive,
          isSaved: true,
          createdAt: now.subtract(const Duration(minutes: 30)),
          updatedAt: now.subtract(const Duration(minutes: 30)),
        ),
        Listing(
          id: 'sell-2',
          title: 'Samsung 24-inch Full HD IPS LED Monitor',
          description:
              'Samsung 24-inch borderless IPS display with 75Hz refresh rate, HDMI, and DisplayPort cables included. Crisp colors, zero dead pixels. Moving out sale.',
          category: AppConstants.categorySell,
          price: '₹4,800',
          originalPrice: '₹6,500',
          imageUrl:
              'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=800&auto=format&fit=crop&q=80',
          approximateArea: 'Green Park Blocks A-D',
          contactPreference: AppConstants.contactPrefCall,
          status: AppConstants.statusActive,
          isSaved: false,
          createdAt: now.subtract(const Duration(hours: 2)),
          updatedAt: now.subtract(const Duration(hours: 2)),
        ),
        Listing(
          id: 'sell-3',
          title: 'Yamaha F310 Acoustic Guitar with Gig Bag & Tuner',
          description:
              'Original Yamaha acoustic dreadnought guitar with rich acoustic resonance. Includes heavy padded gig bag, digital tuner, capo, and spare string pack.',
          category: AppConstants.categorySell,
          price: '₹2,900',
          originalPrice: '₹4,200',
          imageUrl:
              'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=800&auto=format&fit=crop&q=80',
          approximateArea: 'Station Road & West End',
          contactPreference: AppConstants.contactPrefWhatsApp,
          status: AppConstants.statusActive,
          isSaved: true,
          createdAt: now.subtract(const Duration(hours: 4)),
          updatedAt: now.subtract(const Duration(hours: 4)),
        ),
        Listing(
          id: 'sell-4',
          title: 'Hero Sprint 21-Speed Mountain Bicycle',
          description:
              'All-terrain gear bike with front Zoom suspension, dual mechanical disc brakes, alloy rims, mudguards, and night safety reflector kit. Fully serviced.',
          category: AppConstants.categorySell,
          price: '₹5,500',
          originalPrice: '₹8,000',
          imageUrl:
              'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=800&auto=format&fit=crop&q=80',
          approximateArea: 'Civil Lines Locality',
          contactPreference: AppConstants.contactPrefInPerson,
          status: AppConstants.statusActive,
          isSaved: false,
          createdAt: now.subtract(const Duration(hours: 6)),
          updatedAt: now.subtract(const Duration(hours: 6)),
        ),
        Listing(
          id: 'sell-5',
          title: 'Teak Wooden 3-Seater Living Room Sofa',
          description:
              'Handcrafted 3-seater teak wood sofa with thick washable fabric cushions. Sturdy, elegant, and comfortable. Perfect for living room or lounge.',
          category: AppConstants.categorySell,
          price: '₹6,500',
          originalPrice: '₹9,800',
          imageUrl:
              'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800&auto=format&fit=crop&q=80',
          approximateArea: 'Old Town Square',
          contactPreference: AppConstants.contactPrefCall,
          status: AppConstants.statusActive,
          isSaved: false,
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
        Listing(
          id: 'sell-6',
          title: 'Philips Air Fryer XL (4.1 Liter Digital)',
          description:
              'Rapid Air Technology digital air fryer for healthy oil-free cooking. Touchscreen controls with 7 presets. Clean, well maintained, 1 year old.',
          category: AppConstants.categorySell,
          price: '₹3,800',
          originalPrice: '₹5,990',
          imageUrl:
              'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=800&auto=format&fit=crop&q=80',
          approximateArea: 'University North Campus',
          contactPreference: AppConstants.contactPrefWhatsApp,
          status: AppConstants.statusActive,
          isSaved: false,
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 2)),
        ),

        // ==========================================
        // BUY CATEGORY (5 Products)
        // ==========================================
        Listing(
          id: 'buy-1',
          title: 'NCERT Class 10 Science & Maths Textbooks',
          description:
              'Urgent: Looking to buy or borrow NCERT Class 10 Science and Mathematics textbooks for board preparation. Willing to pay up to ₹400.',
          category: AppConstants.categoryBuy,
          price: 'Budget: ₹400',
          originalPrice: 'MSRP: ₹650',
          imageUrl:
              'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=800&auto=format&fit=crop&q=80',
          approximateArea: 'University North Campus',
          contactPreference: AppConstants.contactPrefWhatsApp,
          status: AppConstants.statusContacted,
          isSaved: false,
          createdAt: now.subtract(const Duration(hours: 1)),
          updatedAt: now.subtract(const Duration(minutes: 20)),
        ),
        Listing(
          id: 'buy-2',
          title: 'Looking for Kindle Paperwhite (10th Gen)',
          description:
              'Seeking a pre-owned Kindle Paperwhite e-reader in working condition with display backlight. Budget around ₹4,000.',
          category: AppConstants.categoryBuy,
          price: 'Budget: ₹4,000',
          originalPrice: 'Retail: ₹7,999',
          imageUrl:
              'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=800&auto=format&fit=crop&q=80',
          approximateArea: 'Sector 15 Main Market',
          contactPreference: AppConstants.contactPrefCall,
          status: AppConstants.statusActive,
          isSaved: false,
          createdAt: now.subtract(const Duration(hours: 3)),
          updatedAt: now.subtract(const Duration(hours: 3)),
        ),
        Listing(
          id: 'buy-3',
          title: 'Seeking Compact 20L Solo Microwave Oven',
          description:
              'Need a clean, working solo microwave oven for quick heating. Must be under 3 years old. Willing to pick up directly.',
          category: AppConstants.categoryBuy,
          price: 'Budget: ₹2,500',
          originalPrice: 'Retail: ₹4,200',
          imageUrl:
              'https://images.unsplash.com/photo-1574269909862-7e1d70bb8078?w=800&auto=format&fit=crop&q=80',
          approximateArea: 'Green Park Blocks A-D',
          contactPreference: AppConstants.contactPrefWhatsApp,
          status: AppConstants.statusActive,
          isSaved: false,
          createdAt: now.subtract(const Duration(hours: 5)),
          updatedAt: now.subtract(const Duration(hours: 5)),
        ),
        Listing(
          id: 'buy-4',
          title: 'Rubber Coated Dumbbell Set (5kg - 10kg Pairs)',
          description:
              'Looking for home fitness rubber dumbbells in good condition. Willing to pay fair price for 5kg or 7.5kg pairs.',
          category: AppConstants.categoryBuy,
          price: 'Budget: ₹1,200',
          originalPrice: 'Retail: ₹2,000',
          imageUrl:
              'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?w=800&auto=format&fit=crop&q=80',
          approximateArea: 'Station Road & West End',
          contactPreference: AppConstants.contactPrefInPerson,
          status: AppConstants.statusActive,
          isSaved: false,
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
        Listing(
          id: 'buy-5',
          title: 'Looking for Wooden Office Folding Table',
          description:
              'Need a lightweight portable wooden folding table for laptop WFH setup. Budget around ₹800 - ₹1,000.',
          category: AppConstants.categoryBuy,
          price: 'Budget: ₹1,000',
          originalPrice: 'Retail: ₹1,800',
          imageUrl:
              'https://images.unsplash.com/photo-1530018607912-eff2daa1bac4?w=800&auto=format&fit=crop&q=80',
          approximateArea: 'Civil Lines Locality',
          contactPreference: AppConstants.contactPrefWhatsApp,
          status: AppConstants.statusActive,
          isSaved: false,
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 2)),
        ),

        // ==========================================
        // LEND CATEGORY (5 Products)
        // ==========================================
        Listing(
          id: 'lend-1',
          title: 'Electric Lawn Mower for Weekend Sharing',
          description:
              'Heavy-duty 1400W electric lawn mower with 30L grass collection box. Free to lend to Green Park neighbors for weekend garden maintenance. Please return cleaned!',
          category: AppConstants.categoryLend,
          price: 'Free Lend / Share',
          originalPrice: 'Rental Value: ₹500/day',
          imageUrl:
              'https://images.unsplash.com/photo-1592417817098-8f3d6eb231fc?w=800&auto=format&fit=crop&q=80',
          approximateArea: 'Green Park Blocks A-D',
          contactPreference: AppConstants.contactPrefCall,
          status: AppConstants.statusActive,
          isSaved: false,
          createdAt: now.subtract(const Duration(hours: 2)),
          updatedAt: now.subtract(const Duration(hours: 2)),
        ),
        Listing(
          id: 'lend-2',
          title: 'Bosch Professional Cordless Power Drill Kit',
          description:
              '18V Cordless impact drill kit with masonry, wood, and metal drill bit set. Happy to lend to neighbors for home DIY or wall mounting projects.',
          category: AppConstants.categoryLend,
          price: 'Free to Borrow',
          originalPrice: 'Rental Value: ₹400/day',
          imageUrl:
              'https://images.unsplash.com/photo-1504148455328-c376907d081c?w=800&auto=format&fit=crop&q=80',
          approximateArea: 'Sector 15 Main Market',
          contactPreference: AppConstants.contactPrefWhatsApp,
          status: AppConstants.statusActive,
          isSaved: false,
          createdAt: now.subtract(const Duration(hours: 4)),
          updatedAt: now.subtract(const Duration(hours: 4)),
        ),
        Listing(
          id: 'lend-3',
          title: '4-Person Waterproof Camping Tent & Sleeping Mats',
          description:
              'Quechua 4-person dome camping tent with double roof waterproof protection and 2 insulated sleeping mats. Available to lend for weekend trips.',
          category: AppConstants.categoryLend,
          price: 'Free Weekend Lend',
          originalPrice: 'Rental Value: ₹800/day',
          imageUrl:
              'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=800&auto=format&fit=crop&q=80',
          approximateArea: 'Civil Lines Locality',
          contactPreference: AppConstants.contactPrefCall,
          status: AppConstants.statusActive,
          isSaved: true,
          createdAt: now.subtract(const Duration(hours: 8)),
          updatedAt: now.subtract(const Duration(hours: 8)),
        ),
        Listing(
          id: 'lend-4',
          title: 'Canon DSLR Camera & Heavy Duty Tripod',
          description:
              'Canon EOS Rebel DSLR camera with 18-55mm lens and aluminum tripod. Available to lend for 1-2 days for student photography projects.',
          category: AppConstants.categoryLend,
          price: 'Lend for 2 Days',
          originalPrice: 'Rental Value: ₹1,200/day',
          imageUrl:
              'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800&auto=format&fit=crop&q=80',
          approximateArea: 'University North Campus',
          contactPreference: AppConstants.contactPrefInPerson,
          status: AppConstants.statusActive,
          isSaved: false,
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
        Listing(
          id: 'lend-5',
          title: 'Foldable Aluminium Extension Ladder (12 Ft)',
          description:
              'Sturdy 12-foot aluminum extension ladder with anti-skid feet. Great for roof repair, painting, or tree trimming.',
          category: AppConstants.categoryLend,
          price: 'Free Lend / Share',
          originalPrice: 'Rental Value: ₹300/day',
          imageUrl:
              'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=800&auto=format&fit=crop&q=80',
          approximateArea: 'Old Town Square',
          contactPreference: AppConstants.contactPrefCall,
          status: AppConstants.statusActive,
          isSaved: false,
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 2)),
        ),

        // ==========================================
        // HELP CATEGORY (5 Products)
        // ==========================================
        Listing(
          id: 'help-1',
          title: 'Senior Citizen Grocery & Medicine Aid',
          description:
              'Offering free voluntary assistance to elderly residents or persons with disability around Station Road locality for weekend grocery & pharmacy errands.',
          category: AppConstants.categoryHelp,
          price: 'Voluntary Neighbor Aid',
          originalPrice: 'Free Community Aid',
          imageUrl:
              'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&auto=format&fit=crop&q=80',
          approximateArea: 'Station Road & West End',
          contactPreference: AppConstants.contactPrefInPerson,
          status: AppConstants.statusActive,
          isSaved: false,
          createdAt: now.subtract(const Duration(hours: 1)),
          updatedAt: now.subtract(const Duration(hours: 1)),
        ),
        Listing(
          id: 'help-2',
          title: 'High-School Mathematics & Physics Tutoring',
          description:
              'Engineering student offering free weekend tutoring support for Class 9 & 10 students struggling with Physics or Maths fundamentals.',
          category: AppConstants.categoryHelp,
          price: 'Free Voluntary Support',
          originalPrice: 'Free Tutoring Aid',
          imageUrl:
              'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=800&auto=format&fit=crop&q=80',
          approximateArea: 'University North Campus',
          contactPreference: AppConstants.contactPrefWhatsApp,
          status: AppConstants.statusActive,
          isSaved: false,
          createdAt: now.subtract(const Duration(hours: 3)),
          updatedAt: now.subtract(const Duration(hours: 3)),
        ),
        Listing(
          id: 'help-3',
          title: 'Pet Care & Dog Walking Assistance',
          description:
              'Avid dog lover happy to walk your pets or feed indoor cats on weekend mornings if you are busy or out of town.',
          category: AppConstants.categoryHelp,
          price: 'Voluntary Pet Aid',
          originalPrice: 'Free Pet Care',
          imageUrl:
              'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=800&auto=format&fit=crop&q=80',
          approximateArea: 'Green Park Blocks A-D',
          contactPreference: AppConstants.contactPrefWhatsApp,
          status: AppConstants.statusActive,
          isSaved: false,
          createdAt: now.subtract(const Duration(hours: 7)),
          updatedAt: now.subtract(const Duration(hours: 7)),
        ),
        Listing(
          id: 'help-4',
          title: 'Indoor Plant Watering While Out of Town',
          description:
              'Going away for vacation? Happy to drop by every 2 days to water balcony garden and indoor plants for neighbors in Sector 15.',
          category: AppConstants.categoryHelp,
          price: 'Neighborly Goodwill',
          originalPrice: 'Free Plant Care',
          imageUrl:
              'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=800&auto=format&fit=crop&q=80',
          approximateArea: 'Sector 15 Main Market',
          contactPreference: AppConstants.contactPrefInPerson,
          status: AppConstants.statusActive,
          isSaved: false,
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
        Listing(
          id: 'help-5',
          title: 'Computer & Smartphone Basics for Seniors',
          description:
              'Offering 1-on-1 assistance for senior citizens wanting to learn WhatsApp, digital payments, video calls, or smartphone basics.',
          category: AppConstants.categoryHelp,
          price: 'Free Community Aid',
          originalPrice: 'Free Digital Aid',
          imageUrl:
              'https://images.unsplash.com/photo-1531482615713-2afd69097998?w=800&auto=format&fit=crop&q=80',
          approximateArea: 'Civil Lines Locality',
          contactPreference: AppConstants.contactPrefCall,
          status: AppConstants.statusActive,
          isSaved: false,
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 2)),
        ),
      ];

      for (final item in seedListings) {
        if (box != null) {
          await box.put(item.id, item.toMap());
        } else {
          _inMemoryStore[item.id] = item.toMap();
        }
      }
    }
  }
}
