import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smm/MobileAuth/home.dart';
import 'package:smm/MobileAuth/mobilereg.dart';
import 'package:smm/MobileAuth/signup.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State createState() => _LandingPageState();
}

class _LandingPageState extends State {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    String? _email;
    String? _password;

    // Simple email validation function
    String? _validateEmail(String? value) {
      if (value == null || value.isEmpty) {
        return 'Please enter your email';
      }
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(value)) {
        return 'Enter a valid email';
      }
      return null;
    }

    // Simple password validation function
    String? _validatePassword(String? value) {
      if (value == null || value.isEmpty) {
        return 'Please enter your password';
      }
      if (value.length < 6) {
        return 'Password must be at least 6 characters long';
      }
      return null;
    }

   void _login() async {
  try {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Firebase login with email and password
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // If login is successful, navigate to the home screen
      if (userCredential.user != null) {
        // Navigate to HomeScreen (replace with your actual home screen widget)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()), // Make sure HomeScreen exists
        );
      }
    }
  } catch (e) {
    // Display error message if login fails
    print('Login failed: $e');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Login Failed'),
          content: Text(e.toString()), // Display error message
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}


   
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  width: double.infinity,
                  height: 70,
                ),
                Image.asset(
                  'assets/images/lan7.png',
                  height: 150,
                  width: 300,
                ),
                const SizedBox(
                  height: 50,
                ),
                // Email TextFormField
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 194, 226, 255),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Gmail',
                          hintText: 'Enter your Gmail',
                          prefixIcon: Icon(Icons.email), // Email icon
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10.0), // Rounded corners
                          ),
                          filled: true, // Adds a background color
                          fillColor:
                              Colors.grey[200], // Background color for input field
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                        ),
                        validator: _validateEmail,
                        onSaved: (value) => _email = value,
                      ),
                      const SizedBox(height: 50,),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: Icon(Icons.lock), // Lock icon for password
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10.0), // Rounded corners
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                        ),
                        validator: _validatePassword,
                        onSaved: (value) => _password = value,
                      ),
                      
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _login,
                        child: Text('Login'),
                      ),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          GestureDetector(
                            onTap: () {
                              // Handle the registration navigation here
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Signup()), // Replace with your RegisterScreen
                              );
                            },
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration
                                    .underline, // Adds underline to indicate it's clickable
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),

                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 58, 63, 219),
                      shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      "OR",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              
                const SizedBox(
                  height: 50,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MobileNumberInput()),
                    );
                  },
                  child: Container(
                    height: 50,
                    width: 250,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 58, 63, 219),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                            bottom: Radius.circular(15)),
                        border: Border.all(
                            color: const Color.fromARGB(255, 58, 63, 219))),
                    child: const Center(
                      child: Text(
                        'Login with Phone',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
