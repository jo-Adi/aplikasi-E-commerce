import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../services/firestore_collections.dart';

class ProductRepository {
  /// Stream produk aktif — filter kategori opsional dengan proteksi error & indeks
  Stream<List<ProductModel>> getActiveProducts({String? category}) {
    try {
      Query query = FirestoreCollections.products.where('isActive', isEqualTo: true);

      // Jika kategori dipilih, tambahkan ke dalam query filter
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      // Gabungkan dengan pengurutan data berdasarkan waktu pembuatan terbaru
      query = query.orderBy('createdAt', descending: true);

      return query.snapshots().map((snap) {
        // Log pembantu untuk memantau apakah data mentah berhasil ditarik dari Firestore
        print("I/flutter 🟢 FIRESTORE BERHASIL SELEKSI: ${snap.docs.length} DATA");
        
        return snap.docs.map((d) {
          try {
            // Proses konversi dari JSON Firestore Map ke Objek Model Flutter
            return ProductModel.fromMap(d.data() as Map<String, dynamic>, d.id);
          } catch (e) {
            // Log ini akan langsung berteriak jika ada salah tipe data di dokumen tertentu
            print("🚨 ERROR CONVERT/PARSING DATA PADA DOKUMEN ID [${d.id}]: $e");
            rethrow;
          }
        }).toList();
      });
    } catch (e, stackTrace) {
      // Log utama untuk menangkap link pembuatan indeks otomatis dari Firebase
      print("🚨 ERROR UTAMA PADA STREAM QUERY: $e");
      print("📌 LOKASI CORONG KODE: $stackTrace");
      rethrow;
    }
  }

  /// Stream produk milik penjual berdasarkan Owner ID
  Stream<List<ProductModel>> getSellerProducts(String ownerId) {
    try {
      return FirestoreCollections.products
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs
              .map((d) => ProductModel.fromMap(
                  d.data() as Map<String, dynamic>, d.id))
              .toList());
    } catch (e) {
      print("🚨 ERROR GET SELLER PRODUCTS: $e");
      rethrow;
    }
  }

  /// Menambahkan data produk baru ke Firebase
  Future<String> addProduct(ProductModel product) async {
    final doc = await FirestoreCollections.products.add(product.toMap());
    return doc.id;
  }

  /// Memperbarui isi data produk berdasarkan ID produk
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    await FirestoreCollections.product(productId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mengaktifkan atau menonaktifkan status penjualan produk (soft delete/hide)
  Future<void> toggleProductActive(String productId, bool isActive) async {
    await FirestoreCollections.product(productId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Menghapus dokumen produk secara permanen dari Firestore
  Future<void> deleteProduct(String productId) async {
    await FirestoreCollections.product(productId).delete();
  }

  /// Mengurangi stok produk otomatis dan menaikkan angka soldCount saat transaksi berhasil
  Future<void> decreaseStock(String productId, int quantity) async {
    await FirestoreCollections.product(productId).update({
      'stock': FieldValue.increment(-quantity),
      'soldCount': FieldValue.increment(quantity),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mengatur besaran persentase diskon dan menghitung harga jual baru produk
  Future<void> setDiscount(String productId, int? discountPercent, double salePrice) async {
    await FirestoreCollections.product(productId).update({
      'discountPercent': discountPercent,
      'price': salePrice,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> debugFirestore() async {}
}