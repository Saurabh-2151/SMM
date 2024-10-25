import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  String name;
  String email;
  String profilePic;
  String createdAt;
  String phoneNumber;
  String uid;
  String? pass;
  String bio;

  UserModel({
    required this.name,
    required this.email,
    required this.profilePic,
    required this.createdAt,
    required this.phoneNumber,
    required this.uid,
    required this.pass,
    required this.bio
  });

  // from map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      createdAt: map['createdAt'] ?? '',
      profilePic: map['profilePic'] ?? '',
      pass: map['pass'] ?? '',
      bio: map['bio'] ?? ''
    );
  }
  final FirebaseAuth _auth = FirebaseAuth.instance;
  get userId => _auth.currentUser?.uid;

  // to map
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "uid": uid,
      "profilePic": profilePic,
      "phoneNumber": phoneNumber,
      "createdAt": createdAt,
      "pass":pass,
      "bio":bio
    };
  }
}
