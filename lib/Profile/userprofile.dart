import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smm/Story/userStories.dart';
import 'package:smm/screen/postwidget.dart';

class UserProfileScreen extends StatefulWidget {
  final String userid;
  const UserProfileScreen({super.key, required this.userid});

  @override
  State createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<UserProfileScreen> {
  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    userModel = await getUserInfo(widget.userid);
    setState(() {});
  }

  Future<UserModel?> getUserInfo(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user info: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "  MEMORIES",
          style: GoogleFonts.poppins(fontSize: 21, fontWeight: FontWeight.w700),
        ),
        
      ),
      body: userModel == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    const SizedBox(width: 20),
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: userModel?.profilePic != null
                          ? NetworkImage(userModel!.profilePic!)
                          : const AssetImage("assets/images/user_image.png")
                              as ImageProvider,
                      radius: 50,
                    ),
                    const SizedBox(width: 30),
                    Text(
                      userModel?.name ?? "UserName",
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(width: 20),
                     userModel!.bio!.isNotEmpty ?Text(
                      userModel?.bio  ?? "Your bio",
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w500),
                    ):Text(
                     "Your bio",
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Userstories(userId:widget.userid)));
                  },
                  child: Container(
                    height: 50,
                    width: 200,
                    decoration: BoxDecoration(
                        color: const Color.fromRGBO(9, 128, 243, 1),
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
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .where('userId', isEqualTo: widget.userid)
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No posts yet.'));
                        }

                        final posts = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];

                            final Map<String, dynamic> postData =
                                post.data() as Map<String, dynamic>;
                            final String userId = postData['userId'] ?? 'Unknown User';
                            final String description = postData['description'] ?? '';
                            final List<Map<String, dynamic>> mediaFiles =
                                List<Map<String, dynamic>>.from(
                                    postData['mediaFiles'] ?? []);
                            final DateTime? createdAt =
                                (postData['createdAt'] as Timestamp?)?.toDate();
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
                      }),
                ),
              ],
            ),
    );
  }
}

class UserModel {
  final String? profilePic;
  final String? name;
  final String? bio;

  UserModel({this.profilePic, this.name, this.bio});

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      profilePic: data['profilePic'] as String?,
      name: data['name'] as String?,
      bio: data['bio'] as String?,
    );
  }
}
