import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';

//firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

//database imports
import 'package:firebase_database/firebase_database.dart';

void main() async {

  //firebase stuff
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<DynamicTextWidget> dynamicList = [];
  List<String> currentLogs = [];

  
  void getLogs() {
    for (final item in dynamicList) {
      // print(item.logController.text);
      String log = item.logController.text;
      if (log.isNotEmpty) {
        currentLogs.add(log);
      }
      //now it contains hey and hi, probably if i restart then it won't. but after sending the values to the database i'll have to reset the list
    }
    print(currentLogs);
  }

  @override
  Widget build(BuildContext context) {
    //rerun every time setState is called
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text(
              'What are you grateful for today?',
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded (
                child: ListView.builder(
                  itemCount: dynamicList.length,
                  prototypeItem: dynamicList.first,//ListTile(
                  //   title: Text(currentLogs.first)
                  // ),
                  itemBuilder: (context, index) {
                    return dynamicList[index];//ListTile (
                      // title: Text(currentLogs[index]
                  //);//);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: GratitudeForm(),
            ),
            
          ],
        ),
      ), 
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("the button is pressed");
          setState(() {
            dynamicList.add(DynamicTextWidget());
            getLogs();
          });
          print(dynamicList);
        },
        child: Icon(Icons.add),
        ),
    );
  }
}



class GratitudeForm extends StatefulWidget {
  const GratitudeForm({super.key});

  @override
  GratitudeFormState createState() {
    return GratitudeFormState();
  }
}


class GratitudeFormState extends State<GratitudeForm> {
  final _formKey = GlobalKey<FormState>();
  final myController = TextEditingController();
  late DatabaseReference dbRef;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    //initializing database GratitudeLogs
    dbRef = FirebaseDatabase.instance.ref().child('GratitudeLogs');
  }

  @override
  void dispose() {
    //clean up the controller when the widget is disposed
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form (
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: myController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () async {
              //validate returns true if the form is valid, false otherwise
              if (_formKey.currentState!.validate()) {
                try {
                  // await dbRef.set({
                  //   "gratitude_item": myController.text,
                  //   "date": DateTime.now().toIso8601String(),
                  // });
                  print("in the try blockk");
                  Map<String, String> gratitudeLogs = {
                    'gratitude_item': myController.text,
                    'date': DateTime.now().toIso8601String(),
                  };
                  //push creates a unique key
                  dbRef.push().set(gratitudeLogs);
                  // GratitudeForm();
                } catch (e) {
                  print('error writing data: $e');
                }
              }
            }, 
            child: Text('Done')
          ),
        ],
      )
    );
  }
}

// class BasicStateful extends StatefulWidget {
//   @override
//   _BasicStatefulState createState() => _BasicStatefulState();
// }

// class _BasicStatefulState extends State<BasicStateful> {
//   @override
//   Widget build(BuildContext context) {

//   }
// }

class DynamicTextWidget extends StatelessWidget {
  TextEditingController logController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
        [TextFormField(
            controller: logController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          )
        ]
    );
  }
}


/*
SOURCES:
- Basic form setup: https://docs.flutter.dev/cookbook/forms/validation 
- Accessing text fields from a form: https://docs.flutter.dev/cookbook/forms/retrieve-input 

- Install Firebase: https://firebase.google.com/docs/flutter/setup?platform=android
- Firebase database: https://firebase.google.com/docs/database/flutter/start
 */