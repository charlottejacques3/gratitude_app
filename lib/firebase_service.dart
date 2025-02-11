import 'package:firebase_database/firebase_database.dart'; // Import Firebase Database
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Messaging
import 'package:flutter/material.dart';

class FirebaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Method to get data from Realtime Database
  // Future<DataSnapshot> getData(String path) async {
  //   return await _database.ref(path).once();
  // }

  //Other Firebase methods

  // ... other Firebase related methods (for messaging, authentication etc.)...
}
