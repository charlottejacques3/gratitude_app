import 'dart:math';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:gratitude_app/utilities/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;


//find time to start alarm manager
Future<DateTime> startAlarmManager() async {
  //get shared preferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.reload();

  int hr;
  int min;
  if (prefs.getBool('random_notifications')!) {
    hr = prefs.getInt('random_start_hours')!;
    min = prefs.getInt('random_start_minutes')!;
  } else {
    hr = prefs.getInt('scheduled_hours')!;
    min = prefs.getInt('scheduled_minutes')!;
  }
  DateTime rn = DateTime.now();
  DateTime alarmTime = DateTime(rn.year, rn.month, rn.day, hr-1, min);

  //if already passed, schedule for tomorrow
  if (alarmTime.isBefore(rn)) {
    alarmTime = alarmTime.add(Duration(days: 1));
  }
  return alarmTime;
}


//alarm manager, schedules the notifications
//this will run 1 hour before: (the beginning of the time range for random notifications, or the scheduled time for scheduled notifications)
@pragma('vm:entry-point')
Future<void> notificationScheduler() async {
  final DateTime now = DateTime.now();
  print("[$now] Hello, world! function='$notificationScheduler'");

  //only schedule a notification if one hasn't happened today yet
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  String? iso = prefs.getString('scheduled_notif_date');
  if (iso == null || !DateUtils.isSameDay(DateTime.parse(iso), DateTime.now()) || DateTime.parse(iso).isAfter(DateTime.now())) {

    //make sure the period isn't over for today
    DateTime rn = DateTime.now();
    int startHrs = prefs.getInt('random_start_hours')!;
    int endHrs = prefs.getInt('random_end_hours')!;
    bool rand = prefs.getBool('random_notifications')!;
    DateTime startPeriod = DateTime(rn.year, rn.month, rn.day, startHrs, prefs.getInt('random_start_minutes')!);
    DateTime endPeriod = DateTime(rn.year, rn.month, rn.day, endHrs, prefs.getInt('random_end_minutes')!);
    DateTime scheduledTime = DateTime(rn.year, rn.month, rn.day, prefs.getInt('scheduled_hours')!, prefs.getInt('scheduled_minutes')!);

    if ((rand && endPeriod.isAfter(rn)) || (!rand && scheduledTime.isAfter(rn))) {
      DateTime notificationDate = DateTime.now();

      //random notifications
      if (rand) {
        bool withinRange = false;

        while(!withinRange) {

          //pick a random hour
          int hour = Random().nextInt(endHrs-startHrs+1) + startHrs;

          //pick a random minute
          int minute = 0;
          minute = Random().nextInt(60); //generate a random minute

          notificationDate = DateTime(rn.year, rn.month, rn.day, hour, minute);

          //if it's after the current time, before the end of the range, and after the beginning of the range, escape the loop
          //also escape if the current time is after the notification period to avoid an infinite loop
          if ((notificationDate.isAfter(rn) && notificationDate.isBefore(endPeriod)) && notificationDate.isAfter(startPeriod)|| rn.isAfter(endPeriod)) {
            withinRange = true;
          }
        }
      }

      //scheduled notifications
      else {
        notificationDate = scheduledTime;
      }

      //schedule the notification  
      print('NOTIF DATE: $notificationDate');
      try {
        tz.initializeTimeZones();
        NotificationService.scheduledNotification(
          title: "Gratitude Buddy", 
          body: "Time to log your gratitude!", 
          scheduledTime: notificationDate
        );
      } catch (e) {
        print("Exception caught while scheduling notification: $e");
      }
    }
  }

  //reschedule the next alarm
  DateTime nextAlarm = await startAlarmManager();
  var timeBetween = nextAlarm.difference(DateTime.now());
  print('next alarm: $nextAlarm, which is in $timeBetween');
  await AndroidAlarmManager.oneShot(
    timeBetween, //schedule for next time
    0, 
    notificationScheduler,
    rescheduleOnReboot: true,
    allowWhileIdle: true,
    exact: true,
    wakeup: true
  );
}