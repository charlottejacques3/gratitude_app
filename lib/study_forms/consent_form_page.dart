import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gratitude_app/main.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:signature/signature.dart';
import 'package:flutter/services.dart' show rootBundle;


class ConsentFormPage extends StatefulWidget {

  const ConsentFormPage({super.key});

  @override
  State<ConsentFormPage> createState() => _ConsentFormPageState();
}


class _ConsentFormPageState extends State<ConsentFormPage> {

  final formKey = GlobalKey<FormState>();

  bool readForm = false;
  bool askQuestions = false; 
  bool voluntary = false;
  bool withdrawConsent = false;
  bool consent = false;
  TextEditingController name = TextEditingController();
  TextEditingController date = TextEditingController();
  SignatureController signatureController = SignatureController(); 
  Uint8List? signatureBytes;

  //markdown
  String data = "# Gratitude Buddy";



  //generate pdf from consent form data
  void generatePdf() async {
    final pdf = pw.Document();

    // final mainText = File('sample.pdf');
    // final pdf = pw.Document.load(PdfDocumentParserBase(mainText.readAsBytesSync()));
    
    // pdf.addPage()

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          // return [pw.Column(
          //   crossAxisAlignment: pw.CrossAxisAlignment.start,
          //   children: [
              return [pw.Text(
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

              //yes/no selections
              readForm && askQuestions && voluntary && withdrawConsent && consent ?
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Paragraph(text: 'I have read the consent form - Yes'),
                    pw.Paragraph(text: 'I understand that if I have questions, I am free to contact the researcher at the email address specified above - Yes'),
                    pw.Paragraph(text: 'I understand that my participation in this study is voluntary - Yes'),
                    pw.Paragraph(text: 'I understand that I can withdraw my consent at any time - Yes'),
                    pw.Paragraph(text: 'I agree to take part in the study - Yes'),
                  ]
                ) : pw.Container(),
              
              //participant info
              pw.Text('Name: ${name.text}'),
              pw.Text('Date: ${date.text}'),
              pw.Row(
                children: [
                  pw.Text('Signature: '),
                  pw.Image(pw.MemoryImage(signatureBytes!))
                ]
              )
            ];
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
        Reference refFile = refFileDir.child(FirebaseAuth.instance.currentUser!.uid); //create a reference for the file to be stored

        await refFile.putData(pdfBytes, SettableMetadata(contentType: 'application/pdf'));
        String url = await refFile.getDownloadURL();

        //store to database
        DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('users').child(FirebaseAuth.instance.currentUser!.uid);
        await dbRef.set({'consent_form': url});

      } catch(e) {
        print('upload failed: $e');
      }
    });
  }

  //load from markdown
  @override 
  void initState() {
    super.initState();
    setText();
  }

  void setText() async {
    // File formText = File('/consent_form.md');
    // String text = await formText.readAsString();
    // setState(() {
    //   data = text;
    // });
    String fileText = await rootBundle.loadString('assets/consent_form.md');
    setState(() {
      data = fileText;
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
            child: MarkdownWidget(data: data)
            // child: ListView(
            //   children: [
            //     Text(
            //       'Evaluating a Mobile Gratitude Application',
            //       style: Theme.of(context).textTheme.titleMedium!.copyWith(
            //         fontSize: 20,
            //         fontWeight: FontWeight.bold
            //       ),
            //       textAlign: TextAlign.center,
            //     ),
            //     Text('CONSENT FORM STUFF'),
            //     MarkdownWidget(
            //       data: data,
            //       physics: NeverScrollableScrollPhysics(),
            //     ),
            //     Text('Please remember that participation in this study is voluntary.',
            //       style: Theme.of(context).textTheme.titleMedium!.copyWith(
            //         fontWeight: FontWeight.bold
            //       ),
            //     ),
            
            //     //read form
            //     YesNoRadio(
            //       label: 'I have read the consent form',
            //       radioSelected: readForm, 
            //       onChanged: (bool newValue) {
            //         setState(() {
            //           readForm = newValue;
            //         });
            //       }
            //     ),
            
            //     //questions
            //     YesNoRadio(
            //       label: 'I understand that if I have questions, I am free to contact the researcher at the email address specified above',
            //       radioSelected: askQuestions, 
            //       onChanged: (bool newValue) {
            //         setState(() {
            //           askQuestions = newValue;
            //         });
            //       }
            //     ),
            
            //     //voluntary
            //     YesNoRadio(
            //       label: 'I understand that my participation in this study is voluntary',
            //       radioSelected: voluntary, 
            //       onChanged: (bool newValue) {
            //         setState(() {
            //           voluntary = newValue;
            //         });
            //       }
            //     ),
            
            //     //withdraw consent
            //     YesNoRadio(
            //       label: 'I understand that I can withdraw my consent at any time',
            //       radioSelected: withdrawConsent, 
            //       onChanged: (bool newValue) {
            //         setState(() {
            //           withdrawConsent = newValue;
            //         });
            //       }
            //     ),
            
            //     //overall consent
            //     YesNoRadio(
            //       label: 'I agree to take part in the study',
            //       radioSelected: consent, 
            //       onChanged: (bool newValue) {
            //         setState(() {
            //           consent = newValue;
            //         });
            //       }
            //     ),
            
            //     //name
            //     Row(
            //       children: [
            //         Text('Name'),
            //         SizedBox(width: 10,),
            //         Expanded(
            //           child: TextFormField(
            //             controller: name,
            //             validator: (value) {
            //               if (value == null || value.isEmpty) {
            //                 return 'Please fill out this field';
            //               }
            //               return null;
            //             },
            //           ),
            //         ),
            //       ],
            //     ),
            
            //     //date
            //     Row(
            //       children: [
            //         Text('Date'),
            //         SizedBox(width: 10,),
            //         Expanded(
            //           child: TextFormField(
            //             controller: date,
            //             validator: (value) {
            //               if (value == null || value.isEmpty) {
            //                 return 'Please fill out this field';
            //               }
            //               return null;
            //             },
            //           ),
            //         ),
            //       ],
            //     ),

            //     //show e-signature
            //     Padding(
            //       padding: const EdgeInsets.symmetric(vertical: 16),
            //       child: Row(
            //         mainAxisSize: MainAxisSize.max,
            //         children: [
            //           Text('Signature '),
            //           Expanded(
            //             child: signatureBytes != null ? 
            //               Image.memory(
            //                 signatureBytes!,
            //                 height: 50,
            //                 alignment: Alignment.centerLeft,
            //               ) 
            //             : Container(
            //                 height: 50,
            //                 decoration: const BoxDecoration(
            //                   border: Border(
            //                     bottom: BorderSide(color: Colors.black)
            //                   )
            //                 ),
            //               ),
            //           ),

            //           //e-signature popup
            //           IconButton(
            //             icon: Icon(Icons.edit),
            //             alignment: Alignment.centerRight,
            //             onPressed: () => showDialog(
            //               context: context, 
            //               builder: (BuildContext context) => Dialog(
            //                 child: Padding(
            //                   padding: const EdgeInsets.all(15.0),
            //                   child: Column(
            //                     mainAxisSize: MainAxisSize.min,
            //                     children: [
            //                       //signing box
            //                       Signature(
            //                         controller: signatureController,
            //                         width: 300,
            //                         height: 125,
            //                       ),
                              
            //                       //save and clear
            //                       Row(
            //                         children: [
            //                           Expanded(
            //                             child: Padding(
            //                               padding: const EdgeInsets.all(8.0),
            //                               child: ElevatedButton(
            //                                 onPressed: () => signatureController.clear(),
            //                                 child: Text('Clear')
            //                               ),
            //                             ),
            //                           ),
            //                           Expanded(
            //                             child: Padding(
            //                               padding: const EdgeInsets.all(8.0),
            //                               child: ElevatedButton(
            //                                 onPressed: () async {
            //                                   final bytes = await signatureController.toPngBytes();
            //                                   setState(() {
            //                                     signatureBytes = bytes;
            //                                   });
            //                                   Navigator.pop(context);
            //                                 }, 
            //                                 child: Text('Save')
            //                               ),
            //                             ),
            //                           )
            //                         ],
            //                       )
            //                     ],
            //                   ),
            //                 ),
            //               )
            //             ),
            //           )
            //         ],
            //       ),
            //     ),
            
            //     //finish consent form
            //     ElevatedButton(
            //       child: Text('Submit Form and Sign Up'),
            //       onPressed: () async {
            //         if(!readForm || !askQuestions || !voluntary || !withdrawConsent || !consent) {
            //           ScaffoldMessenger.of(context).showSnackBar(
            //             const SnackBar(content: Text('Please accept all terms of the consent form to use the app')),
            //           );
            //         } else if (signatureBytes == null) {
            //           ScaffoldMessenger.of(context).showSnackBar(
            //             const SnackBar(content: Text('Please add an e-signature to use the app')),
            //           );
            //         } else if (formKey.currentState!.validate()){
            //           generatePdf();
            //           //send to main page
            //           Navigator.pushReplacement(
            //             context, 
            //             MaterialPageRoute(builder: (BuildContext context) => const MyHomePage(startingPageIndex: 0,) )
            //           );
            //         }
            //       },
            //     ),
            //   ],
            // ),
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