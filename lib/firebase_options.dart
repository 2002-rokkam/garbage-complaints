// firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    } else {
      throw UnsupportedError(
        'DefaultFirebaseOptions are not supported for this platform.',
      );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyBZyHW6mEU2b-zUT8QICLsGL0Z9i1oKFis",
      authDomain: "sbmg-504f0.firebaseapp.com",
      projectId: "sbmg-504f0",
      storageBucket: "sbmg-504f0.firebasestorage.app",
      messagingSenderId: "959280236765",
      appId: "1:959280236765:web:bb1f274a8cb58ad5a6b334"
  );
}
