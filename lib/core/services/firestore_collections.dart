import 'package:cloud_firestore/cloud_firestore.dart';

/// Sentralisasi nama koleksi Firestore.
/// Gunakan class ini di seluruh repository — jangan hardcode string.
class FirestoreCollections {
  FirestoreCollections._();

  static final _db = FirebaseFirestore.instance;

  // ── Root collections ────────────────────────────────────────────────────
  static CollectionReference get users      => _db.collection('users');
  static CollectionReference get products   => _db.collection('products');
  static CollectionReference get orders     => _db.collection('orders');
  static CollectionReference get stores     => _db.collection('stores');

  // ── Subcollections ───────────────────────────────────────────────────────
  /// Keranjang belanja: `carts/{uid}/items`
  static CollectionReference cartItems(String uid) =>
      _db.collection('carts').doc(uid).collection('items');

  /// Ulasan produk: `products/{productId}/reviews`
  static CollectionReference reviews(String productId) =>
      _db.collection('products').doc(productId).collection('reviews');

  // ── Document references ──────────────────────────────────────────────────
  static DocumentReference user(String uid)           => users.doc(uid);
  static DocumentReference product(String productId)  => products.doc(productId);
  static DocumentReference order(String orderId)      => orders.doc(orderId);
  static DocumentReference store(String storeId)      => stores.doc(storeId);
}

/*
════════════════════════════════════════════════════════════════════
  STRUKTUR FIRESTORE BINMART
════════════════════════════════════════════════════════════════════

  users/
    {uid}/
      fullName: string
      email: string
      role: 'buyer' | 'seller'
      photoUrl: string?
      phoneNumber: string?
      isVerified: bool
      createdAt: timestamp

  stores/
    {storeId}/           ← storeId = uid penjual
      ownerId: string
      storeName: string
      description: string
      logoUrl: string?
      bannerUrl: string?
      category: string
      rating: number
      totalSales: number
      isOpen: bool
      isVerified: bool    ← admin yang set true
      createdAt: timestamp

  products/
    {productId}/
      storeId: string
      ownerId: string
      name: string
      description: string
      price: number
      originalPrice: number
      stock: number
      category: string
      imageUrls: string[]
      rating: number
      reviewCount: number
      soldCount: number
      isActive: bool
      discountPercent: number?
      createdAt: timestamp
      updatedAt: timestamp
      
      reviews/            ← subcollection
        {reviewId}/
          userId: string
          userName: string
          rating: number
          comment: string
          createdAt: timestamp

  orders/
    {orderId}/
      buyerId: string
      buyerName: string
      storeId: string
      sellerId: string
      items: array
      totalAmount: number
      platformFee: number
      sellerAmount: number
      status: 'pending'|'paid'|'processing'|'shipped'|'delivered'|'completed'|'cancelled'|'refunded'
      paymentMethod: string
      paymentProofUrl: string?
      trackingNumber: string?
      notes: string?
      createdAt: timestamp
      updatedAt: timestamp

  carts/
    {uid}/
      items/              ← subcollection
        {productId}/
          productId: string
          productName: string
          storeId: string
          storeName: string
          price: number
          quantity: number
          imageUrl: string
          maxStock: number
          updatedAt: timestamp

════════════════════════════════════════════════════════════════════
*/
