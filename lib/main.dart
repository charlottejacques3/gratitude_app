import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

//firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'utilities/firebase_options.dart';

//database imports
import 'package:firebase_database/firebase_database.dart';

//notifications
import 'package:timezone/data/latest.dart' as tz;
import 'package:gratitude_app/utilities/notification_service.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

//import pages
import 'gratitude_log_page.dart';
import 'past_logs_page.dart';
import 'reflection_pages/reflection_page.dart';
import 'settings_page.dart';
import 'utilities/helper_functions.dart';

//read settings from database
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
// Future<DateTime> startAlarmManager() async {
//   Map<dynamic, dynamic> settings = await readSettings();
//   var time;
//   if (settings['random_notifications']) {
//     time = settings['random_start_time'];
//   } else {
//     time = settings['scheduled_time'];
//   }
//   DateTime.now();
//   DateTime settings_dt = DateTime(rn.year, rn.month, rn.day, time['hours'], time['minutes']);
//   return settings_time;
// }


//alarm manager, schedules the notifications
//this will run 1 hour before the beginning of the time range for random notifications, or the scheduled time for scheduled notifications
@pragma('vm:entry-point')
Future<void> notificationScheduler() async {
  final DateTime now = DateTime.now();
  print("[$now] Hello, world! function='$notificationScheduler'");

  Map<dynamic, dynamic> settings = await readSettings();
  DateTime notificationDate;
  DateTime rn = DateTime.now();

  //random notifications
  if (settings['random_notifications']) {
    print('random');

      //pick a random hour
      var start = settings['random_start_time'];
      var end = settings['random_end_time'];
      int starttime = start['hours'];
      int hour = Random().nextInt(end['hours']-start['hours']+1) + starttime;

      //pick a random minute
      bool withinRange = false;
      int minute = 0;
      while (!withinRange) {
        minute = Random().nextInt(60); //generate a random minute
        //check if it is within the range, and has not already happened
        if (!((hour == end['hours'] && minute > end['minutes']) ||
              (hour == start['hours'] && minute < start['minutes']))
            && !(hour == rn.hour && minute <= rn.minute)) {
          withinRange = true;
        }
      }

      notificationDate = DateTime(rn.year, rn.month, rn.day, hour, minute);
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


void main() async {
  //initalize firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //init notifications
  await NotificationService.initNotifications();
  tz.initializeTimeZones();

  //initialize alarm manager
  await AndroidAlarmManager.initialize();

  //debugRepaintRainbowEnabled = true;
  runApp(const MyApp());
  
  //set up alarm manager
  await AndroidAlarmManager.periodic(
    const Duration(days: 1), 
    0, 
    notificationScheduler,
    startAt: DateTime(2025, 2, 24, 11, 18),
    rescheduleOnReboot: true,
    allowWhileIdle: true,
    exact: true,
    wakeup: true
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Color bg = Color.fromARGB(255, 250, 240, 230);
    return MaterialApp(
      title: 'Gratitude App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 188, 143, 186)),
        /**
         * font possibilities
         * hind
         * instrument sans
         */
        fontFamily: GoogleFonts.instrumentSans().fontFamily,
        textTheme: GoogleFonts.instrumentSansTextTheme().copyWith(
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            // fontFamily: GoogleFonts.instrumentSans().fontFamily
          )
          // titleLarge: TextStyle(
          //   fontWeight: FontWeight.bold
          // ) ,
          // bodyMedium: TextStyle(
          //   fontWeight: FontWeight.w00
          // )
          // titleLarge: TextStyle(
          //   fontFamily: 
          // )
        ),
        scaffoldBackgroundColor: bg,
        appBarTheme: AppBarTheme(
          backgroundColor: bg,
          // titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
          //     color: Theme.of(context).colorScheme.primary,
          //     fontWeight: FontWeight.bold,
          //     fontFamily: GoogleFonts.instrumentSans().fontFamily,
          //   ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: bg,
          // labelTextStyle: WidgetStateColor
          
          // GoogleFonts.instrumentSansTextTheme().bodyMedium!.copyWith(
          //     color: Theme.of(context).colorScheme.primary,
          //     fontWeight: FontWeight.bold
          //   ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 249, 241, 237),//Color.fromARGB(255, 249, 245, 241),
            textStyle: GoogleFonts.instrumentSansTextTheme().bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold
            ),
          )
        ),
        dialogBackgroundColor: bg,
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
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold
            ),
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
        // type: BottomNavigationBarType.fixed,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: page,
            ),
          ),
        ],
      )
    );
  }
}