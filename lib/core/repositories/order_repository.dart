import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../services/firestore_collections.dart';

class OrderRepository {
  /// Buat pesanan baru — pembeli checkout
  Future<String> createOrder(OrderModel order) async {
    final doc = await FirestoreCollections.orders.add(order.toMap());
    return doc.id;
  }

  /// Stream pesanan milik pembeli (Bypass tanpa Composite Index)
  Stream<List<OrderModel>> getBuyerOrders(String buyerId) {
    return FirestoreCollections.orders
        .where('buyerId', isEqualTo: buyerId)
        // .orderBy dihilangkan untuk mencegah error index Firestore
        .snapshots()
        .map((snap) {
          final orders = snap.docs
              .map((d) => OrderModel.fromMap(
                  d.data() as Map<String, dynamic>, d.id))
              .toList();
          
          // 🟢 Urutkan secara manual di aplikasi: pesanan terbaru (createdAt) berada di atas
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  /// Stream pesanan masuk untuk penjual (Bypass tanpa Composite Index)
  Stream<List<OrderModel>> getSellerOrders(String sellerId) {
    return FirestoreCollections.orders
        .where('sellerId', isEqualTo: sellerId)
        // .orderBy dihilangkan untuk mencegah error index Firestore
        .snapshots()
        .map((snap) {
          final orders = snap.docs
              .map((d) => OrderModel.fromMap(
                  d.data() as Map<String, dynamic>, d.id))
              .toList();
          
          // 🟢 Urutkan secara manual di aplikasi: pesanan terbaru (createdAt) berada di atas
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  /// Update status pesanan — penjual atau pembeli
  Future<void> updateOrderStatus(
      String orderId, OrderStatus status) async {
    await FirestoreCollections.order(orderId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Penjual input nomor resi
  Future<void> addTrackingNumber(
      String orderId, String trackingNumber) async {
    await FirestoreCollections.order(orderId).update({
      'trackingNumber': trackingNumber,
      'status': OrderStatus.shipped.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Pembeli konfirmasi barang diterima → trigger escrow release
  Future<void> confirmDelivery(String orderId) async {
    await FirestoreCollections.order(orderId).update({
      'status': OrderStatus.completed.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    // TODO: Cloud Function akan mendeteksi perubahan status ini
    // dan mentransfer sellerAmount ke saldo penjual
  }

  /// Ambil detail satu pesanan
  Future<OrderModel?> getOrder(String orderId) async {
    final doc = await FirestoreCollections.order(orderId).get();
    if (!doc.exists) return null;
    return OrderModel.fromMap(doc.data() as Map<String, dynamic>, orderId);
  }
}