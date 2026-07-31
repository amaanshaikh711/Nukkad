import 'package:nukkad/core/constants/app_constants.dart';

/// Domain Model for a Neighborhood Listing in Nukkad.
class Listing {
  final String id;
  final String title;
  final String description;
  final String category;
  final String price; // Current price, e.g., "₹4,800"
  final String originalPrice; // Original price for offer strikethrough, e.g., "₹6,500"
  final String imageUrl;
  final String approximateArea;
  final String contactPreference;
  final String status; // Active, Contacted, Closed
  final bool isSaved;
  final DateTime createdAt;
  final DateTime updatedAt;

  Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.price = 'Contact for details',
    this.originalPrice = '',
    this.imageUrl = '',
    required this.approximateArea,
    required this.contactPreference,
    this.status = AppConstants.statusActive,
    this.isSaved = false,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasDiscount => originalPrice.isNotEmpty && originalPrice != price;

  Listing copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? price,
    String? originalPrice,
    String? imageUrl,
    String? approximateArea,
    String? contactPreference,
    String? status,
    bool? isSaved,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      approximateArea: approximateArea ?? this.approximateArea,
      contactPreference: contactPreference ?? this.contactPreference,
      status: status ?? this.status,
      isSaved: isSaved ?? this.isSaved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'approximateArea': approximateArea,
      'contactPreference': contactPreference,
      'status': status,
      'isSaved': isSaved,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Listing.fromMap(Map<dynamic, dynamic> map) {
    return Listing(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      price: map['price'] as String? ?? 'Contact for details',
      originalPrice: map['originalPrice'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      approximateArea: map['approximateArea'] as String,
      contactPreference: map['contactPreference'] as String,
      status: map['status'] as String? ?? AppConstants.statusActive,
      isSaved: map['isSaved'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
