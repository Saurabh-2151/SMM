import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:smm/MobileAuth/authprovider.dart';
import 'package:smm/MobileAuth/home.dart';
import 'package:smm/MobileAuth/mobilereg.dart';
import 'package:smm/MobileAuth/registeruser.dart';
import 'package:smm/MobileAuth/snackbar.dart';

class OtpInputScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  const OtpInputScreen({super.key, required this.verificationId, required this.phoneNumber});

  @override
  State createState() => _OtpInputScreenState();
}

class _OtpInputScreenState extends State<OtpInputScreen> {
  String? otpCode;
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 100),
                const Text(
                  "Enter OTP",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 50,
                    color: Color.fromRGBO(9, 128, 243, 1),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "We have sent OTP to",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.phoneNumber,
                  style:const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                 Pinput(
                        length: 6,
                        showCursor: true,
                        defaultPinTheme: PinTheme(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                        color: const Color.fromRGBO(180, 218, 255, 1),
                        borderRadius: BorderRadius.circular(15)
                          ),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onCompleted: (value) {
                          setState(() {
                            otpCode = value;
                            
                          });
                        },
                      ),
        
                
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: (){
                    Provider.of<AuthProvider>(context, listen: false).resendOtp(
                                      phoneNumber: widget.phoneNumber,
                                      context: context,
                                      onSuccess: () {
                                        // Handle success if needed
                                      },
                                      onFailed: (error) {
                                        // Handle failure if needed
                                      },
                                    );
                      },
                      child: const Text(
                        "Resend OTP",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(9, 128, 243, 1),
                          fontSize: 15
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MobileNumberInput(),
                ),
                (route) => false,
              );
                      },
                      child: const Text(
                        "Change number",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(9, 128, 243, 1),
                          fontSize: 15
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 260),
                  GestureDetector(
                    onTap: (){
                      if (otpCode != null) {
                              verifyOtp(context, otpCode!);
                            } else {
                              showSnackBar(context, "Enter 6-Digit code");
                            }
                    },
                    child: Container(
                      height: 60,
                      width: 320,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(9, 128, 243, 1),
                        borderRadius: BorderRadius.circular(20)
                        
                      ),
                      child: const Center(
                        child: Text('Next',
                          
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
    void verifyOtp(BuildContext context, String userOtp) {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    ap.verifyOtp(
      context: context,
      verificationId: widget.verificationId,
      userOtp: userOtp,
      onSuccess: () {
        ap.checkExistingUser().then(
          (value) async {
            if (value == true) {
              ap.getDataFromFirestore().then(
                (value) => ap.saveUserDataToSP().then(
                  (value) => ap.setSignIn().then(
                    (value) => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>const HomePage(),
                      ),
                      (route) => false,
                    ),
                  ),
                ),
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => RegistrationScreen(),
                ),
                (route) => false,
              );
            }
          },
        );
      },
    );
  }
}
