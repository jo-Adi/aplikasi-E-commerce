import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/user_model.dart';
import '../../../core/models/store_model.dart';
import '../../../core/repositories/user_repository.dart';
import '../../../core/repositories/store_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final _auth = FirebaseAuth.instance;
  final _userRepo = UserRepository();
  final _storeRepo = StoreRepository();

  AuthCubit() : super(const AuthState()) {
    _checkCurrentUser();
  }

  // ── Cek session aktif saat app dibuka ───────────────────────────────────
  Future<void> _checkCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return;

    final user = await _userRepo.getUser(firebaseUser.uid);
    if (user != null) {
      emit(state.copyWith(
        status: AuthStatus.success,
        currentUser: user,
      ));
    }
  }

  // ── UI toggles ───────────────────────────────────────────────────────────
  void togglePasswordVisibility() =>
      emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));

  void toggleConfirmPasswordVisibility() =>
      emit(state.copyWith(
          isConfirmPasswordVisible: !state.isConfirmPasswordVisible));

  void toggleTerms() =>
      emit(state.copyWith(isTermsAccepted: !state.isTermsAccepted));

  void selectRole(UserRole role) =>
      emit(state.copyWith(selectedRole: role));

  void clearError() => emit(state.copyWith(clearError: true));

  // ── Register dengan Email & Password ────────────────────────────────────
  Future<void> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    required Function(UserModel user) onSuccess,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      // 1. Buat akun di Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // 2. Update display name di Firebase Auth
      await credential.user!.updateDisplayName(fullName);

      // 3. Simpan data user ke Firestore users/{uid}
      final user = UserModel(
        uid: uid,
        fullName: fullName,
        email: email,
        role: role == UserRole.seller ? 'seller' : 'buyer',
        isVerified: true, // langsung verified sesuai keputusan
        createdAt: DateTime.now(),
      );
      await _userRepo.createUser(user);

      // 4. Jika penjual → buat dokumen toko otomatis
      if (role == UserRole.seller) {
        final store = StoreModel(
          storeId: uid,
          ownerId: uid,
          storeName: '$fullName Store',
          description: 'Toko baru di BinMart',
          isVerified: true,
          createdAt: DateTime.now(),
        );
        await _storeRepo.createStore(store);
      }

      emit(state.copyWith(
        status: AuthStatus.success,
        currentUser: user,
      ));
      onSuccess(user);
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: _mapFirebaseError(e.code),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Terjadi kesalahan. Silakan coba lagi.',
      ));
    }
  }

  // ── Login dengan Email & Password ───────────────────────────────────────
  Future<void> loginWithEmail({
    required String email,
    required String password,
    required Function(UserModel user) onSuccess,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      // 1. Login ke Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Ambil data user dari Firestore
      final user = await _userRepo.getUser(credential.user!.uid);
      if (user == null) {
        emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Data akun tidak ditemukan.',
        ));
        return;
      }

      emit(state.copyWith(
        status: AuthStatus.success,
        currentUser: user,
      ));
      onSuccess(user);
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: _mapFirebaseError(e.code),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Terjadi kesalahan. Silakan coba lagi.',
      ));
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────
  Future<void> logout({required Function onSuccess}) async {
    await _auth.signOut();
    emit(const AuthState());
    onSuccess();
  }

  // ── Map Firebase error code → pesan Indonesia ───────────────────────────
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan login.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah. Minimal 8 karakter.';
      case 'user-not-found':
        return 'Email tidak terdaftar.';
      case 'wrong-password':
        return 'Password salah.';
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet.';
      default:
        return 'Terjadi kesalahan ($code).';
    }
  }
}
