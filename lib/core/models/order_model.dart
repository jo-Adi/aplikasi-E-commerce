import 'package:cloud_firestore/cloud_firestore.dart';

/// Status pesanan — urutan lifecycle
enum OrderStatus {
  pending,      // menunggu pembayaran
  paid,         // pembayaran berhasil, dana di escrow
  processing,   // penjual sedang memproses
  shipped,      // penjual input nomor resi
  delivered,    // pembeli konfirmasi terima
  completed,    // escrow release ke penjual
  cancelled,    // dibatalkan
  refunded,     // dana dikembalikan ke pembeli
}

/// Item dalam 1 pesanan
class OrderItem {
  final String productId;
  final String productName;
  final String imageUrl;
  final double price;
  final int quantity;
  final double subtotal;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      subtotal: (map['subtotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }
}

/// Koleksi Firestore: `orders/{orderId}`
class OrderModel {
  final String orderId;
  final String buyerId;
  final String buyerName;
  final String storeId;
  final String sellerId;
  final List<OrderItem> items;
  final double totalAmount;
  final double platformFee;   // biaya platform BinMart
  final double sellerAmount;  // totalAmount - platformFee
  final OrderStatus status;
  final String paymentMethod;
  final String? paymentProofUrl;  // bukti transfer
  final String? trackingNumber;   // nomor resi pengiriman
  final String? notes;            // catatan dari pembeli
  final DateTime createdAt;
  final DateTime updatedAt;


  const OrderModel({
    required this.orderId,
    required this.buyerId,
    required this.buyerName,
    required this.storeId,
    required this.sellerId,
    required this.items,
    required this.totalAmount,
    this.platformFee = 0,
    required this.sellerAmount,
    required this.status,
    required this.paymentMethod,
    this.paymentProofUrl,
    this.trackingNumber,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String orderId) {
    return OrderModel(
      orderId: orderId,
      buyerId: map['buyerId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      storeId: map['storeId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      platformFee: (map['platformFee'] ?? 0).toDouble(),
      sellerAmount: (map['sellerAmount'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentMethod: map['paymentMethod'] ?? '',
      paymentProofUrl: map['paymentProofUrl'],
      trackingNumber: map['trackingNumber'],
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'buyerName': buyerName,
      'storeId': storeId,
      'sellerId': sellerId,
      'items': items.map((e) => e.toMap()).toList(),
      'totalAmount': totalAmount,
      'platformFee': platformFee,
      'sellerAmount': sellerAmount,
      'status': status.name,
      'paymentMethod': paymentMethod,
      'paymentProofUrl': paymentProofUrl,
      'trackingNumber': trackingNumber,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  OrderModel copyWith({OrderStatus? status, String? trackingNumber}) {
    return OrderModel(
      orderId: orderId,
      buyerId: buyerId,
      buyerName: buyerName,
      storeId: storeId,
      sellerId: sellerId,
      items: items,
      totalAmount: totalAmount,
      platformFee: platformFee,
      sellerAmount: sellerAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
      paymentProofUrl: paymentProofUrl,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
