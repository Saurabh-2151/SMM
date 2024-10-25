import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  bool _isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();
  final List<Map<String, dynamic>> _mediaFiles = [];
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
  
  }

  Future<void> savePost({
    required String description,
    required List<Map<String, String>> mediaFiles,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user signed in');
        return;
      }

      final docRef = FirebaseFirestore.instance.collection('posts').doc();
      if (mediaFiles.isNotEmpty) {
        await docRef.set({
          'userId': user.uid,
          'description': description,
          'mediaFiles': mediaFiles,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        print("Post Is Empty");
      }
    } catch (e) {
      print('Error saving post: $e');
    }
    print("Success");
  }

 Future<String> storeFileToStorage(String ref, File file) async {
  try {
    // Use current time to ensure a unique file name
    String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    
    UploadTask uploadTask = FirebaseStorage.instance
        .ref()
        .child('$ref/$uniqueFileName')
        .putFile(file);
        
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    print('Error uploading file: $e');
    return '';
  }
}


  Future<void> uploadAndSavePost() async {
    setState(() {
      _isLoading = true;
    });

    final mediaFileUrls = <Map<String, String>>[];

    for (var mediaFile in _mediaFiles) {
      final file = File(mediaFile['mediaFile']!);
      final fileUrl = await storeFileToStorage("media/${mediaFile['id']!}", file);

      mediaFileUrls.add({
        'id': mediaFile['id']!,
        'mediaFile': fileUrl,
        'mediaType': mediaFile['mediaType']!,
      });
    }

    await savePost(
      description: _descriptionController.text,
      mediaFiles: mediaFileUrls,
    );

    setState(() {
      _isLoading = false;
      _mediaFiles.clear();
      _descriptionController.clear();
    });
  }

  Future<void> pickVideo() async {
    final pickedFile = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: Duration(seconds: 60),
    );

    if (pickedFile != null) {
      final videoFile = File(pickedFile.path);
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final mediaJson = {
        'id': id,
        'mediaFile': videoFile.path,
        'mediaType': 'video',
      };

      setState(() {
        _mediaFiles.add(mediaJson);
      });
    }
  }

  Future<void> pickImage() async {
    final pickedFiles = await _picker.pickMultiImage();

    final mediaJsonList = pickedFiles.map((pickedFile) {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      return {
        'id': id,
        'mediaFile': File(pickedFile.path).path,
        'mediaType': 'image',
      };
    }).toList();

    setState(() {
      _mediaFiles.addAll(mediaJsonList);
    });
  }

  Future<void> takePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final mediaJson = {
        'id': id,
        'mediaFile': imageFile.path,
        'mediaType': 'image',
      };

      setState(() {
        _mediaFiles.add(mediaJson);
      });
    }
  }

  void showMediaBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Pick Image'),
              onTap: pickImage,
            ),
            ListTile(
              leading: Icon(Icons.videocam),
              title: Text('Pick Video'),
              onTap: pickVideo,
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take Picture'),
              onTap: takePicture,
            ),
          ],
        );
      },
    );
  }
  @override
  void dispose() {
    _descriptionController.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }
  void removeMedia(int index) {
    setState(() {
      _mediaFiles.removeAt(index);
    });
  }
  Future<void> playVideo(String filePath) async {
    _videoPlayerController = VideoPlayerController.file(File(filePath))
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController!.play();
      });
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('For Memories'),
        centerTitle: true,
      ),
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 69, 56),
        ),
        onPressed: uploadAndSavePost,
        child: Text("Post"),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Write Something"),
                SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    filled: true,
                    hintText: 'Description',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: takePicture,
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(Icons.add_a_photo),
                      ),
                    ),
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(Icons.photo),
                      ),
                    ),
                    GestureDetector(
                      onTap: pickVideo,
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(Icons.video_collection),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  Center(child: CircularProgressIndicator()),
                
                SizedBox(height: 20),
                _mediaFiles.isNotEmpty?
                 Container(
                    height: screenHeight * 0.6,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _mediaFiles.length,
                      itemBuilder: (context, index) {
                        final mediaFile = _mediaFiles[index];
                        final isVideo = mediaFile['mediaType'] == 'video';
                        return InkWell(
                          onTap: () {
                            if (isVideo) {
                              VideoPlayerScreen(videoPath:mediaFile['mediaFile']!);
                            }
                          },
                          onLongPress: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      leading: Icon(Icons.delete),
                                      title: Text('Delete'),
                                      onTap: () {
                                        removeMedia(index);
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.cancel),
                                      title: Text('Cancel'),
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            width: screenWidth,
                            height: double.infinity,
                            margin: EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                isVideo
                                  
                                    ? VideoPlayerScreen(videoPath:mediaFile['mediaFile']!)
                                    
                                  : Image.file(
                                      File(mediaFile['mediaFile']!),
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                               
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                  )
            
                
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({
    required this.videoPath,
    super.key, 
  });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late FlickManager flickManager;

  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.file(File(widget.videoPath)),
    );
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Center(
        child: FlickVideoPlayer(flickManager: flickManager),
      ),
    );
  }
}