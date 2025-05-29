import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gratitude_app/utilities/globals.dart';

Future<bool> uploadToFirebase(File file, String filename) async {
  Reference refRoot = FirebaseStorage.instance.ref();

  String uid = FirebaseAuth.instance.currentUser!.uid;
  Reference refImageDir = refRoot.child('images').child(uid); //get reference to storage root and the user's folder
  Reference refImage = refImageDir.child(filename); //create a reference for the image to be stored

  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(Globals.group)
                                                          .child(FirebaseAuth.instance.currentUser!.uid)
                                                          .child('GratitudeLogs');

  //store file
  try {
    await refImage.putFile(File(file.path));
    //get download url
    String url = await refImage.getDownloadURL();
    //map to a dictionary
      Map<String, String> gratitudeImages = {
        'gratitude_item': url,
        'date': filename,
        'type': 'image'
      };
      //send to database
      dbRef.push().set(gratitudeImages);
    return true; //if successful
  } catch(e) {
    print('error storing images: $e');
    throw Error();
  }
}


//deleting local images
void deleteLocalImage(String filename) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final localPath = '${dir.path}/$filename';
    File(localPath).delete();
  } catch (e) {
    print('error deleting image: $e');
  }
}