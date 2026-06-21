part of 'profile_cubit.dart';

enum ProfileStatus { initial, loading, loaded, saving, error }

class ProfileState {
  final ProfileStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool isUploadingPhoto;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.errorMessage,
    this.isUploadingPhoto = false,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserModel? user,
    String? errorMessage,
    bool? isUploadingPhoto,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
    );
  }
}
