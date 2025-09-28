// generate pdf from consent form data
  // void generatePdf() async {
  //   final pdf = pw.Document();

    
  //   String fileText = await rootBundle.loadString('assets/consent_form.md');
  //   final html = md.markdownToHtml(fileText);
  //   final short = html.substring(0, 100);

  //   // final mainText = File('sample.pdf');
  //   // final pdf = pw.Document.load(PdfDocumentParserBase(mainText.readAsBytesSync()));
    
  //   // pdf.addPage()

  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) {
  //         return pw.Column(
  //           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //           children: [
  //             pw.Text(
  //               'Dynamic Scaffolding Gratitude Application Study',
  //               style: pw.TextStyle(
  //                 fontSize: 20,
  //                 fontWeight: pw.FontWeight.bold
  //               ),
  //               textAlign: pw.TextAlign.center
  //             ),
  //             pw.Text('CONSENT FORM STUFF',
  //             ),
  //             pw.Text('Please remember that participation in this study is voluntary.',
  //               style: pw.TextStyle(
  //                 fontWeight: pw.FontWeight.bold
  //               ),
  //             ),
  //             pw.Text(short),

  //             //yes/no selections
  //             readForm && askQuestions && voluntary && withdrawConsent && ageResidency && consent && interviewRecorded && dataUsed && notInCrisis ?
  //               pw.Column(
  //                 crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                 children: [
  //                   pw.Paragraph(text: 'I have read the consent form - Yes'),
  //                   pw.Paragraph(text: 'I have had the opportunity to ask questions - Yes'),
  //                   pw.Paragraph(text: 'I understand that my participation in this study is voluntary - Yes'),
  //                   pw.Paragraph(text: 'I understand that I can withdraw my consent at any time - Yes'),
  //                   pw.Paragraph(text: 'I certify that I reside in North America and am over the age of 18 - Yes'),
  //                   pw.Paragraph(text: 'I agree to take part in the study - Yes'),
  //                   pw.Paragraph(text: 'I agree to have my interview recorded, if I choose to take part in one - Yes'),
  //                   pw.Paragraph(text: 'I agree to have data I enter on the app to be used for research purposes - Yes'),
  //                   pw.Paragraph(text: 'I understand that this is a research study, and I confirm that I am not currently in crisis and/or in need of urgent and/or professional support - Yes')
  //                 ]
  //               ) : pw.Container(),
              
  //             //participant info
  //             pw.Text('Name: ${name.text}'),
  //             pw.Text('Date: ${date.text}'),
  //             pw.Text('Email: ${email.text}'),
  //             pw.Text('Username: ${FirebaseAuth.instance.currentUser!.email!.split('@')[0]}'),
  //             pw.Row(
  //               children: [
  //                 pw.Text('Signature: '),
  //                 pw.Image(pw.MemoryImage(signatureBytes!))
  //               ]
  //             )
  //           ]
  //         );
  //       }
  //     )
  //   );
  //   Uint8List pdfBytes = Uint8List(0);

  //   //save pdf to cloud storage
  //   pdf.save().then((Uint8List result) async {
  //     pdfBytes = result;
  //     final pdfFile = base64Encode(pdfBytes);
  //     sendEmail(pdfFile);

  //     // try {
  //     //   Reference refRoot = FirebaseStorage.instance.ref();

  //     //   Reference refFileDir = refRoot.child('consent_forms'); //get reference to storage root
  //     //   Reference refFile = refFileDir.child(FirebaseAuth.instance.currentUser!.uid); //create a reference for the file to be stored

  //     //   await refFile.putData(pdfBytes, SettableMetadata(contentType: 'application/pdf'));
  //     //   String url = await refFile.getDownloadURL();

  //     //   //store to database
  //     //   DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('users').child(FirebaseAuth.instance.currentUser!.uid);
  //     //   await dbRef.update({'consent_form': url});

  //     // } catch(e) {
  //     //   print('upload failed: $e');
  //     // }
  //   });
  // }