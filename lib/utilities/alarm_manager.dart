//read settings from database
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gratitude_app/utilities/firebase_options.dart';
import 'package:gratitude_app/utilities/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<Map<dynamic, dynamic>> readSettings() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Map<dynamic, dynamic> values = {};
  try {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('Settings');
    var dataSnapshot = await dbRef.once();
    values = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
    print(values);
  } catch (e) {
    print("error reading from firebase: $e");
  }
  return values;
}

//find time to start alarm manager
Future<DateTime> startAlarmManager() async {
  Map<dynamic, dynamic> settings = await readSettings();
  var time;
  if (settings['random_notifications']) {
    time = settings['random_start_time'];
  } else {
    time = settings['scheduled_time'];
  }
  DateTime rn = DateTime.now();
  DateTime alarmTime = DateTime(rn.year, rn.month, rn.day, time['hours']-1, time['minutes']);

  //if already passed, schedule for tomorrow
  if (alarmTime.isBefore(rn)) {
    alarmTime = alarmTime.add(Duration(days: 1));
  }
  print('Alarm manager should go off at $alarmTime');
  return alarmTime;
}


//alarm manager, schedules the notifications
//this will run 1 hour before: (the beginning of the time range for random notifications, or the scheduled time for scheduled notifications)
@pragma('vm:entry-point')
Future<void> notificationScheduler() async {
  final DateTime now = DateTime.now();
  print("[$now] Hello, world! function='$notificationScheduler'");

  Map<dynamic, dynamic> settings = await readSettings();
  DateTime notificationDate = DateTime.now();
  DateTime rn = DateTime.now();

  //random notifications
  if (settings['random_notifications']) {
    print('random');
    
    bool withinRange = false;

    while(!withinRange) {

      //pick a random hour
      var start = settings['random_start_time'];
      var end = settings['random_end_time'];
      int starttime = start['hours'];
      int hour = Random().nextInt(end['hours']-start['hours']+1) + starttime;

      //pick a random minute
      int minute = 0;
      minute = Random().nextInt(60); //generate a random minute
      //check if it is within the range, and has not already happened
      // if (!((hour == end['hours'] && minute > end['minutes']) ||
      //       (hour == start['hours'] && minute < start['minutes']))) {
          // && !(hour == rn.hour && minute <= rn.minute)) {
      notificationDate = DateTime(rn.year, rn.month, rn.day, hour, minute);

      //if it's after the current time, or the current time is after the notification period, escape the loop
      DateTime endPeriod = DateTime(rn.year, rn.month, rn.day, end['hours'], end['minutes']);
      if (notificationDate.isAfter(rn) || rn.isAfter(endPeriod)) {
        withinRange = true;
      }
      // }
    }

    

    // notificationDate = DateTime(rn.year, rn.month, rn.day, hour, minute);
  }

  //scheduled notifications
  else {
    print('scheduled');
    var time = settings['scheduled_time'];
    notificationDate = DateTime(rn.year, rn.month, rn.day, time['hours'], time['minutes']);
  }

  //schedule the notification  
  print(notificationDate);
  try {
    tz.initializeTimeZones();
    NotificationService.scheduledNotification(
      title: "Gratitude App", 
      body: "Time to log your gratitude!", 
      scheduledTime: notificationDate
    );
  } catch (e) {
    print("Exception caught while scheduling notification: $e");
  }
  print("notification has been scheduled");
}