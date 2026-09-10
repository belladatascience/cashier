import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

extension ExtendedNavigator on BuildContext {
  /// Internal helper to log screen transitions to Firebase / Analytics
  void _logScreenToFirebase(String screenName) {
    try {
      final user = FirebaseAuth.instance.currentUser;
      () async {
        try {
          await FirebaseFirestore.instance.collection('screen_views').add({
            'screenName': screenName,
            'uid': user?.uid ?? 'guest',
            'email': user?.email ?? 'anonymous',
            'timestamp': FieldValue.serverTimestamp(),
          });
        } catch (_) {}
      }();
    } catch (_) {
      // Non-blocking firestore analytics logging
    }
  }

  Future<dynamic> push(Widget page, {String? name, bool logAnalytics = true}) async {
    final screenName = name ?? page.runtimeType.toString();
    if (logAnalytics) {
      _logScreenToFirebase(screenName);
    }

    return Navigator.push(
      this,
      MaterialPageRoute(
        builder: (_) => page,
        settings: RouteSettings(name: screenName),
      ),
    );
  }

  Future<dynamic> pushReplacement(Widget page, {String? name, bool logAnalytics = true}) async {
    final screenName = name ?? page.runtimeType.toString();
    if (logAnalytics) {
      _logScreenToFirebase(screenName);
    }

    return Navigator.pushReplacement(
      this,
      MaterialPageRoute(
        builder: (_) => page,
        settings: RouteSettings(name: screenName),
      ),
    );
  }

  Future<dynamic> pushNamed(String routeName, {Object? arguments, bool logAnalytics = true}) async {
    if (logAnalytics) {
      _logScreenToFirebase(routeName);
    }
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushReplacementNamed(
    String newRouteName, {
    Object? arguments,
    bool logAnalytics = true,
  }) {
    if (logAnalytics) {
      _logScreenToFirebase(newRouteName);
    }
    return Navigator.of(
      this,
    ).pushReplacementNamed(newRouteName, arguments: arguments);
  }

  Future<dynamic> pushNamedAndRemoveUntil(
    String newRouteName,
    RoutePredicate predicate, {
    Object? arguments,
    bool logAnalytics = true,
  }) async {
    if (logAnalytics) {
      _logScreenToFirebase(newRouteName);
    }
    return Navigator.pushNamedAndRemoveUntil(
      this,
      newRouteName,
      predicate,
      arguments: arguments,
    );
  }

  Future<dynamic> pushAndRemoveAll(Widget page, {String? name, bool logAnalytics = true}) async {
    final screenName = name ?? page.runtimeType.toString();
    if (logAnalytics) {
      _logScreenToFirebase(screenName);
    }

    return Navigator.pushAndRemoveUntil(
      this,
      MaterialPageRoute(
        builder: (_) => page,
        settings: RouteSettings(name: screenName),
      ),
      (route) => false,
    );
  }

  /// Navigasi terlindungi: Memeriksa sesi Firebase Auth sebelum membuka layar tujuan
  Future<dynamic> pushAuthGuarded(
    Widget page, {
    required Widget fallbackLoginPage,
    String? name,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return push(page, name: name);
    } else {
      return push(fallbackLoginPage, name: 'LoginScreen');
    }
  }

  /// Logout dari Firebase Auth dan bersihkan seluruh riwayat navigasi
  Future<void> signOutAndNavigate(Widget loginScreen) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    if (mounted) {
      await pushAndRemoveAll(loginScreen);
    }
  }

  void pop([dynamic result]) {
    if (Navigator.canPop(this)) {
      Navigator.of(this).pop(result);
    }
  }
}
