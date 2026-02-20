import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS is not configured yet.');
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDQSz_td7B6ih4N9Qql1krBv0OnSY_t5TU',
    appId: '1:89551898663:android:50c996fe5199184f1e2602',
    messagingSenderId: '89551898663',
    projectId: 'artisansmarket-5f2b6',
    storageBucket: 'artisansmarket-5f2b6.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDG1fBMvyAmmk7qNBH-mRKAX1OCd3ouKUk',
    appId: '1:89551898663:web:1891c4639d293c861e2602',
    messagingSenderId: '89551898663',
    projectId: 'artisansmarket-5f2b6',
    authDomain: 'artisansmarket-5f2b6.firebaseapp.com',
    storageBucket: 'artisansmarket-5f2b6.firebasestorage.app',
  );
}
