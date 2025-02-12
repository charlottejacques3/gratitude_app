// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

//firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'package:gratitude_app/api/firebase_api.dart';
// import 'package:gratitude_app/firebase_service.dart';
import 'firebase_options.dart';

//import files
import 'gratitude_log_page.dart';
import 'past_logs_page.dart';
import 'reflection_page.dart';

// import 'package:provider/provider.dart';

//messaging service
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'messaging_service.dart';
// import 'firebase_service.dart';
// import 'package:firebase_messaging/firebase_messaging.dart'; 

void main() async {
  //database stuff
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();
  // FirebaseAnalytics analytics = FirebaseAnalytics.instance;

    //messaging service
  // print("before trying");
  // try {
  //   print("trying");
  //   final messagingService = MessagingService();
  //   await messagingService.initializeMessaging(); //call the initialization function
  //   print("reached the end");
  // } catch (e) {
  //   print("error in main function $e");
  // }

//debugRepaintRainbowEnabled = true;
  runApp(const MyApp());

  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // runApp(
  //   Provider<FirebaseService>(
  //     create: (_) => FirebaseService(),
  //     child: MyApp(),
  //   )
  // );

  
  // 
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


  @override
  Widget build(BuildContext context) {
    //reruns every time setState is called

    // final firebaseService = Provider.of<FirebaseService>(context);
    
    //select the correct page to load
    Widget page;
    switch (currentPageIndex) {
      case 0:
        page = GratitudeLogPage();
      case 1:
        page = PastLogsPage();
      case 2:
        page = ReflectionPage();
      default:
        throw UnimplementedError('no widget for $currentPageIndex');
    }


    return Scaffold(
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
      // body: FutureBuilder<DataSnapshot?>(

      //   future: firebaseService.getData('GratitudeLogs'), 
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return Center(child: CircularProgressIndicator());
      //     }
      //     else if (snapshot.hasError) {
      //       return Center(child: Text('Error: ${snapshot.error}'));
      //     }
      //     else if (snapshot.hasData) {
      //        final DataSnapshot? data = snapshot.data;
      // if (data != null) {
        // Data exists; process it.  Note the extra null check!
        // return Text('Data: ${data.value}'); // Or your data display logic
        body: Column(
        children: [
          Expanded(
            child: page,
          ),
        ],
      )
    //   } else {
    //     // DataSnapshot is null (meaning data wasn't found or there was an error)
    //     return Text('No data found'); // Or other appropriate UI
    //   }
    // } else {
    //   return Text('Something went wrong'); // Should never happen with FutureBuilder
    // }
          
    //     }
    //   )
      
      
      
    );
  }
}