import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smm/Story/storyeditor.dart';

import 'dart:io';

import 'package:smm/Story/storyprovider.dart';

class MediaDisplayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Accessing the MediaManager instance via Provider
    final mediaManager = Provider.of<MediaManagerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Selected Media'),
      ),
      body: PageView.builder(
                scrollDirection: Axis.horizontal, // Horizontal swipe
                itemCount: mediaManager.mediaFiles.length,
               
                itemBuilder: (context, index) {
                  File file = mediaManager.mediaFiles[index];
                  String fileType = mediaManager.mediaTypes[index];

                  // Display either an image or a video widget based on the file type
                  return fileType == 'video'
                      ?VideoPlayerScreen(videoUrl: file.path)
                      : Image.file(file, fit: BoxFit.cover);
                },
              ),
    );
  }
}
