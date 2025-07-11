import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gratitude_app/guiding_pages/inspiration_page.dart';
import 'package:gratitude_app/guiding_pages/main_reframing_page.dart';
import 'package:gratitude_app/logs_model.dart';
import 'package:gratitude_app/utilities/alarm_manager.dart';
import 'package:gratitude_app/utilities/globals.dart';
import 'package:gratitude_app/utilities/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

//firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'utilities/firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

//notifications
import 'package:timezone/data/latest.dart' as tz;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

//import pages
import 'authentication/auth_gate.dart';
import 'gratitude_log_page.dart';
import 'past_logs_page.dart';
import 'reflection_pages/reflection_page.dart';
import 'settings_page.dart';


void main() async {
  //initalize firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //app check
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest,
  );

  //cache data so available offline
  FirebaseDatabase.instance.setPersistenceEnabled(true);

  //init notifications
  // await NotificationService.initNotifications();
  tz.initializeTimeZones();

  //initialize alarm manager
  await AndroidAlarmManager.initialize();

  //print last notif date
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  print('LAST NOTIF TIME: ${prefs.getString('scheduled_notif_date')}');

  //check if permissions have changed
  bool? notifsAllowed = prefs.getBool('notifs_allowed');
  bool? alarmsAllowed = prefs.getBool('alarms_allowed');
  bool notifPermission = await Permission.notification.isGranted;
  bool alarmPermission = await Permission.scheduleExactAlarm.isGranted;
  if (notifPermission && (notifPermission != notifsAllowed || alarmPermission != alarmsAllowed)) {
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
  prefs.setBool('notifs_allowed', notifPermission);
  prefs.setBool('alarms_allowed', alarmPermission);

  //set up global variable for group
  if (prefs.getString('group') != null) {
    Globals.group = prefs.getString('group')!;
  }

  //get font license
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  runApp(
    ChangeNotifierProvider(
      create: (context) => LogsModel(),
      child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    //only allow portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    //set styles for the app
    Color bg = Color.fromARGB(255, 250, 240, 230);
    return MaterialApp(
      title: 'Gratitude Buddy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 188, 143, 186)
        ),
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
            backgroundColor: Color.fromARGB(255, 249, 241, 237),
            textStyle: GoogleFonts.instrumentSansTextTheme().bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold
            ),
          )
        ),
        useMaterial3: true, dialogTheme: DialogThemeData(backgroundColor: bg),
      ),
      home: ParticipantGate(), 
      debugShowCheckedModeBanner: false,
    );
  }
}


class MyHomePage extends StatefulWidget {
  final int startingPageIndex;
  const MyHomePage({super.key, required this.startingPageIndex});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  var currentPageIndex = 0;
  bool pastLogsEditMode = false;
  bool reflectionEditMode = false;
  String pageHeader = '';

  @override
  void initState() {
    super.initState();
    currentPageIndex = widget.startingPageIndex;

    //set checkin for control group 
    if (Globals.group.compareTo('control') == 0) {
      checkinDialog(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    Widget page;
    
    //select the correct page to load for experimental
    if (Globals.group.compareTo('experimental') == 0) {
      switch (currentPageIndex) {
        case 0:
          page = GratitudeLogPage();
          pageHeader = 'Log Gratitude';
        case 1:
          page = InspirationPage();
          pageHeader = 'Inspiration';
        case 2: 
          page = MainReframingPage();
          pageHeader = 'Reframing';
        case 3:
          page = ReflectionPage(editMode: reflectionEditMode);
          pageHeader = 'Activities';
        case 4:
          page = PastLogsPage(editMode: pastLogsEditMode);
          pageHeader = 'Past Logs';
        default:
          throw UnimplementedError('no widget for $currentPageIndex');
      }
    }
    //select the correct page to load for control
    else {
      switch (currentPageIndex) {
        case 0:
          page = GratitudeLogPage();
          pageHeader = 'Log Gratitude';
        case 1:
          page = PastLogsPage(editMode: pastLogsEditMode);
          pageHeader = 'Past Logs';
        default:
          throw UnimplementedError('no widget for $currentPageIndex');
      }
    }

    return Scaffold(
      //appbar with settings icon
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            //add edit button for past logs page
            (currentPageIndex == 1 && Globals.group.compareTo('experimental') != 0) || (currentPageIndex == 4 && Globals.group.compareTo('experimental') == 0)?
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      pastLogsEditMode = !pastLogsEditMode;
                    });
                  },
                  child: pastLogsEditMode ? Text('Cancel') : Text('Edit'),
                )
              ),
            )
            : //add edit button for reflection page
            currentPageIndex == 3 ?
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      reflectionEditMode = !reflectionEditMode;
                    });
                  },
                  child: reflectionEditMode ? Text('Cancel') : Text('Edit'),
                )
              ),
            ) : Spacer(),
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
        onDestinationSelected: (int index) {
          //change currentIndex based on what's been selected
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: 
          Globals.group.compareTo('experimental') == 0 ? [  //experimental group
            NavigationDestination(
              icon: Icon(Icons.edit), 
              label: 'Log',
            ),
            NavigationDestination(
              icon: Icon(Icons.lightbulb),
              label: 'Ideas'
            ),
            NavigationDestination(
              icon: Icon(Icons.psychology),
              label: 'Reframe'
            ),
            NavigationDestination(
              icon: Icon(Icons.spa), 
              label: 'Activities',
            ),
            NavigationDestination(
              icon: Icon(Icons.book), 
              label: 'Past Logs',
            ),
          ] : [ //control group
            NavigationDestination(
              icon: Icon(Icons.edit), 
              label: 'Log',
            ),
            NavigationDestination(
              icon: Icon(Icons.book), 
              label: 'Past Logs',
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