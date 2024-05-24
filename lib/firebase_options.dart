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
    apiKey: 'AIzaSyAE2sQwPjMRs_agjHP558zAJ0igb_BPT0k',
    appId: '1:909529745705:web:554896f33cd7cd322d8f38',
    messagingSenderId: '909529745705',
    projectId: 'weatherwise-ec5f3',
    authDomain: 'weatherwise-ec5f3.firebaseapp.com',
    storageBucket: 'weatherwise-ec5f3.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDR77u6JsK-FEhUKYUv5Pd4B5p8Sip1hYw',
    appId: '1:909529745705:android:36bd0a707c4ce6102d8f38',
    messagingSenderId: '909529745705',
    projectId: 'weatherwise-ec5f3',
    storageBucket: 'weatherwise-ec5f3.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCUE-MHUPD_mMBytVxFeI1_u9Au8_FUD9E',
    appId: '1:909529745705:ios:df3e4075a05d56422d8f38',
    messagingSenderId: '909529745705',
    projectId: 'weatherwise-ec5f3',
    storageBucket: 'weatherwise-ec5f3.appspot.com',
    iosBundleId: 'com.example.weatherWise',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCUE-MHUPD_mMBytVxFeI1_u9Au8_FUD9E',
    appId: '1:909529745705:ios:df3e4075a05d56422d8f38',
    messagingSenderId: '909529745705',
    projectId: 'weatherwise-ec5f3',
    storageBucket: 'weatherwise-ec5f3.appspot.com',
    iosBundleId: 'com.example.weatherWise',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAE2sQwPjMRs_agjHP558zAJ0igb_BPT0k',
    appId: '1:909529745705:web:cda00e3b140bc97c2d8f38',
    messagingSenderId: '909529745705',
    projectId: 'weatherwise-ec5f3',
    authDomain: 'weatherwise-ec5f3.firebaseapp.com',
    storageBucket: 'weatherwise-ec5f3.appspot.com',
  );
}