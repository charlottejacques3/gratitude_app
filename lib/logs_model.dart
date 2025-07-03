import 'dart:collection';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gratitude_app/utilities/widgets.dart';

class LogsModel extends ChangeNotifier {
  List<DynamicFormWidget> _textLogs = [DynamicFormWidget(key: Key('1'), logController: TextEditingController())];
  UnmodifiableListView<DynamicFormWidget> get textLogs => UnmodifiableListView(_textLogs);
  List<String> _imageUrls = [];
  UnmodifiableListView<String> get imageUrls => UnmodifiableListView(_imageUrls);
  int _numImages = 0;
  int get numImages => _numImages;
  String _inspoUsed = '';
  String get inspoUsed => _inspoUsed;
  String _guidingStage = '';
  String get guidingStage => _guidingStage;
  int _sessionMood = 0;
  int get sessionMood => _sessionMood;


  void addTextLog(DynamicFormWidget log, bool preloaded) {
    if (preloaded && _textLogs.length == 1 && _textLogs[0].logController.text.isEmpty) {
      _textLogs = [log];
    } else {
      _textLogs.add(log);
    }
    notifyListeners();
  }

  void removeTextLog(Key? key) {
    //if was the last one, just clear it
    if (_textLogs.length == 1) {
      _textLogs[0].logController.clear();
      notifyListeners();
    }
    //otherwise, find right one to delete
    else {
      for (var formWidget in _textLogs) {
        if (formWidget.key == key) {
          _textLogs.remove(formWidget);
          notifyListeners();
          return;
        }
      }
    }
  }

  void resetTextLogs() {
    _textLogs =[DynamicFormWidget(key: Key('1'), logController: TextEditingController())];
    notifyListeners();
  }

  void addImageUrl(String url) {
    _imageUrls.add(url);
    notifyListeners();
  }

  void incNumImages() {
    _numImages++;
    notifyListeners();
  }

  void removeImageUrl(int index) {
    String url = _imageUrls.elementAt(index);
    Reference imgRef = FirebaseStorage.instance.refFromURL(url);
    imgRef.delete();
    _imageUrls.removeAt(index);
    _numImages--;
    notifyListeners();
  }

  void removeAllImageUrls() {
    _imageUrls = [];
    _numImages = 0;
    notifyListeners();
  }

  void setInspoUsed(String inspo) {
    _inspoUsed = inspo;
    notifyListeners();
  }

  void setGuidingStage(String stage) {
    _guidingStage = stage;
    notifyListeners();
  }

  void setSessionMood(int moodIndex) {
    _sessionMood = moodIndex;
    notifyListeners();
  }
}


