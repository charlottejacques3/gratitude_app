import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gratitude_app/study_pages/demographics_page.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:markdown/markdown.dart' as md;
import 'package:gratitude_app/utilities/widgets.dart';


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
  bool ageResidency = false;
  bool consent = false;
  bool interviewRecorded = false;
  bool dataAnalysis = false;
  bool dissemination = false;
  TextEditingController name = TextEditingController();
  TextEditingController date = TextEditingController();
  SignatureController signatureController = SignatureController(); 
  Uint8List? signatureBytes;

  //markdown
  String data = "# Gratitude Buddy";



  //generate pdf from consent form data
  void generatePdf() async {
    final pdf = pw.Document();

    
    String fileText = await rootBundle.loadString('assets/consent_form.md');
    final html = md.markdownToHtml(fileText);
    final short = html.substring(0, 100);

    // final mainText = File('sample.pdf');
    // final pdf = pw.Document.load(PdfDocumentParserBase(mainText.readAsBytesSync()));
    
    // pdf.addPage()

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
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
              pw.Text(short),

              //yes/no selections
              readForm && askQuestions && voluntary && withdrawConsent && ageResidency && consent && interviewRecorded && dataAnalysis && dissemination ?
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Paragraph(text: 'I have read the consent form - Yes'),
                    pw.Paragraph(text: 'I have had the opportunity to ask questions - Yes'),
                    pw.Paragraph(text: 'I understand that my participation in this study is voluntary - Yes'),
                    pw.Paragraph(text: 'I understand that I can withdraw my consent at any time - Yes'),
                    pw.Paragraph(text: 'I certify that I reside in North America and am over the age of 18 - Yes'),
                    pw.Paragraph(text: 'I agree to take part in the study - Yes'),
                    pw.Paragraph(text: 'I agree to have my interview recorded, if I choose to take part in one - Yes'),
                    pw.Paragraph(text: 'I agree to have data I enter on the app to be used for data analysis purposes - Yes'),
                    pw.Paragraph(text: 'I agree to have data I enter on the app to be used for research results dissemination purposes - Yes')
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
        Reference refFile = refFileDir.child(FirebaseAuth.instance.currentUser!.uid); //create a reference for the file to be stored

        await refFile.putData(pdfBytes, SettableMetadata(contentType: 'application/pdf'));
        String url = await refFile.getDownloadURL();

        //store to database
        DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('users').child(FirebaseAuth.instance.currentUser!.uid);
        await dbRef.update({'consent_form': url});

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

  @override
  void dispose() {
    super.dispose();
    name.dispose();
    date.dispose();
    signatureController.dispose();
  }

  //get text from markdown file
  void setText() async {
    String fileText = await rootBundle.loadString('assets/consent_form.md');
    setState(() {
      data = fileText;
    });
  }

  //open e-signature popup
  void signaturePopup() {
    showDialog(
      context: context, 
      builder: (BuildContext context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //signing box
              Signature(
                controller: signatureController,
                width: 300,
                height: 125,
              ),
          
              //save and clear
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () => signatureController.clear(),
                        child: Text('Clear')
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          final bytes = await signatureController.toPngBytes();
                          setState(() {
                            signatureBytes = bytes;
                          });
                          Navigator.pop(context);
                        }, 
                        child: Text('Save')
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   onPressed: () {
        //     Navigator.pop(context);
        //   }, 
        //   icon: Icon(Icons.arrow_back)
        // ),
        centerTitle: true,
        // automaticallyImplyLeading: false,
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
          child: ListView(
            children: [
              //form text
              MarkdownWidget(
                data: data,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
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
                label: 'I have had the opportunity to ask questions',
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

              //over the age of 18 + north america
              YesNoRadio(
                label: 'I certify that I reside in North America and am over the age of 18',
                radioSelected: ageResidency, 
                onChanged: (bool newValue) {
                  setState(() {
                    ageResidency = newValue;
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

              //interview recorded
              YesNoRadio(
                label: 'I agree to have my interview recorded, if I choose to take part in one',
                radioSelected: interviewRecorded, 
                onChanged: (bool newValue) {
                  setState(() {
                    interviewRecorded = newValue;
                  });
                }
              ),

              //data used for analysis
              YesNoRadio(
                label: 'I agree to have data I enter on the app to be used for data analysis purposes',
                radioSelected: dataAnalysis, 
                onChanged: (bool newValue) {
                  setState(() {
                    dataAnalysis = newValue;
                  });
                }
              ),

              //data used for dissemination
              YesNoRadio(
                label: 'I agree to have data I enter on the app to be used for research results dissemination purposes',
                radioSelected: dissemination, 
                onChanged: (bool newValue) {
                  setState(() {
                    dissemination = newValue;
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

              //show e-signature
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text('Signature '),
                    Expanded(
                      child: InkWell(
                        onTap: signaturePopup,
                        child: signatureBytes != null ? 
                          Image.memory(
                            signatureBytes!,
                            height: 50,
                            alignment: Alignment.centerLeft,
                          ) 
                        : Container(
                            height: 50,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.black)
                              )
                            ),
                          ),
                      ),
                    ),

                    //e-signature popup
                    IconButton(
                      icon: Icon(Icons.edit),
                      alignment: Alignment.centerRight,
                      onPressed: signaturePopup
                    )
                  ],
                ),
              ),
          
              //finish consent form
              ElevatedButton(
                child: Text('Submit Form and Sign Up'),
                onPressed: () async {
                  if(!readForm || !askQuestions || !voluntary || !withdrawConsent || !consent) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please accept all terms of the consent form to use the app')),
                    );
                  } else if (signatureBytes == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please add an e-signature to use the app')),
                    );
                  } else if (formKey.currentState!.validate()){
                    generatePdf();
                    //update sharedpreferences
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setBool('consent_complete', true);
                    //send to demographics page
                    Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(builder: (BuildContext context) => const DemographicsPage() )
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
