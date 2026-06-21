//import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/store_model.dart';
import '../services/firestore_collections.dart';

class StoreRepository {
  /// Buat toko baru — dipanggil saat penjual register
  Future<void> createStore(StoreModel store) async {
    await FirestoreCollections.store(store.storeId).set(store.toMap());
  }

  /// Ambil data toko berdasarkan storeId
  Future<StoreModel?> getStore(String storeId) async {
    final doc = await FirestoreCollections.store(storeId).get();
    if (!doc.exists) return null;
    return StoreModel.fromMap(doc.data() as Map<String, dynamic>, storeId);
  }

  /// Stream realtime toko — untuk dashboard penjual
  Stream<StoreModel?> storeStream(String storeId) {
    return FirestoreCollections.store(storeId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return StoreModel.fromMap(
          doc.data() as Map<String, dynamic>, storeId);
    });
  }

  /// Update info toko — penjual edit profil toko
  Future<void> updateStore(
      String storeId, Map<String, dynamic> data) async {
    await FirestoreCollections.store(storeId).update(data);
  }

  /// Buka / tutup toko
  Future<void> toggleStoreOpen(String storeId, bool isOpen) async {
    await FirestoreCollections.store(storeId).update({'isOpen': isOpen});
  }

  /// Semua toko yang sudah terverifikasi — untuk halaman explore
  Stream<List<StoreModel>> getVerifiedStores() {
    return FirestoreCollections.stores
        .where('isVerified', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => StoreModel.fromMap(
                d.data() as Map<String, dynamic>, d.id))
            .toList());
  }
}
