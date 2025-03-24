import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'package:gratitude_app/authentication/auth_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'utilities/firebase_options.dart';

//notifications
import 'package:timezone/data/latest.dart' as tz;
import 'package:gratitude_app/utilities/notification_service.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

//import pages
import 'gratitude_log_page.dart';
import 'past_logs_page.dart';
import 'reflection_pages/reflection_page.dart';
import 'settings_page.dart';
import 'utilities/alarm_manager.dart';


void main() async {
  //initalize firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //init notifications
  await NotificationService.initNotifications();
  tz.initializeTimeZones();

  // for (var i = 0; i < 100; i++) {
  //    bool success = await AndroidAlarmManager.cancel(i);
  //   print("Canceled alarm with ID $i: $success");
  // }

  //request battery permissions
  await requestBatteryOptimizationExemption();
  
  //cancel past alarms to avoid backlog
  // bool success = await AndroidAlarmManager.cancel(0) && await AndroidAlarmManager.cancel(1);
  // print("Canceled alarm with IDs 0 and 1: $success");

  //initialize alarm manager
  await AndroidAlarmManager.initialize();

  //debugRepaintRainbowEnabled = true;
  runApp(const MyApp());

  
  
  //set up alarm manager
  //cancel a bunch of past alarms
  // for (var i = 0; i < 100; i++) {
  //   bool success = await AndroidAlarmManager.cancel(i);
  //   print("Canceled alarm with ID $i: $success");
  // }


  // await AndroidAlarmManager.cancel(0); //cancel past alarms to avoid backlog

  //only schedule notifications if logged in
  // if (FirebaseAuth.instance.currentUser != null) {
  //   DateTime startTime = await startAlarmManager();

    //using shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('start: ${prefs.getInt('random_start_hours')}:${prefs.getInt('random_start_minutes')}');
    print('end: ${prefs.getInt('random_end_hours')}:${prefs.getInt('random_end_minutes')}');
    // bool alarmScheduled = prefs.getBool('alarmScheduled') ?? false;
    // print('is alarm scheduled already? $alarmScheduled');

    // if (!alarmScheduled) {
      // print('scheduling new alarm for $startTime');
      // await AndroidAlarmManager.periodic(
      //   const Duration(days: 1), 
      //   0, 
      //   notificationScheduler,
      //   startAt: startTime, //DateTime(2025, 3, 11, 10, 00),
      //   rescheduleOnReboot: true,
      //   allowWhileIdle: true,
      //   exact: true,
      //   wakeup: true
      // );
      // prefs.setBool('alarmScheduled', true);
    // }
  // }
  
  
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
        fontFamily: GoogleFonts.instrumentSans().fontFamily,
        textTheme: GoogleFonts.instrumentSansTextTheme().copyWith(
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
          )
        ),
        scaffoldBackgroundColor: bg,
        appBarTheme: AppBarTheme(
          backgroundColor: bg,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: bg,
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
      home: AuthGate(), 
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
        automaticallyImplyLeading: false,
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