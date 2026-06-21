import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id; // Disinkronkan dengan pemanggilan 'id' di repository & UI
  final String storeId;
  final String ownerId;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final int stock;
  final String category;
  final List<String> imageUrls;
  final double rating;
  final int reviewCount;
  final int soldCount;
  final bool isActive;
  final int? discountPercent;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String storeName;

  const ProductModel({
    required this.id,
    required this.storeId,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.stock,
    required this.category,
    required this.imageUrls,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.soldCount = 0,
    this.isActive = true,
    this.discountPercent,
    required this.createdAt,
    required this.updatedAt,
    this.storeName = 'BinMart Store',
  });

  /// 📥 MAPPING DARI FIRESTORE DOCUMENT (DocumentSnapshot)
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProductModel.fromMap(data, doc.id);
  }

  /// 📥 MAPPING DARI MAP DATA & ID (Aman dari kesalahan tipe data database)
  factory ProductModel.fromMap(Map<String, dynamic> map, String documentId) {
    // Safe casting untuk array imageUrls agar tidak error bertipe List<dynamic>
    List<String> parsedUrls = [];
    if (map['imageUrls'] is List) {
      parsedUrls = (map['imageUrls'] as List).map((e) => e.toString()).toList();
    }

    // Jaring pengaman: Bersihkan spasi liar di awal/akhir nama kategori dari database
    String rawCategory = map['category']?.toString() ?? '';
    String cleanedCategory = rawCategory.trim();

    return ProductModel(
      id: documentId,
      storeId: map['storeId']?.toString() ?? '',
      ownerId: map['ownerId']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Produk Tanpa Nama',
      description: map['description']?.toString() ?? '',
      price: (map['price'] ?? 0).toDouble(),
      originalPrice: (map['originalPrice'] ?? map['price'] ?? 0).toDouble(),
      stock: (map['stock'] ?? 0).toInt(),
      category: cleanedCategory, // Menyimpan kategori yang sudah bersih dari spasi
      imageUrls: parsedUrls,
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: (map['reviewCount'] ?? 0).toInt(),
      soldCount: (map['soldCount'] ?? 0).toInt(),
      isActive: map['isActive'] ?? true,
      discountPercent: map['discountPercent'] != null 
          ? (map['discountPercent'] as num).toInt() 
          : null,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      storeName: map['storeName']?.toString() ?? 'BinMart Store',
    );
  }

  /// 📤 MAPPING KE MAP (Untuk tambah data / update ke Firebase)
  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'stock': stock,
      'category': category,
      'imageUrls': imageUrls,
      'rating': rating,
      'reviewCount': reviewCount,
      'soldCount': soldCount,
      'isActive': isActive,
      'discountPercent': discountPercent,
      'storeName': storeName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Ambil URL gambar pertama, fallback ke string kosong jika tidak ada gambar
  String get primaryImage => imageUrls.isNotEmpty ? imageUrls.first : '';

  /// 🍏 Emoji fallback berdasarkan kategori (Fiksasi sensitivitas huruf kapital & spasi)
  String get categoryEmoji {
    switch (category.toLowerCase().trim()) {
      case 'buah':
        return '🍏';
      case 'minuman':
        return '🍹';
      case 'makanan ringan':
        return '🍿';
      case 'elektronik':
        return '📱';
      case 'kuliner':
        return '🍲';
      case 'fashion':
        return '👗';
      case 'sembako':
        return '🏪';
      default:
        return '🎁';
    }
  }

  /// 🎨 Warna background fallback berdasarkan kategori (Fiksasi Hex String)
  String get categoryColorHex {
    switch (category.toLowerCase().trim()) {
      case 'buah':
        return 'ECFDF5'; // Hijau soft
      case 'minuman':
      case 'makanan ringan':
        return 'FEF3C7'; // Kuning soft
      case 'elektronik':
        return 'F5F3FF'; // Ungu soft
      case 'fashion':
        return 'FCE7F3'; // Pink soft
      case 'sembako':
        return 'EFF6FF'; // Biru soft
      default:
        return 'FFF7ED'; // Orange soft fallback
    }
  }

  String get productId => id;

}