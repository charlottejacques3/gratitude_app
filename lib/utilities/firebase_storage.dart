import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<String> uploadToFirebase(File file, String filename) async {
  Reference refRoot = FirebaseStorage.instance.ref();

  String uid = FirebaseAuth.instance.currentUser!.uid;
  Reference refImageDir = refRoot.child('images').child(uid); //get reference to storage root and the user's folder
  Reference refImage = refImageDir.child(filename); //create a reference for the image to be stored

  //store file
  try {
    await refImage.putFile(File(file.path));
    //get download url
    return await refImage.getDownloadURL();
  } catch(e) {
    print('error storing images: $e');
    throw Error();
  }
}