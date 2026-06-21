import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/store_model.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/order_model.dart';
import '../../../core/repositories/store_repository.dart';
import '../../../core/repositories/product_repository.dart';
import '../../../core/repositories/order_repository.dart';

part 'seller_state.dart';

class SellerCubit extends Cubit<SellerState> {
  final _storeRepo = StoreRepository();
  final _productRepo = ProductRepository();
  final _orderRepo = OrderRepository();
  final _picker = ImagePicker();

  StreamSubscription<StoreModel?>? _storeSub;
  StreamSubscription<List<ProductModel>>? _productsSub;
  StreamSubscription<List<OrderModel>>? _ordersSub;

  SellerCubit() : super(const SellerState());

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  Future<void> close() {
    _storeSub?.cancel();
    _productsSub?.cancel();
    _ordersSub?.cancel();
    return super.close();
  }

  /// Load semua data seller — dipanggil saat dashboard dibuka
  Future<void> loadSellerData() async {
    final uid = _uid;
    if (uid == null) return;

    emit(state.copyWith(status: SellerLoadStatus.loading));

    // 1. Stream data toko
    _storeSub?.cancel();
    _storeSub = _storeRepo.storeStream(uid).listen(
      (store) => emit(state.copyWith(store: store)),
    );

    // 2. Stream produk penjual
    _productsSub?.cancel();
    _productsSub = _productRepo.getSellerProducts(uid).listen(
      (products) => emit(state.copyWith(
        products: products,
        status: SellerLoadStatus.loaded,
      )),
      onError: (_) => emit(state.copyWith(
        status: SellerLoadStatus.error,
        errorMessage: 'Gagal memuat data.',
      )),
    );

    // 3. Stream pesanan masuk
    _ordersSub?.cancel();
    _ordersSub = _orderRepo.getSellerOrders(uid).listen(
      (orders) => emit(state.copyWith(orders: orders)),
    );
  }

  // ── Manajemen Produk ─────────────────────────────────────────────────────

  /// ⚠️ SILAKAN DIABAIKAN / TIDAK DIPAKAI KARENA STORAGE TERKUNCI (SPARK PLAN)
  /// Fungsi ini dibiarkan utuh agar tidak merusak dependensi file lama jika ada.
  Future<String?> uploadProductImage() async {
    final uid = _uid;
    if (uid == null) return null;

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 80,
      );
      if (picked == null) return null;

      emit(state.copyWith(isProcessing: true));

      final file = File(picked.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('products/$uid/$fileName');

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      emit(state.copyWith(isProcessing: false));
      return url;
    } catch (e) {
      emit(state.copyWith(isProcessing: false));
      return null;
    }
  }

  /// Tambah produk baru menggunakan List URL teks langsung ke Cloud Firestore
  Future<bool> addProduct({
    required String name,
    required String description,
    required double price,
    required double originalPrice,
    required int stock,
    required String category,
    required List<String> imageUrls, // Menampung list link gambar dari UI baru
    int? discountPercent,
  }) async {
    final uid = _uid;
    if (uid == null) return false;

    emit(state.copyWith(isProcessing: true));
    try {
      final product = ProductModel(
        id: '', // Diisi otomatis oleh id dokumen auto-generate Firestore di repository
        storeId: uid, 
        ownerId: uid,
        name: name,
        description: description,
        price: price,
        originalPrice: originalPrice,
        stock: stock,
        category: category,
        imageUrls: imageUrls, // List string URL masuk langsung dengan aman
        isActive: true,
        discountPercent: discountPercent,
        storeName: state.store?.storeName ?? 'Toko Saya',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(), 
      );
      
      await _productRepo.addProduct(product);
      emit(state.copyWith(isProcessing: false));
      return true;
    } catch (e) {
      emit(state.copyWith(isProcessing: false));
      return false;
    }
  }

  /// Edit produk
  Future<bool> updateProduct(
      String productId, Map<String, dynamic> data) async {
    emit(state.copyWith(isProcessing: true));
    try {
      await _productRepo.updateProduct(productId, data);
      emit(state.copyWith(isProcessing: false));
      return true;
    } catch (e) {
      emit(state.copyWith(isProcessing: false));
      return false;
    }
  }

  /// Aktif/nonaktifkan produk
  Future<void> toggleProduct(String productId, bool isActive) async {
    await _productRepo.toggleProductActive(productId, isActive);
  }

  /// Hapus produk
  Future<void> deleteProduct(String productId) async {
    await _productRepo.deleteProduct(productId);
  }

  // ── Manajemen Pesanan ────────────────────────────────────────────────────

  /// Penjual proses pesanan — pending → processing
  Future<void> processOrder(String orderId) async {
    emit(state.copyWith(isProcessing: true));
    await _orderRepo.updateOrderStatus(orderId, OrderStatus.processing);
    emit(state.copyWith(isProcessing: false));
  }

  /// Penjual selesaikan pesanan — processing → completed
  Future<void> completeOrder(String orderId) async {
    emit(state.copyWith(isProcessing: true));
    await _orderRepo.updateOrderStatus(orderId, OrderStatus.completed);
    emit(state.copyWith(isProcessing: false));
  }
}