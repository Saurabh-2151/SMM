import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:smm/MobileAuth/authprovider.dart' as auth ;
import 'package:smm/MobileAuth/usermodel.dart';

class ProfilePic extends StatefulWidget {
  const ProfilePic({
    Key? key,
  }) : super(key: key);

  @override
  State createState()=>_ProfilePic();
}

class _ProfilePic extends State{
   UserModel? u;
  bool isUserLoaded = false;

  void getData() async {
    final ap = Provider.of<auth.AuthProvider>(context,
        listen: false); // Use the alias

    await ap.getDataFromSP();
    setState(() {
      u = ap.userModel;
      isUserLoaded = true;
    });
  }
   Future<String> getUserProfilePic() async {
    // Simulate a network call or fetch from a database
    final ap = Provider.of<auth.AuthProvider>(context,
        listen: false); 
    await Future.delayed(const Duration(seconds: 1));
    return ap.userModel.profilePic; // Replace with actual URL fetching logic
  }
  @override
  void initState() {
    super.initState();
    getData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    
    return SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
           FutureBuilder<String>(
                      future: getUserProfilePic(), // Replace with your async function to fetch the profile picture URL
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircleAvatar(
                            backgroundColor: Color.fromARGB(255, 124, 121, 121),
                            radius: 60,
                            child: CircularProgressIndicator(),
                          );
                           // Show a loading indicator while waiting
                        } else if (snapshot.hasError) {
                          return const Icon(Icons.error); // Show an error icon if there was an error
                        } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                          return const CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 60,
                            child: Icon(Icons.person, size: 60), // Default avatar if no data or empty URL
                          );
                        } else {
                          return CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(snapshot.data!),
                            radius: 60,
                          );
                        }
                      },
                    ),
        ],
      ),
    );
  }
}
