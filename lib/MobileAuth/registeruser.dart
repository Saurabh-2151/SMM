import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smm/MobileAuth/authprovider.dart';
import 'package:smm/MobileAuth/home.dart';
import 'package:smm/MobileAuth/snackbar.dart';
import 'package:smm/MobileAuth/usermodel.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful!')),
      );
    }
  }

  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Register",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: Color.fromRGBO(9, 128, 243, 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 60,
                      width: 350,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromRGBO(219, 222, 230, 1)),
                          borderRadius: BorderRadius.circular(10),
                          color: const Color.fromRGBO(247, 248, 249, 1)),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                            hintText: "Name", border: InputBorder.none),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 60,
                      width: 350,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromRGBO(219, 222, 230, 1)),
                          borderRadius: BorderRadius.circular(10),
                          color: const Color.fromRGBO(247, 248, 249, 1)),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 60,
                      width: 350,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromRGBO(219, 222, 230, 1)),
                          borderRadius: BorderRadius.circular(10),
                          color: const Color.fromRGBO(247, 248, 249, 1)),
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                            hintText: 'Password',
                            border: InputBorder.none,
                            suffixIcon: Icon(Icons.visibility)),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 60,
                      width: 350,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromRGBO(219, 222, 230, 1)),
                          borderRadius: BorderRadius.circular(10),
                          color: const Color.fromRGBO(247, 248, 249, 1)),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(
                            hintText: 'Confirm Password',
                            border: InputBorder.none,
                            suffixIcon: Icon(Icons.visibility)),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              const SizedBox(
                height: 150,
              ),
              Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isChecked = value ?? false;
                      });
                    },
                  ),
                  const Text('  I agree to the '),
                  const Text(
                    'Privacy policy',
                    style: TextStyle(color: Colors.blue),
                  ),
                  const Text(' and'),
                  const Text(
                    ' Terms of use.',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
              GestureDetector(
                onTap: storeData,
                child: Container(
                  height: 60,
                  width: 400,
                  decoration: BoxDecoration(
                      color: const Color.fromRGBO(9, 128, 243, 1),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Center(
                    child: Text(
                      'Register',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  void storeData() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    UserModel userModel = UserModel(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      profilePic: "",
      createdAt: "",
      phoneNumber: "",
      uid: "",
      pass: _passwordController.text.trim(),
      bio:""

    );
    if(_isChecked != true){
      showSnackBar(context, "Please agree terms");

    }
    if (_isChecked != false && _nameController.text.isNotEmpty && _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty &&  _passwordController.text==_confirmPasswordController.text) {
      ap.saveUserDataToFirebase(
        context: context,
        userModel: userModel,
        onSuccess: () {
          ap.saveUserDataToSP().then(
                (value) => ap.setSignIn().then(
                      (value) => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                          (route) => false),
                    ),
              );
        },
      );
    } else {
      showSnackBar(context, "Please upload required (*) documents");
    }
  }
}

