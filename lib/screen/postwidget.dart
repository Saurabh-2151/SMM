import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smm/Profile/userprofile.dart';
// Assuming this contains the VideoPlayerScreen class
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class PostWidget extends StatefulWidget {
  final String userId;
  final String description;
  final List<Map<String, dynamic>> mediaFiles;
  final DateTime? createdAt;
  String? postId;

  PostWidget({
    Key? key,
    required this.userId,
    required this.description,
    required this.mediaFiles,
    required this.createdAt,
    required this.postId,
  }) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  // Function to get user information from Firestore
  Future<Map<String, String>> _getUserInfo(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists && userDoc.data() != null) {
      return {
        'username': userDoc.data()!['name'] ?? 'User',
        'profilePic': userDoc.data()!['profilePic'] ?? 'assets/images/user_image.png',
      };
    } else {
      return {
        'username': 'Unknown User',
        'profilePic': 'assets/images/user_image.png',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentuser = FirebaseAuth.instance.currentUser!.uid;
    return FutureBuilder<Map<String, String>>(
      future: _getUserInfo(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(); // Can show a loading indicator if needed
        }

        final username = snapshot.data?['username'] ?? 'Unknown User';
        final profilePic = snapshot.data?['profilePic'] ?? 'assets/images/user_image.png';

        return Card(
          color: Colors.white,
          elevation: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User information row
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(profilePic),
                      radius: 20,
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfileScreen(userid: widget.userId),
                          ),
                        );
                      },
                      child: Text(
                        username,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Spacer(),
                    if (widget.postId != null && widget.userId == currentuser )
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            _deletePost(context);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return {'Delete'}.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice.toLowerCase(),
                              child: Text(choice),
                            );
                          }).toList();
                        },
                      ),
                  ],
                ),
              ),
              SizedBox(height: 8),

              // Media files (images or video)
            // Inside PostWidget class

widget.mediaFiles.isNotEmpty
    ? Container(
        height: 400, // This can be adjusted based on your requirements
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.mediaFiles.length,
          itemBuilder: (context, index) {
            final media = widget.mediaFiles[index];
            final mediaFileUrl = media['mediaFile'];
            final isVideo = media['mediaType'] == 'video';

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                height: isVideo ? 800 : 300, // Set height based on whether it's a video or image
                width: MediaQuery.of(context).size.width,
                child: isVideo
                    ? AutoPlayVideoWidget(videoUrl: mediaFileUrl) // Video player widget
                    : CachedNetworkImage(
                        imageUrl: mediaFileUrl,
                        fit: BoxFit.fill,
                        width: MediaQuery.of(context).size.width,
                        height: 300, // Image height
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
              ),
            );
          },
        ),
      )
    : SizedBox.shrink(),

              SizedBox(height: 8),

              // Post description
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(widget.description),
              ),

              // Post date
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  widget.createdAt != null
                      ? 'Posted on ${DateFormat.yMMMd().format(widget.createdAt!)}'
                      : 'Just now',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to delete the post from Firestore
  void _deletePost(BuildContext context) {
    FirebaseFirestore.instance.collection('posts').doc(widget.postId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Post deleted successfully')),
    );
  }
}

// Widget to auto-play video when it comes into view

class AutoPlayVideoWidget extends StatefulWidget {
  final String videoUrl;

  AutoPlayVideoWidget({required this.videoUrl});

  @override
  _AutoPlayVideoWidgetState createState() => _AutoPlayVideoWidgetState();
}

class _AutoPlayVideoWidgetState extends State<AutoPlayVideoWidget> {
  late FlickManager _flickManager;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(widget.videoUrl),
    );
  }

  @override
  void dispose() {
    _flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.videoUrl),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5) {
          _flickManager.flickControlManager?.play();
        } else {
          _flickManager.flickControlManager?.pause();
        }
      },
      child: AspectRatio(
        aspectRatio: 9 / 16, // Change to the required aspect ratio
        child: FlickVideoPlayer(
          flickManager: _flickManager,
        ),
      ),
    );
  }
}