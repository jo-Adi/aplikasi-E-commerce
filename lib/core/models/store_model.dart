import 'package:cloud_firestore/cloud_firestore.dart';

/// Koleksi Firestore: `stores/{storeId}`
/// storeId = uid penjual (1 seller = 1 toko)
class StoreModel {
  final String storeId;     // sama dengan uid penjual
  final String ownerId;     // uid penjual
  final String storeName;
  final String description;
  final String? logoUrl;
  final String? bannerUrl;
  final String category;    // kategori utama toko
  final double rating;
  final int totalSales;
  final bool isOpen;
  final bool isVerified;    // sudah di-approve admin
  final DateTime createdAt;

  const StoreModel({
    required this.storeId,
    required this.ownerId,
    required this.storeName,
    required this.description,
    this.logoUrl,
    this.bannerUrl,
    this.category = 'Umum',
    this.rating = 0.0,
    this.totalSales = 0,
    this.isOpen = true,
    this.isVerified = false,
    required this.createdAt,
  });

  factory StoreModel.fromMap(Map<String, dynamic> map, String storeId) {
    return StoreModel(
      storeId: storeId,
      ownerId: map['ownerId'] ?? '',
      storeName: map['storeName'] ?? '',
      description: map['description'] ?? '',
      logoUrl: map['logoUrl'],
      bannerUrl: map['bannerUrl'],
      category: map['category'] ?? 'Umum',
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalSales: map['totalSales'] ?? 0,
      isOpen: map['isOpen'] ?? true,
      isVerified: map['isVerified'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'storeName': storeName,
      'description': description,
      'logoUrl': logoUrl,
      'bannerUrl': bannerUrl,
      'category': category,
      'rating': rating,
      'totalSales': totalSales,
      'isOpen': isOpen,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
