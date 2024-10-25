import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smm/Profile/userprofile.dart';
import 'package:video_player/video_player.dart';

// Fetch data from Firestore
Future<List<Map<String, dynamic>>> fetchStories() async {
  // Get the current user ID
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId == null) {
    throw Exception('User not authenticated');
  }

  // Query Firestore to get documents where the userId matches the current user's ID
  final QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('uploads')
      .where('userId', isEqualTo: userId) // Filter by current user's ID
      .orderBy('uploadedAt', descending: true)
      .get();

  return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
}

class StoriesPageView extends StatefulWidget {
  const StoriesPageView({super.key});

  @override
  State createState() => _StoriesPageViewState();
}

class _StoriesPageViewState extends State<StoriesPageView> {
  late Future<List<Map<String, dynamic>>> _storiesFuture;
  late PageController _pageController;
  late AudioPlayer _audioPlayer;
  late List<Map<String, dynamic>> _stories;
  String? _currentMusicUrl;

  @override
  void initState() {
    super.initState();
    _storiesFuture = fetchStories();
    _audioPlayer = AudioPlayer();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _refreshStories() async {
    setState(() {
      _storiesFuture = fetchStories();
    });
  }

  Future<void> _playOverallMusic(String? musicUrl) async {
    if (musicUrl == null || musicUrl == _currentMusicUrl) {
      return; // No new music to play
    }

    try {
      await _audioPlayer.stop(); // Stop previous music
      await _audioPlayer.setUrl(musicUrl); // Set new music URL
      await _audioPlayer.play(); // Play the music
      _currentMusicUrl = musicUrl; // Update current music URL
    } catch (e) {
      print('Error playing overall music: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _storiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No stories found.'));
        }

        _stories = snapshot.data!;
         _playOverallMusic(_stories[0]['overAllMusic']);
        return RefreshIndicator(
          onRefresh: _refreshStories,
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _stories.length,
            onPageChanged: (index) {
              _playOverallMusic(_stories[index]['overAllMusic']);
            },
            itemBuilder: (context, index) {
              final story = _stories[index];
              return StoryWidget(
                files: story['files'] as List<dynamic>,
              
                caption: story['caption'] as String,
                mediaType: story['mediaType'] as List<dynamic>,
                
                userId: story['userId'] as String,
              );
            },
          ),
        );
      },
    );
  }
}

class StoryWidget extends StatefulWidget {
  final List<dynamic> files;
  final String caption;
  final List<dynamic> mediaType;
  final String userId; // Add userId here

  StoryWidget({
    required this.files,
    required this.caption,
    required this.mediaType,
    required this.userId, // Add userId here
  });

  @override
  _StoryWidgetState createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget> {
  late PageController _pageController;
  int _currentPageIndex = 0;
  late Future<Map<String, String>> _userInfoFuture;
  double _progress = 0.0; // Progress for the current story
  Timer? _timer; // Timer to update the progress indicator

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _userInfoFuture = _getUserInfo(widget.userId); // Fetch user info

    _pageController.addListener(() {
      int newPageIndex = _pageController.page!.round();
      if (newPageIndex != _currentPageIndex) {
        setState(() {
          _currentPageIndex = newPageIndex;
          _resetProgress();
        });
        _startProgress(); // Start progress based on the new page
      }
    });

    _startProgress();
  }

  void _startProgress() {
    _timer?.cancel(); // Cancel any previous timer
    final mediaType = widget.mediaType[_currentPageIndex];

    if (mediaType == 'video') {
      // Handle video duration
      _setVideoProgress(widget.files[_currentPageIndex] as String);
    } else {
      // Handle image duration (6 seconds)
      const duration = Duration(seconds: 6);
      _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
        setState(() {
          _progress += 50 / duration.inMilliseconds;
          if (_progress >= 1.0) {
            _nextStory();
          }
        });
      });
    }
  }

  void _setVideoProgress(String videoUrl) async {
    final videoController = VideoPlayerController.network(videoUrl);
    await videoController.initialize();

    final videoDuration = videoController.value.duration;
    _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        _progress += 50 / videoDuration.inMilliseconds;
        if (_progress >= 1.0) {
          _nextStory();
        }
      });
    });
  }

  void _resetProgress() {
    _progress = 0.0;
  }

  void _nextStory() {
    if (_currentPageIndex < widget.files.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      _resetProgress();
    } else {
      _timer?.cancel(); // Stop timer when the last story is viewed
    }
  }

  void _previousStory() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      _resetProgress();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

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
    return FutureBuilder<Map<String, String>>(
      future: _userInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final userInfo = snapshot.data!;
        final username = userInfo['username']!;
        final profilePic = userInfo['profilePic']!;

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              GestureDetector(
                onTapDown: (details) {
                  double dx = details.globalPosition.dx;
                  double screenWidth = MediaQuery.of(context).size.width;
                  if (dx > screenWidth / 2) {
                    // Tap on the right side for the next story
                    _nextStory();
                  } else {
                    // Tap on the left side for the previous story
                    _previousStory();
                  }
                  _resetProgress(); // Reset progress when story changes
                },
                child: PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.files.length,
                  itemBuilder: (context, index) {
                    final fileUrl = widget.files[index] as String;
                    final type = widget.mediaType[index] as String;
                    return AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      child: type == 'video' || fileUrl.endsWith('.mp4')
                          ? VideoPlayerScreen(videoUrl: fileUrl)
                          : SizedBox(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              child: Image.network(
                                fileUrl,
                                fit: BoxFit.contain,
                                key: ValueKey(fileUrl),
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 40,
                left: 16,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(profilePic),
                    ),
                    SizedBox(width: 8),
                     GestureDetector(
                    onTap: () {
                      if (_timer != null) {
      _timer!.cancel(); // Cancel any timers
    }
                      

                      Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen(userid: widget.userId)));
                    },
                    child: Text(username, style: TextStyle(color: Colors.white)),
                  ),
                  ],
                ),
              ),
             
             Positioned(
                top: -10,
                left: 10,
                right: 10,
                child: Row(
                  children: List.generate(widget.files.length, (index) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.0),
                        child: LinearProgressIndicator(
                          value: index == _currentPageIndex ? _progress : (index < _currentPageIndex ? 1.0 : 0.0),
                          backgroundColor: Colors.white30,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    );
                  }),
                ),
              ), 
              Positioned(
                bottom: 0,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.caption,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    IconButton(
                      onPressed: () {
                        // Share the current story using Share package
                        Share.share(widget.files[_currentPageIndex]);
                      },
                      icon: Icon(Icons.share, color: Colors.white),
                    ),
                    
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  VideoPlayerScreen({required this.videoUrl});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late FlickManager _flickManager;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl);
    _flickManager = FlickManager(
      videoPlayerController: _controller,
    );
    _controller.initialize().then((_) {
      setState(() {}); // Refresh after initialization
      _controller.play(); // Start playing video automatically
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlickVideoPlayer(
  flickManager: _flickManager,
  flickVideoWithControls: FlickVideoWithControls(
    controls: FlickAutoHideChild(
      child: Container(), // Empty container to hide all controls
    ),
  ),
);
  }
}
