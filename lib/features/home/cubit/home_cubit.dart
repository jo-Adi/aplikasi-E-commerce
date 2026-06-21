import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/product_model.dart';
import '../../../core/repositories/product_repository.dart';
import '../../../core/repositories/user_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final _productRepo = ProductRepository();
  final _userRepo = UserRepository();

  StreamSubscription<List<ProductModel>>? _productsSub;

  HomeCubit() : super(const HomeState());

  @override
  Future<void> close() {
    _productsSub?.cancel();
    return super.close();
  }
/// Format kategori agar pas dengan data Firebase (Huruf Besar di Awal)
  // ignore: unused_element
  String? _formatCategory(String? category) {
    if (category == null || category.trim().isEmpty) return null;
    
    // Hilangkan spasi liar di awal/akhir
    String txt = category.trim(); 
    
    // Paksa format menjadi Huruf Kapital di awal kata (Contoh: "buah" -> "Buah", " Elektronik" -> "Elektronik")
    return txt[0].toUpperCase() + txt.substring(1).toLowerCase();
  }
  /// Load user + subscribe stream produk dari Firestore
  Future<void> loadHomeData() async {
    emit(state.copyWith(loadStatus: HomeLoadStatus.loading));
    await _productRepo.debugFirestore();
    // 1. Load nama user dari Firestore
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final user = await _userRepo.getUser(firebaseUser.uid);
      emit(state.copyWith(
        userName: user?.fullName ?? firebaseUser.displayName ?? 'Pengguna',
        userRole: user?.role ?? 'buyer',
      ));
    }
    

    // 2. Subscribe stream produk — realtime dari Firestore
    _productsSub?.cancel();
    _productsSub = _productRepo
        .getActiveProducts(category: state.selectedCategory)
        .listen(
      (products) {
        emit(state.copyWith(
          products: products,
          loadStatus: HomeLoadStatus.loaded,
        ));
      },
      onError: (e) {
        emit(state.copyWith(
          loadStatus: HomeLoadStatus.error,
          errorMessage: 'Gagal memuat produk. Periksa koneksi Anda.',
        ));
      },
    );
  }

  /// Filter by kategori — resubscribe stream dengan filter baru
  void selectCategory(String? category) {
    _productsSub?.cancel();

    if (state.selectedCategory == category) {
      // Toggle off
      emit(state.copyWith(clearCategory: true));
      _productsSub = _productRepo.getActiveProducts().listen(
            (products) => emit(state.copyWith(products: products)),
          );
    } else {
      emit(state.copyWith(selectedCategory: category));
      _productsSub = _productRepo
          .getActiveProducts(category: category)
          .listen(
            (products) => emit(state.copyWith(products: products)),
          );
    }
  }

  void changeNavIndex(int index) =>
      emit(state.copyWith(currentNavIndex: index));

  void updateSearch(String query) =>
      emit(state.copyWith(searchQuery: query));

  // Alias untuk kompatibilitas dengan kode sebelumnya
  Future<void> loadUserSession() => loadHomeData();
}
