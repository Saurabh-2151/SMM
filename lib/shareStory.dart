// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:smm/Reel/reel.dart';

// class StoryScreen extends StatelessWidget {
//   final String storyId;

//   const StoryScreen({required this.storyId, Key? key}) : super(key: key);

//   Future<Map<String, dynamic>?> fetchStoryById() async {
//     final DocumentSnapshot snapshot = await FirebaseFirestore.instance
//         .collection('uploads')
//         .doc(storyId)
//         .get();

//     return snapshot.data() as Map<String, dynamic>?;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Story'),
//       ),
//       body: FutureBuilder<Map<String, dynamic>?>(
//         future: fetchStoryById(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data == null) {
//             return const Center(child: Text('Story not found.'));
//           }

//           final story = snapshot.data!;
//           return StoryWidget(
//             files: story['files'] as List<dynamic>,
//             musicFiles: story['musicFiles'] as List<dynamic>,
//             overallMusic: story['overAllMusic'] as String,
//             caption: story['caption'] as String,
//             mediaType: story['mediaType'] as List<dynamic>,
//             audioPlayer: AudioPlayer(),
//           );
//         },
//       ),
//     );
//   }
// }
