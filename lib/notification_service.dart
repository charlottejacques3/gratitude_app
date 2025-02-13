import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:math';

class NotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
  // bool _isInitialized = false;

  // bool get isInitialized => _isInitialized;

  static Future<void> onDidReceiveNotificationResponse(NotificationResponse response) async {
    print("received notification response");
  }

  //initialize
  static Future<void> initNotifications() async {
    // if (_isInitialized) return; //prevent re-initialization

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
  }
  

  //notifications detail setup
  // NotificationDetails notificationDetails() {
  //   return const NotificationDetails(
  //     android: AndroidNotificationDetails(
  //       'daily_channel_id', 
  //       'Daily Notifications',
  //       channelDescription: 'Daily Notification Channel',
  //       importance: Importance.max,
  //       priority: Priority.high
  //     )
  //   );

  // }
  
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

    // try {
    //   return notificationsPlugin.show(id, title, body, const NotificationDetails());
    // } catch (e) {
    //   print("error caught in show notification: $e");
    // }
  }

  //show a scheduled notification
  static Future<void> scheduledNotification({required String title, required String body, required DateTime scheduledTime}) async {

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

  //show a repetitive notification
//   static Future<void> showRepetitiveNotification() async {
//     int randomId = Random().nextInt(1000);

//     final AndroidNotificationDetails _repetitiveAndroidNotificationDetails = 
//       const AndroidNotificationDetails(
//         "channelRemainderId",
//         "channelRemainderName",
//         channelDescription: "channelRemainderDescription",
//         importance: Importance.max,
//         priority: Priority.high,
//         playSound: true,
//         enableVibration: true,
//       );

//   final AndroidNotificationChannel _repetitiveNotificationChannel = 
//       const AndroidNotificationChannel(
//         "channelRemainderId",
//         "channelRemainderName",
//         description: "channelRemainderDescription",
//         importance: Importance.high,
//         playSound: true,
//         enableVibration: true,
//       );

//   notificationsPlugin.periodicallyShow(
//     randomId,
//     "Repetitive $randomId",
//     "Testing Zoned Notification $randomId",
//     RepeatInterval.everyMinute,
//     NotificationDetails(android: _repetitiveAndroidNotificationDetails),
//     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle
//   );
//   print(DateTime.now());
//   }

//   //on notification tap
}