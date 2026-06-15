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
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyClyJnAcSTRsNp6kiD7YfIxI29EEWB8qjY',
    appId: '1:459237597212:web:a01f5406ce835020617fd9',
    messagingSenderId: '459237597212',
    projectId: 'unigo-92182',
    authDomain: 'unigo-92182.firebaseapp.com',
    storageBucket: 'unigo-92182.firebasestorage.app',
    measurementId: 'G-HQQLMLHB6S',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCbdxY-jmSjucXM78IRtMFZNf1N-GkRwMU',
    appId: '1:459237597212:android:79db5f5166793c8a617fd9',
    messagingSenderId: '459237597212',
    projectId: 'unigo-92182',
    storageBucket: 'unigo-92182.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAoo2K_clzKRbp6iyeuPlnT2LU8Vnvag0M',
    appId: '1:459237597212:ios:d8b4521cf509c651617fd9',
    messagingSenderId: '459237597212',
    projectId: 'unigo-92182',
    storageBucket: 'unigo-92182.firebasestorage.app',
    iosBundleId: 'com.example.projetoApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAoo2K_clzKRbp6iyeuPlnT2LU8Vnvag0M',
    appId: '1:459237597212:ios:d8b4521cf509c651617fd9',
    messagingSenderId: '459237597212',
    projectId: 'unigo-92182',
    storageBucket: 'unigo-92182.firebasestorage.app',
    iosBundleId: 'com.example.projetoApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyClyJnAcSTRsNp6kiD7YfIxI29EEWB8qjY',
    appId: '1:459237597212:web:c65bda281cb7d241617fd9',
    messagingSenderId: '459237597212',
    projectId: 'unigo-92182',
    authDomain: 'unigo-92182.firebaseapp.com',
    storageBucket: 'unigo-92182.firebasestorage.app',
    measurementId: 'G-BL8TFKYN37',
  );
}
