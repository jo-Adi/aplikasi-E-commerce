import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String storeId;
  final String ownerId;
  final int price;
  final int originalPrice;
  final double rating;
  final int reviewCount;
  final int soldCount;
  final int stock;
  final String imageUrl;
  final bool isActive;
  final int? discountPercent;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.storeId,
    required this.ownerId,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.soldCount,
    required this.stock,
    required this.imageUrl,
    required this.isActive,
    this.discountPercent,
    this.createdAt,
    this.updatedAt,
  });

  /// 📥 MAPPING DARI FIRESTORE KE FLUTTER (Membaca Data)
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Mengambil indeks pertama dari array imageUrls di Firebase
    final List<dynamic> urls = data['imageUrls'] as List<dynamic>? ?? [];
    final String singleImageUrl = urls.isNotEmpty ? urls[0].toString() : '';

    final Timestamp? createdAtTimestamp = data['createdAt'] as Timestamp?;
    final Timestamp? updatedAtTimestamp = data['updatedAt'] as Timestamp?;

    return ProductModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      storeId: data['storeId'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      price: (data['price'] as num? ?? 0).toInt(),
      originalPrice: (data['originalPrice'] as num? ?? 0).toInt(),
      rating: (data['rating'] as num? ?? 0.0).toDouble(),
      reviewCount: (data['reviewCount'] as num? ?? 0).toInt(),
      soldCount: (data['soldCount'] as num? ?? 0).toInt(),
      stock: (data['stock'] as num? ?? 0).toInt(),
      imageUrl: singleImageUrl,
      isActive: data['isActive'] as bool? ?? true,
      discountPercent: data['discountPercent'] != null 
          ? (data['discountPercent'] as num).toInt() 
          : null,
      createdAt: createdAtTimestamp?.toDate(),
      updatedAt: updatedAtTimestamp?.toDate(),
    );
  }

  /// 📤 MAPPING DARI FLUTTER KE FIRESTORE (Menyimpan Data)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'storeId': storeId,
      'ownerId': ownerId,
      'price': price,
      'originalPrice': originalPrice,
      'rating': rating,
      'reviewCount': reviewCount,
      'soldCount': soldCount,
      'stock': stock,
      'imageUrls': [imageUrl], // Membungkus string imageUrl ke bentuk Array saat disimpan ke Firebase
      'isActive': isActive,
      'discountPercent': discountPercent,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }
}