import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService {
  static final FirebaseAuthService instance = FirebaseAuthService._internal();
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  /// Register a new user with Firebase Authentication and save profile in Firestore
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
        'email': normalizedEmail,
        'nomor_hp': phone ?? '',
        'asalKota': city ?? '',
        'cashierId': finalCashierId,
        'role': finalRole,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Save user profile to Firestore (with safe fallback if Firestore rules are locked)
      try {
        await _firestore.collection('users').doc(user.uid).set(profileData);
      } catch (firestoreErr) {
        debugPrint(
          'Firestore write warning (Rules may be locked): $firestoreErr',
        );
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
            // Check lowercase / uppercase cashierId variant
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

      // Fetch user profile from Firestore (with fallback)
      Map<String, dynamic> profile = {};
      try {
        final docSnapshot =
            await _firestore.collection('users').doc(user.uid).get();

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
          'email': user.email ?? emailToUse,
          'cashierId':
              'BG${user.uid.length >= 6 ? user.uid.substring(0, 6).toUpperCase() : "188889"}',
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

  /// Update user profile in Firestore
  Future<bool> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      final updateData = Map<String, dynamic>.from(data);
      updateData['updatedAt'] = FieldValue.serverTimestamp();
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
      default:
        return isRegister
            ? 'Pendaftaran gagal: $errorCode'
            : 'Login gagal: $errorCode';
    }
  }
}
