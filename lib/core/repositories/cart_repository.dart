import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_model.dart';
import '../services/firestore_collections.dart';

class CartRepository {
  /// Stream isi keranjang user secara realtime
  Stream<List<CartItem>> getCartItems(String uid) {
    return FirestoreCollections.cartItems(uid)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                CartItem.fromMap(d.data() as Map<String, dynamic>))
            .toList());
  }

  /// Tambah atau update item di keranjang
  Future<void> addToCart(String uid, CartItem item) async {
    final ref = FirestoreCollections.cartItems(uid).doc(item.productId);
    final doc = await ref.get();

    if (doc.exists) {
      // Sudah ada → tambah quantity
      final existing =
          CartItem.fromMap(doc.data() as Map<String, dynamic>);
      final newQty =
          (existing.quantity + item.quantity).clamp(1, item.maxStock);
      await ref.update({
        'quantity': newQty,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Belum ada → tambah baru
      await ref.set(item.toMap());
    }
  }

  /// Update quantity item
  Future<void> updateQuantity(
      String uid, String productId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(uid, productId);
      return;
    }
    await FirestoreCollections.cartItems(uid).doc(productId).update({
      'quantity': quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Hapus 1 item dari keranjang
  Future<void> removeFromCart(String uid, String productId) async {
    await FirestoreCollections.cartItems(uid).doc(productId).delete();
  }

  /// Kosongkan keranjang — dipanggil setelah checkout berhasil
  Future<void> clearCart(String uid) async {
    final snap =
        await FirestoreCollections.cartItems(uid).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Hitung total harga keranjang
  double calculateTotal(List<CartItem> items) {
    return items.fold(0, (sum, item) => sum + item.subtotal);
  }
}
