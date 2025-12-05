// File generated manually with fix for Realtime Database URL.
// ignore_for_file: type=lint

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAe3f7pGq4u51DVcupiC3qk1MvGB3UkjIk',
    appId: '1:622209886204:web:727805d437af6acfb6b479',
    messagingSenderId: '622209886204',
    projectId: 'fintrack-c689a',
    authDomain: 'fintrack-c689a.firebaseapp.com',
    storageBucket: 'fintrack-c689a.firebasestorage.app',
    measurementId: 'G-J3ZPWFSH4N',

    /// FIXED — tambahkan databaseURL
    databaseURL: 'https://fintrack-c689a-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAIdXd43dDV3tl9vWPUP05pWivPtuDfubo',
    appId: '1:622209886204:android:8cd5e94af438fc5ab6b479',
    messagingSenderId: '622209886204',
    projectId: 'fintrack-c689a',
    storageBucket: 'fintrack-c689a.firebasestorage.app',

    /// FIXED
    databaseURL: 'https://fintrack-c689a-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCYK4Vj_QIi0EUqQ9Y21SxrlyEzloSrPaI',
    appId: '1:622209886204:ios:f4137e73d1089c5fb6b479',
    messagingSenderId: '622209886204',
    projectId: 'fintrack-c689a',
    storageBucket: 'fintrack-c689a.firebasestorage.app',
    iosBundleId: 'com.example.fintrack',

    /// FIXED
    databaseURL: 'https://fintrack-c689a-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCYK4Vj_QIi0EUqQ9Y21SxrlyEzloSrPaI',
    appId: '1:622209886204:ios:f4137e73d1089c5fb6b479',
    messagingSenderId: '622209886204',
    projectId: 'fintrack-c689a',
    storageBucket: 'fintrack-c689a.firebasestorage.app',
    iosBundleId: 'com.example.fintrack',

    /// FIXED
    databaseURL: 'https://fintrack-c689a-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAe3f7pGq4u51DVcupiC3qk1MvGB3UkjIk',
    appId: '1:622209886204:web:7e312ce7f8cd5952b6b479',
    messagingSenderId: '622209886204',
    projectId: 'fintrack-c689a',
    authDomain: 'fintrack-c689a.firebaseapp.com',
    storageBucket: 'fintrack-c689a.firebasestorage.app',
    measurementId: 'G-VEB4YL7EJV',

    /// FIXED
    databaseURL: 'https://fintrack-c689a-default-rtdb.asia-southeast1.firebasedatabase.app',
  );
}