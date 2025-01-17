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
    apiKey: 'AIzaSyDdSKqFt05e4sedNwy8mPd5Gn0y9yD7vgA',
    appId: '1:403535321532:web:4f8e54d852b7ec6fe273b9',
    messagingSenderId: '403535321532',
    projectId: 'gestao-tarefas-domesticas',
    authDomain: 'gestao-tarefas-domesticas.firebaseapp.com',
    storageBucket: 'gestao-tarefas-domesticas.firebasestorage.app',
    measurementId: 'G-0D4P5KHS8L',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyColibyc4Ba_soSd77IhhH2PV8QWgiMRqE',
    appId: '1:403535321532:android:c3fc64bd81782562e273b9',
    messagingSenderId: '403535321532',
    projectId: 'gestao-tarefas-domesticas',
    storageBucket: 'gestao-tarefas-domesticas.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCkuS1TBz3qtemoKe377dU2u5ThnEHgf6o',
    appId: '1:403535321532:ios:51ff73e38d387606e273b9',
    messagingSenderId: '403535321532',
    projectId: 'gestao-tarefas-domesticas',
    storageBucket: 'gestao-tarefas-domesticas.firebasestorage.app',
    iosBundleId: 'com.example.domesticas',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCkuS1TBz3qtemoKe377dU2u5ThnEHgf6o',
    appId: '1:403535321532:ios:51ff73e38d387606e273b9',
    messagingSenderId: '403535321532',
    projectId: 'gestao-tarefas-domesticas',
    storageBucket: 'gestao-tarefas-domesticas.firebasestorage.app',
    iosBundleId: 'com.example.domesticas',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDdSKqFt05e4sedNwy8mPd5Gn0y9yD7vgA',
    appId: '1:403535321532:web:43b98663ef91d857e273b9',
    messagingSenderId: '403535321532',
    projectId: 'gestao-tarefas-domesticas',
    authDomain: 'gestao-tarefas-domesticas.firebaseapp.com',
    storageBucket: 'gestao-tarefas-domesticas.firebasestorage.app',
    measurementId: 'G-SDLZ53MW6B',
  );
}
