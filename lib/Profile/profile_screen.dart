
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smm/MobileAuth/authprovider.dart' as auth;
import 'package:smm/MobileAuth/landing.dart';
import 'package:smm/MobileAuth/mobilereg.dart';
import 'package:smm/MobileAuth/snackbar.dart';
import 'package:smm/MobileAuth/usermodel.dart';
import 'package:smm/Story/story_view.dart';
import 'package:smm/screen/add.dart';
import 'package:smm/screen/postwidget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State {
  TextEditingController bioController=TextEditingController();
    UserModel? u;
    File? image;
  bool isUserLoaded = false;
  bool isEdit=false;
  bool isload=false;
Future<String?> getBio() async {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(userId).get(); 
  if (doc.exists) {
    return doc.get('bio');
  } else {
    return null; // User document not found
  }
}
  Future<void> getData() async {
    final ap = Provider.of<auth.AuthProvider>(context,
        listen: false); // Use the alias

    await ap.getDataFromSP();
    setState(() {
      u = ap.userModel;
      isUserLoaded = true;
     
    });
  }

 void selectImage() async {
  final ap = Provider.of<auth.AuthProvider>(context,
        listen: false); 
    image = await pickImage(context);
    if(image != null){
      await ap.updateProfile(context, image);
    }
    await getData();
    
    setState(() {
      isload =false;
    });
  }
  void _updateBio() {
    final ap = Provider.of<auth.AuthProvider>(context,
        listen: false); 
        ap.updateBio(context, bioController.text);
        getData();
        
        isEdit=false;
        setState(() {
          
        });
  }

  @override
  void initState() {
    super.initState();
    getData();
    setState(() {});
  }
  String? bio="Your bio";
  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
         backgroundColor: Colors.white,
        title: Text(
          "MEMORIES",
          style: GoogleFonts.poppins(fontSize: 21, fontWeight: FontWeight.w700,
         ),
        ),
        actions: [
          GestureDetector(
            onTap: (){
             
              Navigator.push(context, MaterialPageRoute(builder: (context)=> const AddScreen() ));
            },
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(), borderRadius: BorderRadius.circular(5)),
                child: Icon(
                  Icons.add,
                  size: 20,
                  
                )),
          ),
          const SizedBox(
            width: 20,
          ),
          
        ],
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              child: Text('MEMORIES'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                 print("🏀🏀🏀🏀🏀🏀🏀🏀🏀🏀🏀🏀🏀🏀🏀🏀🏀🏀🏀🏀");
              print(FirebaseAuth.instance.currentUser?.uid);
                _showLogoutConfirmationDialog(context);
                
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if(isUserLoaded != true)
          const CircularProgressIndicator(

          ),
          Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  isload ? CircularProgressIndicator():
                  InkWell(
                        onTap: () => selectImage(),
                        child: u?.profilePic == null
                            ? const CircleAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage: AssetImage("assets/images/user_image.png"),
                                radius: 50,
                                
                              )
                            : CircleAvatar(
                                backgroundImage: NetworkImage(u?.profilePic??"assets/images/user_image.png"),
                                radius: 50,
                              ),
                      ),
                  const SizedBox(
                    width: 30,
                  ),
                  Text(
                     u?.name ?? "UserName",
                    style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.w500,
                      ),
                        
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  
                  !isEdit  ?buildBio() :Container(
                    width: 200,
                    child: TextField(
                      cursorColor: Colors.black,
                      controller: bioController,
                      style:const TextStyle(color: Colors.black), // For the text color
                      decoration:const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      // Use a Container to set the width
                      maxLines: 1,
                      onSubmitted: (_) => _updateBio(),
                    ),
                  ),

                  const SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        isEdit=true;
                      });
                    },
                    child: Icon(Icons.edit,))
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> StoriesPageView()));
                },
                child: Container(
                  height: 50,
                  width: 200,
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(9, 128, 243, 1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: Text(
                      'STORY',
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
           const SizedBox(
                height: 30,
              ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('userId', isEqualTo: userId) 
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
      
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No posts yet.'));
          }
      
          final posts = snapshot.data!.docs;
      
          return  ListView.builder(
  itemCount: posts.length,
  itemBuilder: (context, index) {
    final post = posts[index];

    final Map<String, dynamic> postData = post.data() as Map<String, dynamic>;
    final String userId = postData['userId'] ?? 'Unknown User';
    final String description = postData['description'] ?? '';
    final List<Map<String, dynamic>> mediaFiles = List<Map<String, dynamic>>.from(postData['mediaFiles'] ?? []);
    final DateTime? createdAt = (postData['createdAt'] as Timestamp?)?.toDate();
    final String postId = post.id; 
    return PostWidget(
      userId: userId,
      description: description,
      mediaFiles: mediaFiles,
      createdAt: createdAt,
      postId: postId,
    );
  },
);
        }
            )
          )
        ],
      ),
    );
  }
  
  Widget buildBio(){
    return FutureBuilder<String?>( 

        future: getBio(), // Replace with your actual function
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error fetching bio: ${snapshot.error}');
          } else if (snapshot.data == null) {
            return Text('No bio found.');
          } else {
            return Text(
              snapshot.data!,
              style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.w500,
                      ),
            );
          }
        },
    );
  }
  
Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap a button
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Logout'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Are you sure you want to log out?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Logout'),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LandingPage()),
                (route) => false,
              );
            },
          ),
        ],
      );
    },
  );
}
}