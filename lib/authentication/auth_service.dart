import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gratitude_app/authentication/login_page.dart';
import 'package:gratitude_app/init_mood_page.dart';
import 'package:gratitude_app/main.dart';
import 'package:gratitude_app/utilities/alarm_manager.dart';
import 'package:gratitude_app/utilities/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gratitude_app/utilities/globals.dart' show Globals;

class AuthService {

  Future<void> signup({required String username, required String password, required BuildContext context}) async {
    try {
      //create account
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: '$username@mail.com', 
        password: password
      );      
      basicSignUp(context, username);
    } on FirebaseAuthException catch(e) {
      catchSignupErrors(e.code, context);
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

      //send to page depending on group
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) {
          if (Globals.group.compareTo('experimental') == 0) {
            return InitialMoodPage();
          } else {
            return MyHomePage(startingPageIndex: 0);
          }
        })
      );
    } 
    
    //catch signin errors
    on FirebaseAuthException catch(e) {
      catchSigninErrors(e.code, context);
    }
  }


  Future<void> signout({required BuildContext context}) async {
    //cancel past alarms and notifications
    await AndroidAlarmManager.cancel(0) && await AndroidAlarmManager.cancel(1);
    final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
    await notificationsPlugin.cancelAll();

    await FirebaseAuth.instance.signOut();
  }


  Future<void> reAuthDelete({required BuildContext context, required String email, required String password}) async {
    //re-authenticate
    final submittedCredential = EmailAuthProvider.credential(email: email, password: password);
    try {
      await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(submittedCredential);
      deleteAccount(context);
    } on FirebaseAuthException catch(e) {
      catchSigninErrors(e.code, context);
    }
  }


  // Future<void> signInAnon({required BuildContext context}) async {
  //   try {
  //     await FirebaseAuth.instance.signInAnonymously();
  //     basicSignUp(context);
  //   } on FirebaseAuthException catch (e) {
  //     Flushbar(
  //       message: 'An error occurred: ${e.code}',
  //       duration: Duration(milliseconds: 1500),
  //     ).show(context);
  //   }
  // }


  Future<void> anonToCredential({required BuildContext context, required String email, required String password}) async {
    final submittedCredential = EmailAuthProvider.credential(email: email, password: password);

    //link to user data
    try {
      await FirebaseAuth.instance.currentUser!.linkWithCredential(submittedCredential);
    } on FirebaseAuthException catch (e) {
      catchSignupErrors(e.code, context);
    }
  }


  Future<bool> editPassword({required BuildContext context, required String email, required String newPassword, required String oldPassword}) async {
    //re-authenticate
    final submittedCredential = EmailAuthProvider.credential(email: email, password: oldPassword);
    try {
      await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(submittedCredential);
      //change password
      // try {
        await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);
        return true;
      // } catch(e) {
        // print('TYPE: ${e.runtimeType}');
        // catchSignupErrors(e.code, context);
        // return false;
      // }
    } on FirebaseAuthException catch(e) {
      print('AUTH EXCEPTION ${e.code}');
      if (e.code.compareTo('weak-password') == 0) {
        catchSignupErrors(e.code, context);
      } else {
        catchSigninErrors(e.code, context);
      }
      return false;
    } catch(e) {
      print('Error changing password: $e');
      return false;
    }
   }


  Future<void> basicSignUp(BuildContext context, String username) async {
    //send to mood log page
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (BuildContext context) => const InitialMoodPage())//ConsentFormPage())
    );

    //sharedprefs
    setSharedPrefs();
  }


  Future<void> setSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

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
    prefs.setBool('asked_photo_permission', false);
    prefs.setString('group', 'experimental');
    Globals.group = 'experimental';

    //set notifs
    await NotificationService.initNotifications();

    //set sharedprefs according to given permissions
    bool notifPermission = await Permission.notification.isGranted;
    bool alarmPermission = await Permission.scheduleExactAlarm.isGranted;
    prefs.setBool('notifs_allowed', notifPermission);
    prefs.setBool('alarms_allowed', alarmPermission);
    print('NOTIFS: ${prefs.getBool('notifs_allowed')}, ALARMS: ${prefs.getBool('alarms_allowed')}');

    //cancel past alarms to avoid backlog
    await AndroidAlarmManager.cancel(0) && await AndroidAlarmManager.cancel(1);

    //schedule the next alarm if notifs allowed
    if (notifPermission) {
      await AndroidAlarmManager.oneShot(
        const Duration(seconds: 5), //schedule 5 seconds later
        0, 
        notificationScheduler,
        rescheduleOnReboot: true,
        allowWhileIdle: true,
        exact: alarmPermission,
        wakeup: true
      );
    }
  }


  Future<void> deleteAccount(BuildContext context) async {
    //delete data
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(Globals.group).child(FirebaseAuth.instance.currentUser!.uid);
    dbRef.remove();

    //delete images
    Reference imgRef = FirebaseStorage.instance.ref().child('images').child(FirebaseAuth.instance.currentUser!.uid);
    final listImages = await imgRef.listAll();
    if (listImages.items.isNotEmpty) {
      imgRef.delete();
    }

    //cancel past alarms and notifications
    await AndroidAlarmManager.cancel(0) && await AndroidAlarmManager.cancel(1);
    final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
    await notificationsPlugin.cancelAll();

    await FirebaseAuth.instance.currentUser?.delete();
    await signout(context: context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }
}



void catchSignupErrors(String code, BuildContext context) {
  String message;
  switch (code) {
    case 'weak-password':
      message = 'The password provided is too weak.';
      break;
    case 'email-already-in-use':
      message = 'An account already exists with this username.';
      break;
    case 'not-p-user':
      message = 'Plese sign up with the username provided to you by email (e.g. p{your_participant_number})';
      break;
    case 'invalid-email':
      message = 'Please ensure your username contains only letters, numbers, or the following symbols: . , _ - + %';
      break;
    default:
      message = 'An error occurred: $code';
  }

  Flushbar(
    message: message,
    duration: Duration(milliseconds: 1500),
  ).show(context);
}

void catchSigninErrors(String code, BuildContext context) {
  String message;
  switch (code) {
    case 'user-not-found':
      message = 'No user found for that username.';
    case 'invalid-credential':
      message = 'The username or password is incorrect.';
    case 'invalid-email':
      message = 'Please ensure your username contains only letters, numbers, or the following symbols: . , _ - + %';
    default:
      message = 'An error occurred: $code';
  }

  Flushbar(
    message: message,
    duration: Duration(milliseconds: 1500),
  ).show(context);
}
