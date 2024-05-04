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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBDu4XIweu_KQN5py0J7U_p-qQkcj2mPkc',
    appId: '1:409254426375:android:1249b7ae0bfb62f7d8f7a2',
    messagingSenderId: '409254426375',
    projectId: 'aletrail-d4ee5',
    databaseURL: 'https://aletrail-d4ee5-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'aletrail-d4ee5.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDgTkR3nZEdqJeSKwBQsEFEdMOLXSLqAaY',
    appId: '1:409254426375:ios:c78acc61f00c951ed8f7a2',
    messagingSenderId: '409254426375',
    projectId: 'aletrail-d4ee5',
    databaseURL: 'https://aletrail-d4ee5-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'aletrail-d4ee5.appspot.com',
    iosBundleId: 'com.mmcapplications.aletrail',
  );
}
