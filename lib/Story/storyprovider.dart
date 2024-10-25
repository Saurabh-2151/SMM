import 'dart:io';
import 'package:flutter/material.dart';

class MediaManagerProvider with ChangeNotifier {
  List<File> _mediaFiles = [];
  List<String> _mediaTypes = [];


  List<File> get mediaFiles => _mediaFiles;
  List<String> get mediaTypes => _mediaTypes;


  void addMediaFile(File file, String type) {
    _mediaFiles.add(file);
    _mediaTypes.add(type);
   // Add a null placeholder for the new media file
    notifyListeners();
  }

  void clearMedia() {
    _mediaFiles.clear();
    _mediaTypes.clear();
   // Clear the audio files list
    notifyListeners();
  }

  void removeMediaFile(int index) {
    if (index >= 0 && index < _mediaFiles.length) {
      _mediaFiles.removeAt(index);
      _mediaTypes.removeAt(index);
    // Remove corresponding audio file
      notifyListeners();
    }
  }

  void replaceMediaFile(int index, File newFile) {
    if (index >= 0 && index < _mediaFiles.length) {
      _mediaFiles[index] = newFile;
      notifyListeners();
    }
  }

  void setWholeAudioFile(File? audioFile) {
    // Optionally set a whole audio file for all media files, if needed
    // This can be implemented based on your requirements
    notifyListeners();
  }
}
