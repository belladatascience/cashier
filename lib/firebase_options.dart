// File configured for cashier-018 Firebase project.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static const String projectId = 'cashier-018';
  static const String storageBucket = 'cashier-018.firebasestorage.app';
  static const String messagingSenderId = '941065128286';

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.linux:
        return web;
      default:
        return android;
    }
  }

  /// Safe accessor yang tidak pernah throw UnsupportedError
  static FirebaseOptions get currentPlatformSafe {
    try {
      return currentPlatform;
    } catch (_) {
      return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBS9NDp5k_r6LEcFQs2_yFccRaQOS0ya3k',
    appId: '1:941065128286:web:4c1b85d93a7c5688cd67cf',
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    authDomain: 'cashier-018.firebaseapp.com',
    storageBucket: storageBucket,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC0YMEa5EnMoXIaSvJeEEg1m_5j4Rfg31M',
    appId: '1:941065128286:android:25bfe1df08315af3cd67cf',
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBS9NDp5k_r6LEcFQs2_yFccRaQOS0ya3k',
    appId: '1:941065128286:web:4c1b85d93a7c5688cd67cf',
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    authDomain: 'cashier-018.firebaseapp.com',
    storageBucket: storageBucket,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBS9NDp5k_r6LEcFQs2_yFccRaQOS0ya3k',
    appId: '1:941065128286:ios:25bfe1df08315af3cd67cf',
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
    iosBundleId: 'com.bga.cashier',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBS9NDp5k_r6LEcFQs2_yFccRaQOS0ya3k',
    appId: '1:941065128286:ios:25bfe1df08315af3cd67cf',
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
    iosBundleId: 'com.bga.cashier',
  );
}
