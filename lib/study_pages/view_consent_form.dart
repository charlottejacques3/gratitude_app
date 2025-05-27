import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class ViewConsentForm extends StatelessWidget {
  const ViewConsentForm({super.key, required this.uri});

  final Uri uri; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consent Form')
      ),
      body: PdfViewer.uri(uri)
    );
  }
}