import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smm/MobileAuth/home.dart';
import 'package:smm/MobileAuth/landing.dart';
import 'package:smm/MobileAuth/snackbar.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = "/splash";

  const SplashScreen({super.key});

  @override
  State createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _navigateToHome();
    checkNetworkStatus();
  }
  Future<void> checkNetworkStatus() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      showSnackBar(context, "Warning: You are using mobile data.");
    } else if (connectivityResult == ConnectivityResult.none) {
      showSnackBar(context, "No internet connection");
    }
  }
  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    SharedPreferences s = await SharedPreferences.getInstance();
    String data = s.getString("user_model") ?? '';
    print("-------------------------------------");
    print(data);

    // Check if the user is already signed in
    if (data != '') {
      // User is signed in, navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const HomePage()), // Replace HomeScreen with the actual home screen
      );
    } else {
      // User is not signed in, navigate to RegisterScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LandingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {


    return Material(
      color: Colors.white, // Set the background color here
      child: GestureDetector(
        onTap: () {
          // Handle tap by navigating to the appropriate screen
          _navigateToHome();
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                child:Image.asset('assets/images/lan7.png',height: 150,
          width: 300,),
                ),
              
            ],
          ),
        ),
      ),
    );
  }
}
