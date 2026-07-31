import 'package:nukkad/features/listing/data/datasources/listing_local_datasource.dart';
import 'package:nukkad/features/listing/domain/models/listing.dart';

abstract class ListingRepository {
  Future<List<Listing>> fetchListings();
  Future<Listing?> getListingById(String id);
  Future<void> createListing(Listing listing);
  Future<void> updateListing(Listing listing);
  Future<void> toggleSaveStatus(String id);
  Future<void> updateStatus(String id, String newStatus);
  Future<void> deleteListing(String id);
  Future<void> resetAllData();
}

class ListingRepositoryImpl implements ListingRepository {
  final ListingLocalDatasource datasource;

  ListingRepositoryImpl({required this.datasource});

  @override
  Future<List<Listing>> fetchListings() async {
    await datasource.seedInitialDataIfEmpty();
    return await datasource.getListings();
  }

  @override
  Future<Listing?> getListingById(String id) async {
    return await datasource.getListingById(id);
  }

  @override
  Future<void> createListing(Listing listing) async {
    await datasource.saveListing(listing);
  }

  @override
  Future<void> updateListing(Listing listing) async {
    await datasource.updateListing(listing);
  }

  @override
  Future<void> toggleSaveStatus(String id) async {
    final existing = await datasource.getListingById(id);
    if (existing != null) {
      final updated = existing.copyWith(
        isSaved: !existing.isSaved,
        updatedAt: DateTime.now(),
      );
      await datasource.updateListing(updated);
    }
  }

  @override
  Future<void> updateStatus(String id, String newStatus) async {
    final existing = await datasource.getListingById(id);
    if (existing != null) {
      final updated = existing.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      await datasource.updateListing(updated);
    }
  }

  @override
  Future<void> deleteListing(String id) async {
    await datasource.deleteListing(id);
  }

  @override
  Future<void> resetAllData() async {
    await datasource.clearAllData();
    await datasource.seedInitialDataIfEmpty();
  }
}
