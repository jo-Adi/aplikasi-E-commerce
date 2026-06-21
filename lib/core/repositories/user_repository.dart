import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/firestore_collections.dart';

class UserRepository {
  /// Buat dokumen user baru di Firestore setelah register
  Future<void> createUser(UserModel user) async {
    await FirestoreCollections.user(user.uid).set(user.toMap());
  }

  /// Ambil data user berdasarkan uid
  Future<UserModel?> getUser(String uid) async {
    final doc = await FirestoreCollections.user(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
  }

  /// Stream realtime data user — untuk HomeScreen
  Stream<UserModel?> userStream(String uid) {
    return FirestoreCollections.user(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
    });
  }

  /// Update field tertentu
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await FirestoreCollections.user(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Cek role user — dipakai untuk routing setelah login
  Future<String> getUserRole(String uid) async {
    final user = await getUser(uid);
    return user?.role ?? 'buyer';
  }
}
