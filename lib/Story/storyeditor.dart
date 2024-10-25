import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // For picking files
import 'package:provider/provider.dart';
import 'package:smm/MobileAuth/snackbar.dart';
import 'package:smm/Story/storyprovider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';// Import your provider
import 'package:video_player/video_player.dart'; // Ensure this file exists
import 'package:story_maker/story_maker.dart'; // Your custom StoryMaker widget

class MediaPickerScreen extends StatefulWidget {
  const MediaPickerScreen({super.key});

  @override
  _MediaPickerScreenState createState() => _MediaPickerScreenState();
}

class _MediaPickerScreenState extends State<MediaPickerScreen> {
  PageController _pageController = PageController();
   TextEditingController _captionController=TextEditingController();
  int _currentIndex = 0;
  File? overallMusic;
  bool _isUploading = false;

  // Function to pick multiple media files (images and videos)
  Future<void> _pickMedia(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.media, // Allows both images and videos
    );

    if (result != null) {
      final mediaManager = Provider.of<MediaManagerProvider>(context, listen: false);

      for (var filePath in result.paths) {
        if (filePath != null) {
          File file = File(filePath);
          String fileType = filePath.endsWith('.mp4') ? 'video' : 'image';
          mediaManager.addMediaFile(file, fileType);
        }
      }
    }
  }

  // Function to handle editing an image
  Future<void> _editMedia(BuildContext context, int index) async {
    final mediaManager = Provider.of<MediaManagerProvider>(context, listen: false);
    File originalFile = mediaManager.mediaFiles[index];

    File? editedFile = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StoryMaker(filePath: originalFile.path),
      ),
    );

    if (editedFile != null) {
      mediaManager.replaceMediaFile(index, editedFile);
    }
  }



  // Function to pick audio file for the entire story
  Future<void> _pickWholeAudioFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
     

      if (result.files.isNotEmpty) {
        overallMusic= File(result.files.single.path!);
        

      }
    }
  }
bool isVideo(File file) {
  return file.path.endsWith('.mp4') || file.path.endsWith('.mov') || file.path.endsWith('.avi');
}
  @override
  Widget build(BuildContext context) {
    final mediaManager = Provider.of<MediaManagerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Stories'),
      ),
      body: Center(
        child: mediaManager.mediaFiles.isEmpty
            ? Column( 
              mainAxisAlignment: MainAxisAlignment.center,
              children: [ 
                IconButton(
                onPressed: () => _pickMedia(context),
                icon: const Icon(Icons.upload),
              ),
               const SizedBox(height: 10),
          const Text("Pick Files & Play with them")
              ],
            )
            : Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    itemCount: mediaManager.mediaFiles.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      File file = mediaManager.mediaFiles[index];
                      String fileType = mediaManager.mediaTypes[index];

                      return Stack(
                        children: [
                         
                         
                          Positioned(
                            top: 0,
                            right: 20,
                            child:fileType == 'image'? GestureDetector(onTap: (){
                              _editMedia(context, index);
                            }, child: const Icon(Icons.edit,color: Colors.blue)):Container()),
                           Positioned(
                            top: 0,
                            left: 15,
                            child: GestureDetector(
                              onTap: () {
                                mediaManager.clearMedia();
                              },
                              child: const Icon(Icons.close_outlined, color: Colors.blue),
                            ),
                          ),
                          Positioned(
                            top: 25,
                            child: fileType == 'video'
                                ? SizedBox(
                                  height: MediaQuery.of(context).size.height-220,
                                  width:  MediaQuery.of(context).size.width,
                                  child: VideoPlayerScreen(videoUrl: file.path),
                                )
                                : SizedBox(
                                  height: MediaQuery.of(context).size.height-220,
                                  width:  MediaQuery.of(context).size.width,
                                  child: Image.file(file, fit: BoxFit.cover),
                                ),
                          ),
                         
                        ],
                      );
                    },
                  ),
                  if (_currentIndex == mediaManager.mediaFiles.length - 1)
                    Positioned(
                      bottom: 15,
                      left: 16,
                      child: Container(
                        height: 40,
                        width: 200,
                        alignment: Alignment.center,
                        decoration:const BoxDecoration( 
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Colors.amber
                        ),
                        child:GestureDetector(
                        onTap: () => _pickWholeAudioFile(context),
                        child: const Text('Add Audio for Entire Story'),
                      ),
                      )
                    ),
                    if (_currentIndex == mediaManager.mediaFiles.length - 1)
                    Positioned(
                      left: 20,
                      bottom: 60,
                      child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 15),
                                width: MediaQuery.of(context).size.width-70,
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25), // Rounded corners for aesthetic appeal.
                                    color: const Color.fromRGBO(31, 44, 52, 1)), // Background color set to dark green.
                                child: TextFormField(
                                   // Assigning focus node if provided.
                                  controller: _captionController, // Using the provided TextEditingController for text editing.
                                  style: const TextStyle(fontSize: 18,color: Colors.white), // Text style customization.
                                  cursorColor: const Color.fromRGBO(0, 167, 131, 1), // Cursor color set to teal for visual consistency.
                                  decoration: const InputDecoration(
                                      border: InputBorder.none, // No visual border for the input field.
                                      // Icon for a visual hint at the start of the input field.
                                      hintText: "Add a Description...", // Placeholder text.
                                      contentPadding: EdgeInsets.symmetric(vertical: 15,horizontal: 15), // Padding inside the input field.
                                      hintStyle: TextStyle(color: Colors.white)), // Hint text style.
                                ),
                              ),
                    ),
                ],
              ),
      ),
      floatingActionButton: _currentIndex < mediaManager.mediaFiles.length - 1
          ? SizedBox(
            height: 40,
            width: 50,
            child: FloatingActionButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                },
                child: const Icon(Icons.arrow_forward),
              ),
          )
          : mediaManager.mediaFiles.isNotEmpty ? _isUploading
                  ? const CircularProgressIndicator() :Container(
            height: 40,
            width: 100,
                        alignment: Alignment.center,
                        decoration:const BoxDecoration( 
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          
                        ),
            child: FloatingActionButton.extended(
                onPressed: () async{
                   setState(() {
      _isUploading = true; // Start showing progress
    });
                  try {
  // Reference to Firebase Storage, Firestore, and FirebaseAuth
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  // Get the current user's ID
  String userId = auth.currentUser!.uid;

  List<String> fileDownloadURLs = [];
  List<String?> musicFileDownloadURLs = [];  // List to hold music file download URLs
  List<String> mediaType = [];
  var uuid = const Uuid();  // UUID generator for unique file names

  // Upload selected files
  for (File file in mediaManager.mediaFiles) {
    // Generate a unique file name using UUID
    String uniqueFileName = '${uuid.v4()}_${file.path.split('/').last}';
    Reference ref = storage.ref().child('uploads/$userId/$uniqueFileName');

    // Upload the file
    await ref.putFile(file);

    // Get the download URL
    String downloadURL = await ref.getDownloadURL();
    if (isVideo(file)) {
      mediaType.add("video");
    } else {
      mediaType.add("image");
    }
    fileDownloadURLs.add(downloadURL);
    print('File uploaded: $downloadURL');
  }

  String musicDownloadURL = '';
  // Check if there's an overall music file to upload
  if (overallMusic != null) {
    // Generate a unique file name for the overall music file
    String musicFileName = uuid.v4() + '_' + overallMusic!.path.split('/').last;
    Reference musicRef = storage.ref().child('uploads/$userId/overAllmusic/$musicFileName');

    // Upload the overall music file
    await musicRef.putFile(overallMusic!);

    // Get the download URL
    musicDownloadURL = await musicRef.getDownloadURL();
    print('Overall music file uploaded: $musicDownloadURL');
  } else {
    musicFileDownloadURLs.add(null);  // Add null if there's no music file for the story
  }

  // Create a new document reference for Firestore
  DocumentReference docRef = firestore.collection('uploads').doc();

  // Store the download URLs, caption, and user ID in Firestore
  await firestore.collection('uploads').add({
    'storyId': docRef.id,
    'userId': userId,  // Storing the user ID
    'files': fileDownloadURLs,  // List of file download URLs
    'overAllMusic': musicDownloadURL,
    'mediaType': mediaType,
    'caption': _captionController.text.trim(),
    'uploadedAt': FieldValue.serverTimestamp(),
  });

  // Clear the selected files list after upload
  mediaManager.clearMedia();
  print('Selected files cleared.');
  showSnackBar(context, "Stories uploaded successfully");
  setState(() {
      overallMusic = null; // Reset overall music
      _captionController.clear();
      _pageController.jumpToPage(0);
       _currentIndex = 0;
        _isUploading = false;
  });
} catch (e) {
  print('Failed to upload files: $e');
  showSnackBar(context, "Failed to upload files: $e");
}
                  
                },
                label: const Text('Done'),
                icon: const Icon(Icons.check),
              ),
          ):null
    );
  }
}

// Example Video Player Widget

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  VideoPlayerScreen({required this.videoUrl});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  FlickManager? flickManager;

  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl)),
    );
  }

  @override
  void dispose() {
    flickManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: 9/16,
          child: FlickVideoPlayer(
            flickManager: flickManager!,
          ),
        ),
      ),
    );
  }
}

