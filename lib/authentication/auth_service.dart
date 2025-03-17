import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:gratitude_app/authentication/login_page.dart';
import 'package:gratitude_app/main.dart';
import 'package:gratitude_app/utilities/alarm_manager.dart';

class AuthService {

  Future<void> signup({required String email, required String password, required BuildContext context}) async {
    try {
      //create account
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      print('before scheduling alarm');
      

      //send to main page
      print('before sending to main page');
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (BuildContext context) => const MyHomePage() )
      );

      //save default settings to database
      DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('users')
                                                          .child(FirebaseAuth.instance.currentUser!.uid)
                                                          .child('Settings');
      dbRef.child('random_notifications').set(true);
      dbRef.child('random_start_time').child('hours').set(9); //9am start
      dbRef.child('random_start_time').child('minutes').set(0);
      dbRef.child('random_end_time').child('hours').set(17); //5pm end
      dbRef.child('random_end_time').child('minutes').set(0);
      dbRef.child('scheduled_time').child('hours').set(12); //12pm
      dbRef.child('scheduled_time').child('minutes').set(0);

      //cancel past alarms to avoid backlog
      bool success = await AndroidAlarmManager.cancel(0) && await AndroidAlarmManager.cancel(1);
      print("Canceled alarm with IDs 0 and 1: $success");

      //schedule the next alarm
      DateTime startTime = await startAlarmManager();
      await AndroidAlarmManager.periodic(
        const Duration(days: 1), 
        0, 
        notificationScheduler,
        startAt: startTime, //DateTime(2025, 2, 24, 11, 18),
        rescheduleOnReboot: true,
        allowWhileIdle: true,
        exact: true,
        wakeup: true
      );
    } 
    
    //catch signup errors
    on FirebaseAuthException catch(e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with this email.';
      } else if (e.code == 'invalid-email') {
        message = 'Please provide a valid email address.';
      } else {
        message = 'An error occurred: ${e.code}';
      }

      //show message to user
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        //can also set background colour, text colour, font size, etc.
      );
    }
  }


  Future<void> signin({required String email, required String password, required BuildContext context}) async {
    try {
      //create account
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, 
        password: password
      );

      //cancel past alarms to avoid backlog
      bool success = await AndroidAlarmManager.cancel(0) && await AndroidAlarmManager.cancel(1);
      print("Canceled alarm with IDs 0 and 1: $success");

      //schedule the next alarm
      DateTime startTime = await startAlarmManager();
      await AndroidAlarmManager.periodic(
        const Duration(days: 1), 
        0, 
        notificationScheduler,
        startAt: startTime, //DateTime(2025, 2, 24, 11, 18),
        rescheduleOnReboot: true,
        allowWhileIdle: true,
        exact: true,
        wakeup: true
      );

      //send to main page
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (BuildContext context) => const MyHomePage() )
      );
    } 
    
    //catch signup errors
    on FirebaseAuthException catch(e) {
      String message = '';
      if (e.code == 'invalid-credential') {
        message = 'The username or password is incorrect.';
      } else if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else {
        message = 'An error occurred: ${e.code}';
      }

      //show message to user
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        //can also set background colour, text colour, font size, etc.
      );
    }
  }


  Future<void> signout({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();

    //navigate back to login page
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (BuildContext context) => const LoginPage()),
      (route) => false
    );
  }
}