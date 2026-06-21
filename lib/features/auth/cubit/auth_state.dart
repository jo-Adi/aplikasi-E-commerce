part of 'auth_cubit.dart';

enum AuthStatus { initial, loading, success, failure }
enum UserRole { buyer, seller }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool isTermsAccepted;
  final UserRole selectedRole;
  final UserModel? currentUser;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.isTermsAccepted = false,
    this.selectedRole = UserRole.buyer,
    this.currentUser,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool? isTermsAccepted,
    UserRole? selectedRole,
    UserModel? currentUser,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible: isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      isTermsAccepted: isTermsAccepted ?? this.isTermsAccepted,
      selectedRole: selectedRole ?? this.selectedRole,
      currentUser: currentUser ?? this.currentUser,
    );
  }
// Tambahkan ini di dalam class AuthState
  String get userName => currentUser?.fullName ?? 'Pengguna';
  String get userEmail => currentUser?.email ?? '';
  bool get isLoggedIn => currentUser != null;
  bool get isSeller => currentUser?.role == 'seller';
  bool get isBuyer => currentUser?.role == 'buyer';
}
