import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smm/MobileAuth/authprovider.dart';
import 'package:smm/Story/storyprovider.dart';

import 'package:smm/splash_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
     // Initialize Firebase App
  await Firebase.initializeApp(
    options: Platform.isAndroid
        ? const FirebaseOptions(
            apiKey: 'AIzaSyCpZY7I3yX5HwsjsO23kTRTBaPuIbnVdNg',
            appId: '1:1032714293588:android:fdd4bce7aadc7c967b78c1',
            messagingSenderId: '1032714293588',
            projectId: 'swmm-3f885',
            storageBucket: 'swmm-3f885.appspot.com',
          )
        : null,
  );

  //Activate Firebase App Check
    SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });

  

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // SizeConfig().init(context);
    

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MediaManagerProvider()),
      ],
      child:  const MaterialApp(
       
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
