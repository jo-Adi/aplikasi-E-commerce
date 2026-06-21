import 'package:cloud_firestore/cloud_firestore.dart';

/// Koleksi Firestore: `carts/{uid}/items/{productId}`
/// Struktur subcollection agar tiap user punya keranjang sendiri
class CartItem {
  final String productId;
  final String productName;
  final String storeId;
  final String storeName;
  final double price;
  final int quantity;
  final String imageUrl;
  final int maxStock;       // untuk validasi stok saat checkout

  const CartItem({
    required this.productId,
    required this.productName,
    required this.storeId,
    required this.storeName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.maxStock,
  });

  double get subtotal => price * quantity;

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      storeId: map['storeId'] ?? '',
      storeName: map['storeName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      imageUrl: map['imageUrl'] ?? '',
      maxStock: map['maxStock'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'storeId': storeId,
      'storeName': storeName,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'maxStock': maxStock,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      productName: productName,
      storeId: storeId,
      storeName: storeName,
      price: price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl,
      maxStock: maxStock,
    );
  }
}
