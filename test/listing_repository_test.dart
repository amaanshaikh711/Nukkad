import 'package:flutter_test/flutter_test.dart';
import 'package:nukkad/core/constants/app_constants.dart';
import 'package:nukkad/features/listing/data/datasources/listing_local_datasource.dart';
import 'package:nukkad/features/listing/data/repositories/listing_repository.dart';
import 'package:nukkad/features/listing/domain/models/listing.dart';

class MockListingLocalDatasource implements ListingLocalDatasource {
  final Map<String, Listing> _storage = {};

  @override
  Future<List<Listing>> getListings() async {
    final list = _storage.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<Listing?> getListingById(String id) async => _storage[id];

  @override
  Future<void> saveListing(Listing listing) async {
    _storage[listing.id] = listing;
  }

  @override
  Future<void> updateListing(Listing listing) async {
    _storage[listing.id] = listing;
  }

  @override
  Future<void> deleteListing(String id) async {
    _storage.remove(id);
  }

  @override
  Future<void> clearAllData() async {
    _storage.clear();
  }

  @override
  Future<void> seedInitialDataIfEmpty() async {
    if (_storage.isEmpty) {
      final now = DateTime.now();
      _storage['test-1'] = Listing(
        id: 'test-1',
        title: 'Initial Seed Item',
        description: 'Test seed description for repository unit testing.',
        category: AppConstants.categorySell,
        approximateArea: 'Sector 15 Main Market',
        contactPreference: AppConstants.contactPrefWhatsApp,
        status: AppConstants.statusActive,
        createdAt: now,
        updatedAt: now,
      );
    }
  }
}

void main() {
  group('ListingRepository Unit Tests', () {
    late ListingRepository repository;
    late MockListingLocalDatasource mockDatasource;

    setUp(() {
      mockDatasource = MockListingLocalDatasource();
      repository = ListingRepositoryImpl(datasource: mockDatasource);
    });

    test('fetchListings seeds initial data when empty', () async {
      final listings = await repository.fetchListings();
      expect(listings.length, equals(1));
      expect(listings.first.id, equals('test-1'));
    });

    test('createListing persists new item locally', () async {
      final now = DateTime.now();
      final newListing = Listing(
        id: 'test-2',
        title: 'New Bicycles for Kids',
        description: 'Barely used kids bicycle suitable for ages 6-10.',
        category: AppConstants.categorySell,
        approximateArea: 'Green Park Blocks A-D',
        contactPreference: AppConstants.contactPrefCall,
        createdAt: now,
        updatedAt: now,
      );

      await repository.createListing(newListing);
      final fetched = await repository.getListingById('test-2');

      expect(fetched, isNotNull);
      expect(fetched!.title, equals('New Bicycles for Kids'));
    });

    test('toggleSaveStatus updates isSaved boolean flag', () async {
      await repository.fetchListings(); // seed
      await repository.toggleSaveStatus('test-1');
      var item = await repository.getListingById('test-1');
      expect(item!.isSaved, isTrue);

      await repository.toggleSaveStatus('test-1');
      item = await repository.getListingById('test-1');
      expect(item!.isSaved, isFalse);
    });

    test('updateStatus mutates listing status correctly', () async {
      await repository.fetchListings(); // seed
      await repository.updateStatus('test-1', AppConstants.statusContacted);
      var item = await repository.getListingById('test-1');
      expect(item!.status, equals(AppConstants.statusContacted));

      await repository.updateStatus('test-1', AppConstants.statusClosed);
      item = await repository.getListingById('test-1');
      expect(item!.status, equals(AppConstants.statusClosed));
    });
  });
}
