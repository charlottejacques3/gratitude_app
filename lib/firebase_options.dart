// File generated by FlutterFire CLI.
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
    apiKey: 'AIzaSyCRHHojMmxOzm5_4tj3YjJj7K1tjYXbCWs',
    appId: '1:888375458694:web:f3c0915dbc0abe25528a07',
    messagingSenderId: '888375458694',
    projectId: 'gratitude-app-1c2df',
    authDomain: 'gratitude-app-1c2df.firebaseapp.com',
    databaseURL: 'https://gratitude-app-1c2df.firebasedatabase.app',
    storageBucket: 'gratitude-app-1c2df.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAiv6MefsfBy0GduAZ496sNVnThY3og7Ss',
    appId: '1:888375458694:android:b6cce6e411a95b0b528a07',
    messagingSenderId: '888375458694',
    projectId: 'gratitude-app-1c2df',
    storageBucket: 'gratitude-app-1c2df.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB3Z93efoENtpolFr6E60Qx2E_mgSEtrvM',
    appId: '1:888375458694:ios:63587ed623f3d5b5528a07',
    messagingSenderId: '888375458694',
    projectId: 'gratitude-app-1c2df',
    storageBucket: 'gratitude-app-1c2df.firebasestorage.app',
    iosBundleId: 'com.example.gratitudeApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB3Z93efoENtpolFr6E60Qx2E_mgSEtrvM',
    appId: '1:888375458694:ios:63587ed623f3d5b5528a07',
    messagingSenderId: '888375458694',
    projectId: 'gratitude-app-1c2df',
    storageBucket: 'gratitude-app-1c2df.firebasestorage.app',
    iosBundleId: 'com.example.gratitudeApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCRHHojMmxOzm5_4tj3YjJj7K1tjYXbCWs',
    appId: '1:888375458694:web:79a9e6e5271ab123528a07',
    messagingSenderId: '888375458694',
    projectId: 'gratitude-app-1c2df',
    authDomain: 'gratitude-app-1c2df.firebaseapp.com',
    storageBucket: 'gratitude-app-1c2df.firebasestorage.app',
  );

}