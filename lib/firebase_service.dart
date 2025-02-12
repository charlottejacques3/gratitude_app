import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Database
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Messaging
import 'package:flutter/material.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Handle background message
    print('Background message: ${message.notification?.body}');
    //Consider adding code to save the message or other relevant actions here
  }

class FirebaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _fcmToken;

  // Method to get data from Realtime Database
  Future<DataSnapshot?> getData(String path) async {
  try {
    final DatabaseEvent event = await _database.ref(path).once();
    return event.snapshot;
  } catch (e) {
    print('Error getting data: $e');
    // Handle the error appropriately.  Perhaps return a default DataSnapshot or throw an exception
    //  For example, you might re-throw the error, or return an empty DataSnapshot:
    // final Map<String, dynamic> defaultData = {'value': 'Default Value'}; //Your default values
    //     return DataSnapshot.fromMap(defaultData);
    // return DataSnapshot(exists:false);
    return null;
  }
}

  //Get FCM token
  Future<String?> getFCMToken() async {
    if (_fcmToken == null) {
      try {
        _fcmToken = await _messaging.getToken();
      } catch (e) {
        print('Error getting FCM token: $e');
      }
    }
    return _fcmToken;
  }


  //Handle messages when the app is in the background or terminated
  Future<void> handleBackgroundMessages() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  //Handle messages when the app is opened by tapping the notification
  void handleAppOpenedByNotification() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      //Handle message here
      print('App opened from notification: ${message.notification?.body}');
    });
  }
}

 