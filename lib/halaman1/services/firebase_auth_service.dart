import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService {
  static final FirebaseAuthService instance = FirebaseAuthService._internal();
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isLoggedIn => _auth.currentUser != null;

  /// Register a new cashier/user with Firebase Authentication and save profile in Firestore
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? city,
    String? cashierId,
    String? role,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return {'success': false, 'message': 'Gagal membuat akun pengguna.'};
      }

      // Update Firebase Auth display name
      await user.updateDisplayName(name);

      final finalCashierId = (cashierId != null && cashierId.isNotEmpty)
          ? cashierId
          : 'BG${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final finalRole = role ?? 'Barista / Kasir';

      final profileData = {
        'uid': user.uid,
        'nama': name,
        'displayName': name,
        'email': normalizedEmail,
        'nomor_hp': phone ?? '',
        'phoneNumber': phone ?? '',
        'asalKota': city ?? '',
        'city': city ?? '',
        'cashierId': finalCashierId,
        'role': finalRole,
        'isVerified': user.emailVerified,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Save user profile to Firestore
      try {
        await _firestore.collection('users').doc(user.uid).set(profileData, SetOptions(merge: true));
      } catch (firestoreErr) {
        debugPrint('Firestore write warning (Rules notice): $firestoreErr');
      }

      return {
        'success': true,
        'message': 'Registrasi berhasil!',
        'uid': user.uid,
        'cashierId': finalCashierId,
        'profile': profileData,
      };
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException [register]: ${e.code} - ${e.message}');
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.code, isRegister: true),
      };
    } catch (e) {
      debugPrint('General error [register]: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat registrasi: $e',
      };
    }
  }

  /// Login with email or Cashier ID and password
  Future<Map<String, dynamic>> loginUser({
    required String identifier,
    required String password,
  }) async {
    try {
      String emailToUse = identifier.trim();

      // If user inputs Cashier ID (not an email with @), attempt Firestore lookup
      if (!emailToUse.contains('@')) {
        try {
          final querySnapshot = await _firestore
              .collection('users')
              .where('cashierId', isEqualTo: emailToUse)
              .limit(1)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            final doc = querySnapshot.docs.first;
            emailToUse = doc.data()['email'] ?? emailToUse;
          } else {
            // Check uppercase cashierId variant
            final queryUpper = await _firestore
                .collection('users')
                .where('cashierId', isEqualTo: emailToUse.toUpperCase())
                .limit(1)
                .get();

            if (queryUpper.docs.isNotEmpty) {
              emailToUse = queryUpper.docs.first.data()['email'] ?? emailToUse;
            }
          }
        } catch (queryErr) {
          debugPrint('Firestore cashierId query notice: $queryErr');
        }
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailToUse.toLowerCase(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return {'success': false, 'message': 'Gagal memverifikasi pengguna.'};
      }

      // Fetch user profile from Firestore
      Map<String, dynamic> profile = {};
      try {
        final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
        if (docSnapshot.exists && docSnapshot.data() != null) {
          profile = Map<String, dynamic>.from(docSnapshot.data()!);
        }
      } catch (fetchErr) {
        debugPrint('Firestore fetch profile notice: $fetchErr');
      }

      if (profile.isEmpty) {
        // Fallback profile if firestore doc is not accessible or not created yet
        profile = {
          'uid': user.uid,
          'nama': user.displayName ?? user.email?.split('@').first ?? 'Kasir',
          'displayName': user.displayName ?? user.email?.split('@').first ?? 'Kasir',
          'email': user.email ?? emailToUse,
          'cashierId': 'BG${user.uid.length >= 6 ? user.uid.substring(0, 6).toUpperCase() : "188889"}',
          'role': 'Barista / Kasir',
          'nomor_hp': user.phoneNumber ?? '',
        };
      }

      return {
        'success': true,
        'message': 'Login berhasil!',
        'uid': user.uid,
        'profile': profile,
      };
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException [login]: ${e.code} - ${e.message}');
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.code, isRegister: false),
      };
    } catch (e) {
      debugPrint('General error [login]: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat login: $e',
      };
    }
  }

  /// Update user profile in Firestore and Firebase Auth
  Future<bool> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      final updateData = Map<String, dynamic>.from(data);
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      if (data.containsKey('nama') || data.containsKey('displayName')) {
        final name = data['displayName'] ?? data['nama'];
        if (name != null && currentUser != null) {
          await currentUser!.updateDisplayName(name.toString());
        }
      }

      await _firestore.collection('users').doc(uid).set(
            updateData,
            SetOptions(merge: true),
          );
      return true;
    } catch (e) {
      debugPrint('Error updating user profile in Firestore: $e');
      return false;
    }
  }

  /// Get user profile snapshot from Firestore
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return Map<String, dynamic>.from(doc.data()!);
      }
    } catch (e) {
      debugPrint('Error getting user profile: $e');
    }
    return null;
  }

  /// Stream user profile in real-time from Firestore
  Stream<Map<String, dynamic>?> streamUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return Map<String, dynamic>.from(doc.data()!);
      }
      return null;
    });
  }

  /// Send password reset email
  Future<Map<String, dynamic>> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
      return {
        'success': true,
        'message': 'Tautan reset kata sandi telah dikirim ke email Anda.',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.code, isRegister: false),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Re-authenticate and update user password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return {'success': false, 'message': 'Sesi login tidak ditemukan.'};
      }

      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);

      return {
        'success': true,
        'message': 'Kata sandi berhasil diperbarui!',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.code, isRegister: false),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memperbarui kata sandi: $e',
      };
    }
  }

  /// Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return true;
      }
    } catch (e) {
      debugPrint('Error sending email verification: $e');
    }
    return false;
  }

  /// Reload user session
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      debugPrint('Error reloading user: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Translate Firebase Auth error codes to friendly Indonesian text
  String _getAuthErrorMessage(String errorCode, {required bool isRegister}) {
    switch (errorCode) {
      case 'invalid-email':
        return 'Format email tidak valid. Periksa kembali penulisan email.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan oleh administrator.';
      case 'user-not-found':
        return 'Akun dengan email / ID Kasir tersebut tidak ditemukan.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Kata sandi atau email salah. Silakan coba lagi.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan gunakan email lain atau langsung login.';
      case 'operation-not-allowed':
        return 'Metode autentikasi email belum diaktifkan di Firebase Console.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah. Minimal gunakan 6 karakter.';
      case 'network-request-failed':
        return 'Koneksi jaringan terputus. Pastikan perangkat Anda terhubung ke internet.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan gagal. Silakan tunggu beberapa saat lagi.';
      case 'requires-recent-login':
        return 'Operasi ini memerlukan login ulang demi keamanan.';
      default:
        return isRegister
            ? 'Pendaftaran gagal: $errorCode'
            : 'Login gagal: $errorCode';
    }
  }
}
