// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    // if (kIsWeb) {
    //   return web;
    // }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      // case TargetPlatform.macOS:
      //   return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // static const FirebaseOptions web = FirebaseOptions(
  //   apiKey: 'AIzaSyB7wZb2tO1-Fs6GbDADUSTs2Qs3w08Hovw',
  //   appId: '1:406099696497:web:87e25e51afe982cd3574d0',
  //   messagingSenderId: '406099696497',
  //   projectId: 'flutterfire-e2e-tests',
  //   authDomain: 'flutterfire-e2e-tests.firebaseapp.com',
  //   databaseURL:
  //       'https://flutterfire-e2e-tests-default-rtdb.europe-west1.firebasedatabase.app',
  //   storageBucket: 'flutterfire-e2e-tests.appspot.com',
  //   measurementId: 'G-JN95N1JV2E',
  // );

  // static const FirebaseOptions android = FirebaseOptions(
  //     apiKey: 'AIzaSyAy9xVRTODsWb6XD4jDAiAIDFFhH3Ti0zg',
  //     appId: '1:514489874522:android:fd1cad39c667777b9ec063',
  //     messagingSenderId: '514489874522',
  //     projectId: 'yaams-a1330',
  //     androidClientId:
  //         "514489874522-dao2cp991k2e01je93foa6212vf5vvma.apps.googleusercontent.com");

  static const FirebaseOptions android = FirebaseOptions(
      apiKey: 'AIzaSyDcRdUvdV3s9WUY1fZ_uHiyHkAez1OfXgQ',
      appId: '1:556221488660:android:97eba12527006e4e925101',
      messagingSenderId: '556221488660',
      projectId: 'bvidyademo-a8de4',
      androidClientId:
          "556221488660-eidolne52inj44cq8etetl0dsvsfob3u.apps.googleusercontent.com");

  static const FirebaseOptions ios = FirebaseOptions(
      apiKey: 'AIzaSyB8sVMXhK5uvXnkMI0Ng1rq3CoAgr0-3sE',
      appId: '1:556221488660:ios:68066b9e56a6eaf3925101',
      messagingSenderId: '556221488660',
      projectId: 'bvidyademo-a8de4',
      iosBundleId: 'com.bvidyademo',
      iosClientId:
          "556221488660-435c59kakcdddhmo8c20aqofjoio3tgc.apps.googleusercontent.com");

  // static const FirebaseOptions ios = FirebaseOptions(
  //   apiKey: 'AIzaSyCS3q8CKbTno8Cwun1cu-RueS1LSCQIDxY',
  //   appId: '1:119301962380:ios:7b69ceadf7ea356a1299a9',
  //   messagingSenderId: '119301962380',
  //   projectId: 'bvidya-36b76',
  //   iosBundleId: 'com.bvidya',
  //   iosClientId: "119301962380-fuqlmp6si5ft3874ld5shsq1mi1je61f.apps.googleusercontent.com"
  // );

  // static const FirebaseOptions macos = FirebaseOptions(
  //   apiKey: 'AIzaSyCS3q8CKbTno8Cwun1cu-RueS1LSCQIDxY',
  //   appId: '1:406099696497:ios:acd9c8e17b5e620e3574d0',
  //   messagingSenderId: '406099696497',
  //   projectId: 'flutterfire-e2e-tests',
  //   databaseURL:
  //       'https://flutterfire-e2e-tests-default-rtdb.europe-west1.firebasedatabase.app',
  //   storageBucket: 'flutterfire-e2e-tests.appspot.com',
  //   androidClientId:
  //       '406099696497-tvtvuiqogct1gs1s6lh114jeps7hpjm5.apps.googleusercontent.com',
  //   iosClientId:
  //       '406099696497-taeapvle10rf355ljcvq5dt134mkghmp.apps.googleusercontent.com',
  //   iosBundleId: 'io.flutter.plugins.firebase.tests',
  // );
}
// FirebaseOptions(
//   apiKey: "AIzaSyCS3q8CKbTno8Cwun1cu-RueS1LSCQIDxY",
//   appId: "1:119301962380:ios:7b69ceadf7ea356a1299a9",
//   messagingSenderId: "119301962380",
//   projectId: "bvidya-36b76",
// ),