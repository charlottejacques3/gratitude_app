import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gratitude_app/utilities/alarm_manager.dart';
import 'package:gratitude_app/utilities/firebase_storage.dart';
import 'package:gratitude_app/utilities/upload_task.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  //for firebase storage saving to device when offline
  await Hive.initFlutter();
  Hive.registerAdapter(UploadTaskDataAdapter());
  await Hive.openBox<UploadTaskData>('uploads');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    //set styles for the app
    Color bg = Color.fromARGB(255, 250, 240, 230);
    Color prim = Theme.of(context).colorScheme.primary;
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
  String pageHeader = '';

  //local image uploads
  List<File> localImages = [];
  final uploadsBox = Hive.box<UploadTaskData>('uploads');

  @override
  void initState() {
    super.initState();
    currentPageIndex = widget.startingPageIndex;
    scheduleNextAlarm();

    //trigger upload of queued images
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        uploadPendingImages();
      }
    });
  }

  void loadLocalImages() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = Directory(dir.path).listSync().whereType<File>();
    setState(() {
      localImages = files.toList();
    });
  }

  void uploadPendingImages() async {
    print('TRYING TO UPLOAD');
    print('current list');
    final pending = uploadsBox.values.toList();
    for (var task in pending) {
      final file = File(task.localPath);
      if (await file.exists()) {
        
        Reference refRoot = FirebaseStorage.instance.ref();

        String uid = FirebaseAuth.instance.currentUser!.uid;
        Reference refImageDir = refRoot.child('images').child(uid); //get reference to storage root and the user's folder
        Reference refImage = refImageDir.child(task.fileName); //create a reference for the image to be stored

        //store file
        // try {
        try {
          await refImage.putFile(File(file.path));
          // uploadToFirebase(file, task.fileName);
          // await FirebaseStorage.instance.ref('images/${task.fileName}').putFile(file);
          await task.delete(); //remove task from the queue
          print('Synced: ${task.fileName}');
        } catch (e) {
          print('Retry later: ${task.fileName}');
          print('error: $e');
        }
      }
    }
  }

  //schedule next alarm
  void scheduleNextAlarm() async {
    //cancel past alarms to avoid backlog
    await AndroidAlarmManager.cancel(0) && await AndroidAlarmManager.cancel(1);

    //schedule the next alarm if one is not already set
    // bool alarmSet = await AndroidAlarmManager.
    await AndroidAlarmManager.oneShot(
      const Duration(seconds: 5), //schedule 5 seconds later
      0, 
      notificationScheduler,
      rescheduleOnReboot: true,
      allowWhileIdle: true,
      exact: true,
      wakeup: true
    );
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
            :
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