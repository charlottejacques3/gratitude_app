import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gratitude_app/study_pages/demographics_page.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gratitude_app/utilities/widgets.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';


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
  bool dataUsed = false;
  bool notInCrisis = false;
  TextEditingController name = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController email = TextEditingController();
  SignatureController signatureController = SignatureController(); 
  Uint8List? signatureBytes;

  //markdown
  String data = "# Gratitude Buddy";

  void sendEmail(String pdfFile) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    String username = FirebaseAuth.instance.currentUser!.uid;
    await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json'
      },
      body: json.encode({
        'service_id': 'service_5slkrqu',
        'template_id': 'template_9hbwsic',
        'user_id': 'SbsdJIwP7lrvY2JK1',
        'template_params': {
          'name': name.text,
          'email': email.text,
          'form': pdfFile,
          'username': username
        }
      }),
    );
  }

  void generateNewPdf() async {
    File file;
    try {
      var dir = await getApplicationDocumentsDirectory();
      file = File("${dir.path}/file.pdf");
      var data = await rootBundle.load('assets/consent_fillable.pdf');
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      final PdfDocument doc = PdfDocument(inputBytes: file.readAsBytesSync());
      PdfForm form = doc.form;
      for (int i = 0; i < 9; i++) {
        PdfRadioButtonListField yesNo = form.fields[i] as PdfRadioButtonListField;
        yesNo.selectedIndex = 0;
      }
      (form.fields[9] as PdfTextBoxField).text = name.text;
      (form.fields[10] as PdfTextBoxField).text = email.text;
      (form.fields[11] as PdfTextBoxField).text = date.text;
      PdfSignatureField sigField = form.fields[12] as PdfSignatureField;
      Rect bounds = sigField.bounds;
      PdfBitmap sigImage = PdfBitmap(signatureBytes!);
      PdfPage page = doc.pages[doc.pages.count-1];

      //get signature dimensions
      img.Image ogImg = img.decodeImage(signatureBytes!)!;
      double ogW = ogImg.width.toDouble();
      double ogH = ogImg.height.toDouble();
      double boundsH = bounds.height;
      double aspectRatio = ogW/ogH;
      double targetW = boundsH*aspectRatio;

      page.graphics.drawImage(sigImage, Rect.fromLTWH(bounds.left, bounds.top, targetW, boundsH));
      String pdfStr = base64Encode(await doc.save());
      sendEmail(pdfStr);
    } catch (e) {
      throw Exception('Error signing pdf: $e');
    }
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

              //over the age of 19 + north america
              YesNoRadio(
                label: 'I certify that I reside in North America and am over the age of 19',
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
                label: 'I agree to have data I enter on the app to be used for research purposes',
                radioSelected: dataUsed, 
                onChanged: (bool newValue) {
                  setState(() {
                    dataUsed = newValue;
                  });
                }
              ),

              //data used for dissemination
              YesNoRadio(
                label: 'I understand that this is a research study, and I confirm that I am not currently in crisis and/or in need of urgent and/or professional support',
                radioSelected: notInCrisis, 
                onChanged: (bool newValue) {
                  setState(() {
                    notInCrisis = newValue;
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

              //email
              Row(
                children: [
                  Text('Email'),
                  SizedBox(width: 10,),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please fill out this field';
                        } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                          return 'Please enter a valid email address';
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
              SwitchedColourButton(
                text: 'Submit Form and Sign Up',
                onClick: () async {
                  if(!readForm || !askQuestions || !voluntary || !withdrawConsent || !consent) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please accept all terms of the consent form to use the app')),
                    );
                  } else if (signatureBytes == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please add an e-signature to use the app')),
                    );
                  } else if (formKey.currentState!.validate()){
                    generateNewPdf();
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
