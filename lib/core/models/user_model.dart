import 'package:cloud_firestore/cloud_firestore.dart';

/// Koleksi Firestore: `users/{uid}`
class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String role;        // 'buyer' | 'seller'
  final String? photoUrl;
  final String? phoneNumber;
  final bool isVerified;    // seller: sudah KYC atau belum
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.photoUrl,
    this.phoneNumber,
    this.isVerified = false,
    required this.createdAt,
  });

  /// Firestore → Dart (PERBAIKAN: Hanya menerima 1 argumen 'map')
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'buyer',
      photoUrl: map['photoUrl'],
      phoneNumber: map['phoneNumber'],
      isVerified: map['isVerified'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Dart → Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? fullName,
    String? email,
    String? role,
    String? photoUrl,
    String? phoneNumber,
    bool? isVerified,
  }) {
    return UserModel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt,
    );
  }
}