import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/user_model.dart';
import '../../../core/repositories/user_repository.dart';
import '../../../core/services/storage_service.dart'; // Import service baru kita

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final _userRepo = UserRepository();
  final _storageService = StorageService(); // Kita pakai service Supabase

  ProfileCubit() : super(const ProfileState());

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // --- FUNGSI UPLOAD FOTO PROFIL (FIXED: SUPABASE) ---
  Future<void> uploadProfilePhoto() async {
    final uid = _uid;
    if (uid == null) return;

    try {
      // 1. Pilih gambar lewat StorageService
      final file = await _storageService.pickImageFromGallery();
      if (file == null) return;

      emit(state.copyWith(isUploadingPhoto: true));

      // 2. Upload ke Supabase lewat StorageService
      final photoUrl = await _storageService.uploadProfileImage(file, uid);

      if (photoUrl != null) {
        // 3. Update di Firestore & Auth
        await _userRepo.updateUser(uid, {'photoUrl': photoUrl});
        await FirebaseAuth.instance.currentUser?.updatePhotoURL(photoUrl);

        final updated = state.user?.copyWith(photoUrl: photoUrl);
        emit(state.copyWith(
          isUploadingPhoto: false,
          user: updated,
        ));
      } else {
        emit(state.copyWith(isUploadingPhoto: false));
      }
    } catch (e) {
      emit(state.copyWith(isUploadingPhoto: false));
    }
  }

  // --- FUNGSI LAINNYA TETAP SAMA ---
  Future<bool> updateName(String newName) async {
    final uid = _uid;
    if (uid == null) return false;
    emit(state.copyWith(status: ProfileStatus.saving));
    try {
      await _userRepo.updateUser(uid, {'fullName': newName});
      await FirebaseAuth.instance.currentUser?.updateDisplayName(newName);
      final updated = state.user?.copyWith(fullName: newName);
      emit(state.copyWith(status: ProfileStatus.loaded, user: updated));
      return true;
    } catch (_) {
      emit(state.copyWith(status: ProfileStatus.error, errorMessage: 'Gagal update nama.'));
      return false;
    }
  }

  Future<bool> updatePhone(String phone) async {
    final uid = _uid;
    if (uid == null) return false;
    emit(state.copyWith(status: ProfileStatus.saving));
    try {
      await _userRepo.updateUser(uid, {'phoneNumber': phone});
      final updated = state.user?.copyWith(phoneNumber: phone);
      emit(state.copyWith(status: ProfileStatus.loaded, user: updated));
      return true;
    } catch (_) {
      emit(state.copyWith(status: ProfileStatus.error, errorMessage: 'Gagal update nomor.'));
      return false;
    }
  }

 void loadProfile() async {
    final uid = _uid;
    if (uid == null) return;
    
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    
    if (doc.exists && doc.data() != null) {
      // Pastikan dari sini Anda hanya mengirim doc.data()
      final user = UserModel.fromMap(doc.data()!, uid);
      emit(state.copyWith(user: user, status: ProfileStatus.loaded));
    }
  }
}