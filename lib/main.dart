// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:math';

//firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

//database imports
import 'package:firebase_database/firebase_database.dart';

//notifications
import 'package:timezone/data/latest.dart' as tz;
// import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gratitude_app/notification_service.dart';

//import pages
import 'gratitude_log_page.dart';
import 'past_logs_page.dart';
import 'reflection_page.dart';
import 'helper_functions.dart';
import 'settings_page.dart';


//create workmanager function to run notifications in the background
// void callbackDispatcher() async {
//   //init notifications
//   try {
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   // Initialize for the background isolate
//   const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
//   final InitializationSettings initializationSettings =
//       InitializationSettings(android: initializationSettingsAndroid);

//   flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   tz.initializeTimeZones();
//   } catch (e) {
//     print("exception caught initializing notifications in callback: $e");
//   }

//   Workmanager().executeTask((task, inputData) async {
//     print('we are doing the task!');

//     //read from the database
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     Map<dynamic, dynamic> values = {};
//     try {
//       DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('Settings');
//       var dataSnapshot = await dbRef.once();
//       values = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
//       print(values);
//     } catch (e) {
//       print("error reading from firebase: $e");
//     }
//     print('after');

//     DateTime notificationDate;

//     //generate time for random notifications - THIS DOESN'T WORK!!
//     if (values['random_notifications']) {
//       print('random');

//       //pick a random hour
//       var start = values['random_start_time'];
//       var end = values['random_end_time'];
//       int starttime = start['hours'];
//       int hour = Random().nextInt(end['hours']-start['hours']+1) + starttime;

//       //pick a random minute
//       bool withinRange = false;
//       int minute = 0;
//       while (!withinRange) {
//         minute = Random().nextInt(60); //generate a random minute
//         //check if it is within the range
//         if (!((hour == end['hours'] && minute > end['minutes']) ||
//               (hour == start['hours'] && minute < start['minutes']))) {
//           withinRange = true;
//         }
//       }

//       //schedule tomorrow's random notification
//       DateTime tmr = DateTime.now().add(Duration(days:1));
//       notificationDate = DateTime(tmr.year, tmr.month, tmr.day, hour, minute);
//       print(notificationDate);


//       /*
//       NEW IDEA:
//       - every 24 hours this function gets called
//       - start = number of minutes from now to the start of the next random range
//         - if currently in the random range, start = 0
//       - end = number of minutes from now to the end of the next random range
//       - generate random number between start and min(end, *24 hours in minutes*)
//       - add that random number to datetime.now() -> that is the scheduled time

//       CASES:
//       - range is 9am-5pm
//         - function is called at 6pm
//        */
//     }

//     //set time to next scheduled notification time
//     else {
//       print('scheduling');
//       notificationDate = nextTime(values['scheduled_time']['hours'], values['scheduled_time']['minutes']);
//       print(notificationDate);
//     }
    
//     // DateTime scheduleDate = DateTime(2025, 2, 13, 12, 21)?;
//     try {
//       print("in the notification scheduling try block");
//       NotificationService.scheduledNotification(
//         title: "Scheduled notification", 
//         body: "body", 
//         scheduledTime: DateTime.now().add(Duration(seconds: 30))//notificationDate
//       );
//     } catch (e) {
//       print("Exception caught while scheduling notification: $e");
//     }
//     print("notificaiton has been scheduled");
//     return Future.value(true); //indicates the task has been completed successfully
//   });
// }

void main() async {
  //database stuff
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //init notifications
  await NotificationService.initNotifications();
  tz.initializeTimeZones();

  //initialize workmanager
  // Workmanager().initialize(
  //   callbackDispatcher,
  //   isInDebugMode: true //change to false for production!
  // );

  // //register periodic task (aka when to choose the time for the daily random notification)
  // Workmanager().registerPeriodicTask(
  //   Random().nextInt(1000).toString(), //unique task id
  //   "repetiveNotificationTask",
  //   frequency: Duration(minutes: 15) //chooses a new time every 24 hours
  // );

  //for testing: one-off task
  // Workmanager().registerOneOffTask(
  //   "1", //unique task id
  //   "repetiveNotificationTask",
  // );

//debugRepaintRainbowEnabled = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gratitude App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(), 
      debugShowCheckedModeBanner: false,
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  var currentPageIndex = 0;
  String pageHeader = '';

  @override
  Widget build(BuildContext context) {
    //reruns every time setState is called
    
    //select the correct page to load
    Widget page;
    switch (currentPageIndex) {
      case 0:
        page = GratitudeLogPage();
        pageHeader = 'Log Gratitude';
      case 1:
        page = PastLogsPage();
        pageHeader = 'Past Logs';
      case 2:
        page = ReflectionPage();
        pageHeader = 'Reflection';
      default:
        throw UnimplementedError('no widget for $currentPageIndex');
    }

    return Scaffold(
      //appbar with settings icon
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Text(pageHeader, 
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
              color: Theme.of(context).colorScheme.primary),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsPage())
                    );
                  },
                )
              ),
            )
          ],
        ),
      ),
      //navigation
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          //change currentIndex based on what's been selected
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.edit), 
            label: 'Log',
          ),
          NavigationDestination(
            icon: Icon(Icons.book), 
            label: 'Past Logs',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology), 
            label: 'Reflect',
          ),
        ],
      ),
        body: Column(
        children: [
          Expanded(
            child: page,
          ),
        ],
      )
    );
  }
}