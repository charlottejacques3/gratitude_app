import 'dart:math';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gratitude_app/main.dart';
import 'package:gratitude_app/study_pages/consent_form_page.dart';
import 'package:gratitude_app/study_pages/demographics_page.dart';
import 'package:gratitude_app/utilities/alarm_manager.dart';
import 'package:gratitude_app/utilities/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gratitude_app/utilities/globals.dart' show Globals;
import 'package:gratitude_app/select_method_page.dart';

class AuthService {

  Future<void> signup({required String username, required String password, required BuildContext context}) async {
    try {
      //create account
      // await FirebaseAuth.instance.signInWithCustomToken(token)
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: '$username@mail.com', 
        password: password
      );      

      //send to consent form page
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (BuildContext context) => const DemographicsPage())//ConsentFormPage())
      );

      //sharedprefs
      setSharedPrefs();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('consent_complete', false);
      prefs.setBool('demographics_complete', false);
      prefs.setBool('initial_questionnaires_complete', false);
      prefs.setBool('asked_photo_permission', false);
    } 
    
    //catch signup errors
    on FirebaseAuthException catch(e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with this username.';
      } else if (e.code == 'invalid-email') {
        message = 'Please ensure your username contains only letters, numbers, or the following symbols: . , _ - + %';
      } else {
        message = 'An error occurred: ${e.code}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }


  Future<void> signin({required String username, required String password, required BuildContext context}) async {
    try {
      //create account
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: '$username@mail.com', 
        password: password
      );
      
      setSharedPrefs();

      //set notifs
      await NotificationService.initNotifications();

      //cancel past alarms to avoid backlog
      await AndroidAlarmManager.cancel(0) && await AndroidAlarmManager.cancel(1);

      //check for notification permission
      final notificationPermission = await Permission.notification.status; 
      final exactAlarmPermission = await Permission.scheduleExactAlarm.status;

      //schedule the next alarm if notifs allowed
      if (notificationPermission.isGranted) {
        await AndroidAlarmManager.oneShot(
          const Duration(seconds: 5), //schedule 5 seconds later
          0, 
          notificationScheduler,
          rescheduleOnReboot: true,
          allowWhileIdle: true,
          exact: exactAlarmPermission.isGranted,
          wakeup: true
        );
      }

      //send to page depending on group
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) {
          if (Globals.group.compareTo('experimental') == 0) {
            return SelectMethodPage();
          } else {
            return MyHomePage(startingPageIndex: 0);
          }
        })
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
    //cancel past alarms and notifications
    await AndroidAlarmManager.cancel(0) && await AndroidAlarmManager.cancel(1);
    final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
    await notificationsPlugin.cancelAll();

    await FirebaseAuth.instance.signOut();
  }

  //needs work
  Future<void> deleteAccount({required BuildContext context}) async {
    //delete data
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(Globals.group).child(FirebaseAuth.instance.currentUser!.uid);
    dbRef.remove();

    //delete images
    Reference imgRef = FirebaseStorage.instance.ref().child('images').child(FirebaseAuth.instance.currentUser!.uid);
    imgRef.delete();

    //cancel past alarms and notifications
    await AndroidAlarmManager.cancel(0) && await AndroidAlarmManager.cancel(1);
    final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
    await notificationsPlugin.cancelAll();

    await FirebaseAuth.instance.currentUser?.delete();
    await signout(context: context);
  }

  Future<void> setSharedPrefs() async {
    //pick random group + save to sharedprefs + global variables
      //TEMPORARY - SET BACK!!!
      int group = 1;//Random().nextInt(2); //0 is control group, 1 is experimental!!
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String groupName = 'control';
      if (group == 1) {
        groupName = 'experimental';
      }
      prefs.setString('group', groupName);
      Globals.group = groupName;
      print('ASSIGNED GROUP: $group');
      print('GLOBAL VARIABLE: ${Globals.group}');

      //save default settings to shared preferences
      if (prefs.getBool('random_notifications') == null || prefs.getInt('random_start_hours') == null || prefs.getInt('random_start_minutes') == null || prefs.getInt('random_end_hours') == null || prefs.getInt('random_end_minutes') == null || prefs.getInt('scheduled_hours') == null || prefs.getInt('scheduled_minutes') == null) {
        prefs.setBool('random_notifications', true);
        prefs.setInt('random_start_hours', 9); //9am start
        prefs.setInt('random_start_minutes', 0);
        prefs.setInt('random_end_hours', 17); //5pm end
        prefs.setInt('random_end_minutes', 0);
        prefs.setInt('scheduled_hours', 12); //12pm
        prefs.setInt('scheduled_minutes', 0);
      }
      prefs.setBool('allow_ai', true);
      prefs.setBool('withdraw', false);
      prefs.setBool('withdraw_in_crisis', false);
      prefs.setBool('study_complete', false);
  }
}


