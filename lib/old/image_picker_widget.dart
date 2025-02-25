import 'package:flutter/material.dart';


class ImagePickerWidget extends StatefulWidget {
  final type;
  ImagePickerWidget({super.key, required this.type});

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState(this.type);
}


class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  var _image;
  var imagePicker;
  var type;

  _ImagePickerWidgetState(this.type);

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}