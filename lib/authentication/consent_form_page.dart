import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scroll_screenshot/scroll_screenshot.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:firebase_storage/firebase_storage.dart';


class ConsentFormPage extends StatefulWidget {

  const ConsentFormPage({super.key});

  @override
  State<ConsentFormPage> createState() => _ConsentFormPageState();
}

class _ConsentFormPageState extends State<ConsentFormPage> {

  final formKey = GlobalKey<FormState>();
  final screenshotKey = GlobalKey();

  Uint8List imageDecode = Uint8List(0);

  bool readForm = false;
  bool askQuestions = false; 
  bool voluntary = false;
  bool withdrawConsent = false;
  bool consent = false;
  TextEditingController name = TextEditingController();
  TextEditingController date = TextEditingController();

  //generate pdf from consent form data
  void generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                'Dynamic Scaffolding Gratitude Application Study',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold
                ),
                textAlign: pw.TextAlign.center
              ),
              pw.Text('CONSENT FORM STUFF',
              ),
              pw.Text('Please remember that participation in this study is voluntary.',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold
                ),
              ),

              //radio buttons
              pw.Text('Label'),
              pw.Row(
              ),

              pw.Text('Name: ${name.text}')
            ]
          );
        }
      )
    );
    Uint8List pdfBytes = Uint8List(0);

    //save pdf to cloud storage
    pdf.save().then((Uint8List result) async {
      pdfBytes = result;

      try {
        Reference refRoot = FirebaseStorage.instance.ref();

        Reference refFileDir = refRoot.child('consent_forms'); //get reference to storage root
        Reference refFile = refFileDir.child('filename'); //create a reference for the file to be stored

        final upload = refFile.putData(pdfBytes, SettableMetadata(contentType: 'application/pdf'));
        await upload;
      } catch(e) {
        print('upload failed: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text('Study Consent Form',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold
          ),
        )
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: RepaintBoundary(
            key: screenshotKey,
            child: ListView(
              children: [
                Text(
                  'Dynamic Scaffolding Gratitude Application Study',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
                Text('CONSENT FORM STUFF'),
                Text('Please remember that participation in this study is voluntary.',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold
                  ),
                ),
            
                //read form
                YesNoRadio(
                  label: 'I have read the consent form',
                  radioSelected: readForm, 
                  onChanged: (bool newValue) {
                    setState(() {
                      readForm = newValue;
                    });
                  }
                ),
            
                //questions
                YesNoRadio(
                  label: 'I understand that if I have questions, I am free to contact the researcher at the email address specified above',
                  radioSelected: askQuestions, 
                  onChanged: (bool newValue) {
                    setState(() {
                      askQuestions = newValue;
                    });
                  }
                ),
            
                //voluntary
                YesNoRadio(
                  label: 'I understand that my participation in this study is voluntary',
                  radioSelected: voluntary, 
                  onChanged: (bool newValue) {
                    setState(() {
                      voluntary = newValue;
                    });
                  }
                ),
            
                //withdraw consent
                YesNoRadio(
                  label: 'I understand that I can withdraw my consent at any time',
                  radioSelected: withdrawConsent, 
                  onChanged: (bool newValue) {
                    setState(() {
                      withdrawConsent = newValue;
                    });
                  }
                ),
            
                //overall consent
                YesNoRadio(
                  label: 'I agree to take part in the study',
                  radioSelected: consent, 
                  onChanged: (bool newValue) {
                    setState(() {
                      consent = newValue;
                    });
                  }
                ),
            
                //name
                Row(
                  children: [
                    Text('Name'),
                    SizedBox(width: 10,),
                    Expanded(
                      child: TextFormField(
                        controller: name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please fill out this field';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
            
                //date
                Row(
                  children: [
                    Text('Date'),
                    SizedBox(width: 10,),
                    Expanded(
                      child: TextFormField(
                        controller: date,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please fill out this field';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
            
            
                //finish consent form
                ElevatedButton(
                  child: Text('Submit Form and Sign Up'),
                  onPressed: () async {
                    print(formKey.currentState);
                    if(!readForm || !askQuestions || !voluntary || !withdrawConsent || !consent) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please accept all terms to use the app')),
                      );
                    } else if (formKey.currentState!.validate()){
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Success')),
                      );
            
                      //take screenshot
                      // String? screenshot = await ScrollScreenshot.captureAndSaveScreenshot(screenshotKey);
                      // if (screenshot != null) {
                      //   print('SCREENSHOT: $screenshot');
                      //   // final decode = base64Decode(screenshot);
                      //   // final image = Image.memory(decode);
                      //   setState(() {
                      //     imageDecode = base64Decode(screenshot);
                      //   });
                      //   print('THEIR EMAIL: ${FirebaseAuth.instance.currentUser!.email}');
                      // } 

                      generatePdf();
                      print('AFTER GENERATING PDF');
                      
                    }
                  },
                ),

                imageDecode.isNotEmpty ? Image.memory(imageDecode) : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class LabeledRadio extends StatelessWidget {
  const LabeledRadio({
    super.key,
    required this.label,
    required this.groupValue,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool groupValue;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (value != groupValue) {
          onChanged(value);
        }
      },
      child: Row(
        children: <Widget>[
          Radio<bool>(
            groupValue: groupValue,
            value: value,
            onChanged: (bool? newValue) {
              onChanged(newValue!);
            },
          ),
          Text(label),
        ],
      ),
    );
  }
}

class YesNoRadio extends StatelessWidget {
  const YesNoRadio({
    super.key,
    required this.label,
    required this.radioSelected,
    required this.onChanged
  });

  final String label;
  final bool radioSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30,),
        Text(label),
        Row(
          children: [
            Expanded(
              child: LabeledRadio(
                label: 'Yes', 
                groupValue: radioSelected, 
                value: true, 
                onChanged: (bool? newValue) {
                  onChanged(newValue!);
                }
              ),
            ),
            Expanded(
              child: LabeledRadio(
                label: 'No', 
                groupValue: radioSelected, 
                value: false, 
                onChanged: (bool? newValue) {
                  onChanged(newValue!);
                }
              ),
            ),
          ],
        ),
      ],
    );
  }
}