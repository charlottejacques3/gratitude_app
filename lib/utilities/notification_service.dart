import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveNotificationResponse(NotificationResponse response) async {
    print("received notification response");
  }

  //initialize
  static Future<void> initNotifications() async {

    //prepare android init settings (would have to do more for ios)
    const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher'); //default flutter icon, can change

    //init settings
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
    );

    //initialize the plugin
    await notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotificationResponse,
    );

    
    //request notification permission for android
    await notificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

    //request schedule exact alarms for android
    if (await Permission.scheduleExactAlarm.isGranted) {
      print('Schedule exact alarm permission already granted');
    } else {
      // Request the permission
      final status = await Permission.scheduleExactAlarm.request();
      if (status.isGranted) {
        print('Schedule exact alarm granted');
      } else {
        print('Schedule exact alarm denied');
        print(status);
      }
    }
  }


  //request schedule exact alarm permission for android
  Future<void> requestScheduleExactAlarm() async {
    // Check if we already have the permission
    print('initial: ${Permission.scheduleExactAlarm.status}');
    if (await Permission.scheduleExactAlarm.isGranted) {
      print('Schedule exact alarm permission already granted');
      return;
    }
    
    // Request the permission
    final status = await Permission.scheduleExactAlarm.request();
    
    if (status.isGranted) {
      print('Schedule exact alarm granted');
    } else {
      print('Schedule exact alarm denied');
      print(status);
    }
  }
  
  
  //show instant notification
  static Future<void> showInstantNotification({required String title, required String body}) async {

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        "channelId", 
        "channelName",
        importance: Importance.high,
        priority: Priority.high
      )
    );

    await notificationsPlugin.show(0, title, body, platformChannelSpecifics);
  }

  //show a scheduled notification
  static Future<void> scheduledNotification({required String title, required String body, required DateTime scheduledTime}) async {

    //store time it's scheduled for
    String iso = scheduledTime.toIso8601String();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('scheduled_notif_date', iso);
    print('set time: ${prefs.getString('scheduled_notif_date')}');
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        "channelId", 
        "channelName",
        importance: Importance.high,
        priority: Priority.high
      )
    );

    await notificationsPlugin.zonedSchedule(
      0, title, body, 
      tz.TZDateTime.from(scheduledTime, tz.local), 
      platformChannelSpecifics, 
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle
    );
  }
}