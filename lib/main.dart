import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gratitude_app/logs_model.dart';
import 'package:gratitude_app/utilities/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

//firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'utilities/firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

//notifications
import 'package:timezone/data/latest.dart' as tz;
import 'package:gratitude_app/utilities/notification_service.dart';
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

  //cache data so available offline
  FirebaseDatabase.instance.setPersistenceEnabled(true);

  //init notifications
  await NotificationService.initNotifications();
  tz.initializeTimeZones();

  //initialize alarm manager
  await AndroidAlarmManager.initialize();

  //print last notif date
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  print('LAST NOTIF TIME: ${prefs.getString('scheduled_notif_date')}');

  //set up global variable for group
  if (prefs.getString('group') != null) {
    Globals.group = prefs.getString('group')!;
  }

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

    //set styles for the app
    Color bg = Color.fromARGB(255, 250, 240, 230);
    return MaterialApp(
      title: 'Gratitude App',
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
  }

  @override
  Widget build(BuildContext context) {
    
    //select the correct page to load
    Widget page;
    switch (currentPageIndex) {
      case 0:
        page = GratitudeLogPage();
        pageHeader = 'Log Gratitude';
      case 1:
        page = PastLogsPage(editMode: pastLogsEditMode);
        pageHeader = 'Past Logs';
      case 2:
        //only allow if in experimental group
        if (Globals.group.compareTo('experimental') == 0) {
          page = ReflectionPage(editMode: reflectionEditMode);
          pageHeader = 'Reflection';
        } else {
          throw UnimplementedError('no widget for $currentPageIndex');
        }
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

            //add edit button for past logs page
            currentPageIndex == 1 ?
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
            currentPageIndex == 2 ?
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
              icon: Icon(Icons.book), 
              label: 'Past Logs',
            ),
            NavigationDestination(
              icon: Icon(Icons.psychology), 
              label: 'Reflect',
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