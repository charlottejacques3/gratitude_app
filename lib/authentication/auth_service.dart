import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gratitude_app/study_forms/consent_form_page.dart';
import 'package:gratitude_app/main.dart';
import 'package:gratitude_app/utilities/alarm_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  Future<void> signup({required String email, required String password, required BuildContext context}) async {
    try {
      //create account
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );      

      //send to consent form page
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (BuildContext context) => const ConsentFormPage())
      );

      //save default settings to shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('random_notifications', true);
      prefs.setInt('random_start_hours', 9); //9am start
      prefs.setInt('random_start_minutes', 0);
      prefs.setInt('random_end_hours', 17); //5pm end
      prefs.setInt('random_end_minutes', 0);
      prefs.setInt('scheduled_hours', 12); //12pm
      prefs.setInt('scheduled_minutes', 0);
      prefs.setBool('allow_ai', true);
      prefs.setBool('withdraw', false);
      prefs.setBool('consent_complete', false);

      //cancel past alarms to avoid backlog
      await AndroidAlarmManager.cancel(0) && await AndroidAlarmManager.cancel(1);

      //schedule the next alarm
      await AndroidAlarmManager.oneShot(
        const Duration(seconds: 5), //schedule 5 seconds later
        0, 
        notificationScheduler,
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
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
      await AndroidAlarmManager.cancel(0) && await AndroidAlarmManager.cancel(1);

      //schedule the next alarm
      await AndroidAlarmManager.oneShot(
        const Duration(seconds: 5), //schedule 5 seconds later
        0, 
        notificationScheduler,
        rescheduleOnReboot: true,
        allowWhileIdle: true,
        exact: true,
        wakeup: true
      );

      //send to main page
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (BuildContext context) => const MyHomePage(startingPageIndex: 0,) )
      );
    } 
    
    //catch signup errors
    on FirebaseAuthException catch(e) {
      String message = '';
      if (e.code == 'invalid-credential') {
        message = 'The username or password is incorrect.';
      } else if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'Please provide a valid email address.';
      } else {
        message = 'An error occurred: ${e.code}';
      }

      //show message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }


  Future<void> signout({required BuildContext context}) async {
    //cancel past alarms
    bool success = await AndroidAlarmManager.cancel(0) && await AndroidAlarmManager.cancel(1);
    print("Canceled alarm with IDs 0 and 1: $success");

    await FirebaseAuth.instance.signOut();
  }
}