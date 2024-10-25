import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smm/MobileAuth/authprovider.dart' as auth;
import 'package:smm/MobileAuth/home.dart';
import 'package:smm/MobileAuth/registeruser.dart';

class MobileNumberInput extends StatefulWidget {
  const MobileNumberInput({super.key});

  @override
  _MobileNumberInputState createState() => _MobileNumberInputState();
}

class _MobileNumberInputState extends State<MobileNumberInput> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _selectedCountryCode = '+91';
  bool isLoading = false;

  final List<String> _countryCodes = [
    '+1', // USA
    '+91', // India
    '+44', // UK
    '+61', // Australia
    '+81', // Japan
    // Add more country codes as needed
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<auth.AuthProvider>(context, listen: false);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  height: 100,
                ),
                const Row(
                  children: [
                    Text(
                      "Sign UP",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 50,
                          color: Color.fromRGBO(9, 128, 243, 1)),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                const Row(
                  children: [
                    Text('Enter Phone Number'),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color.fromRGBO(9, 128, 243, 0.2),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 80,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(20)),
                          // border: Border.all(),
                          // color: Color.fromRGBO(9, 128, 243, 0.2)
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedCountryCode,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 20),
                            border: InputBorder.none,
                          ),
                          items: _countryCodes.map((code) {
                            return DropdownMenuItem<String>(
                              value: code,
                              child: Text(code),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedCountryCode = newValue!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a country code';
                            }
                            return null;
                          },
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Container(
                          height: 64,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(20),
                                  left: Radius.circular(20)),
                              // border: Border.all(color: Colors.grey),
                              color: Color.fromRGBO(35, 142, 242, 0.432)),
                          child: TextFormField(
                            controller: _phoneController,
                            onChanged: (value) {
                              setState(() {
                                _phoneController.text = value;
                                if (value.length == 10) {
                                  FocusScope.of(context).unfocus();
                                }
                              });
                            },
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 20),
                              // labelText: 'Mobile Number',
                              border: InputBorder.none,
                              hintText: "Enter Phone Number",
                              suffixIcon: _phoneController.text.length > 9
                                  ? Container(
                                      height: 30,
                                      width: 30,
                                      margin: const EdgeInsets.all(10.0),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.green,
                                      ),
                                      child: const Icon(
                                        Icons.done,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    )
                                  : null,
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your mobile number';
                              }
                              if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                                return 'Please enter a valid 10-digit mobile number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
             
                
                const SizedBox(height: 300),
                GestureDetector(
                  onTap: sendPhoneNumber,
                  child: Container(
                    height: 60,
                    width: 400,
                    decoration: BoxDecoration(
                        color: const Color.fromRGBO(9, 128, 243, 1),
                        borderRadius: BorderRadius.circular(20)),
                    child: const Center(
                      child: Text(
                        'Get OTP',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                if (isLoading) const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void sendPhoneNumber() async {
    isLoading = true;
    setState(() {});

    final ap = Provider.of<auth.AuthProvider>(context, listen: false);
    String phoneNumber = _phoneController.text.trim();

    try {
      await ap.signInWithPhone(context, "$_selectedCountryCode$phoneNumber");
      // Navigate to OTP page or other success actions here
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
