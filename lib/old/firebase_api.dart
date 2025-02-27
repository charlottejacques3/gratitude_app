import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  //create an instance of firebase messaging
  final _firebaseMessaging = FirebaseMessaging.instance;

  //function to initialize notifications
  Future<void> initNotifications() async {
    print('calling the function');
    //request permission (will prompt user)
    await _firebaseMessaging.requestPermission();

    //fetch the FCM token for this device
    final fCMToken = await _firebaseMessaging.getToken();

    //print the token (would normally send to server)
    print('Token: $fCMToken');
  }

  //function to handle received messages

  //function to initialize foreground and background settings
}