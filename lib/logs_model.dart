import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:gratitude_app/widgets.dart';

class LogsModel extends ChangeNotifier {
  List<DynamicFormWidget> _textLogs = [DynamicFormWidget(key: Key('1'), logController: TextEditingController())];
  UnmodifiableListView<DynamicFormWidget> get textLogs => UnmodifiableListView(_textLogs);
  List<String> _imageUrls = [];
  UnmodifiableListView<String> get imageUrls => UnmodifiableListView(_imageUrls);
  int _numImages = 0;
  int get numImages => _numImages;


  void addTextLog(DynamicFormWidget log) {
    _textLogs.add(log);
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
    _imageUrls.removeAt(index);
    _numImages--;
    notifyListeners();
  }

  void removeAllImageUrls() {
    _imageUrls = [];
    _numImages = 0;
    notifyListeners();
  }
}


