// Placeholder file.
// IMPORTANT: Run this command in your project root before running the app:
// flutterfire configure
// The command will replace this file with real FirebaseOptions for your Firebase project.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError('Run flutterfire configure to generate Linux Firebase options.');
      default:
        throw UnsupportedError('This platform is not supported.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCcqBzoF6q0BprAC6UQ9yQFF8wbyQ1-gck',
    appId: '1:600964516478:web:20332d6bb81891c37ae62f',
    messagingSenderId: '600964516478',
    projectId: 'healthtracker-8ff27',
    authDomain: 'healthtracker-8ff27.firebaseapp.com',
    storageBucket: 'healthtracker-8ff27.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAqZlC-y4dS_mT17t_qFRP3mSKI236i8XE',
    appId: '1:600964516478:ios:b8f140785484f08c7ae62f',
    messagingSenderId: '600964516478',
    projectId: 'healthtracker-8ff27',
    storageBucket: 'healthtracker-8ff27.firebasestorage.app',
    androidClientId: '600964516478-0j7kdmrlfenmnsggpd8ed3qcolasu67q.apps.googleusercontent.com',
    iosClientId: '600964516478-95q7m2riufueni57k13invu3est34kb1.apps.googleusercontent.com',
    iosBundleId: 'com.example.healthTrackerRebuild',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAqZlC-y4dS_mT17t_qFRP3mSKI236i8XE',
    appId: '1:600964516478:ios:b8f140785484f08c7ae62f',
    messagingSenderId: '600964516478',
    projectId: 'healthtracker-8ff27',
    storageBucket: 'healthtracker-8ff27.firebasestorage.app',
    androidClientId: '600964516478-0j7kdmrlfenmnsggpd8ed3qcolasu67q.apps.googleusercontent.com',
    iosClientId: '600964516478-95q7m2riufueni57k13invu3est34kb1.apps.googleusercontent.com',
    iosBundleId: 'com.example.healthTrackerRebuild',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBXQAi95PC8xsxkEnMd1OGuM9G2SZPF2Y4',
    appId: '1:600964516478:android:9260872c99d379027ae62f',
    messagingSenderId: '600964516478',
    projectId: 'healthtracker-8ff27',
    storageBucket: 'healthtracker-8ff27.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCcqBzoF6q0BprAC6UQ9yQFF8wbyQ1-gck',
    appId: '1:600964516478:web:2267df426c3f12227ae62f',
    messagingSenderId: '600964516478',
    projectId: 'healthtracker-8ff27',
    authDomain: 'healthtracker-8ff27.firebaseapp.com',
    storageBucket: 'healthtracker-8ff27.firebasestorage.app',
  );
}
