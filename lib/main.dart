import 'package:flutter/material.dart';

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

  //database variable - is this in the right place?
  // FirebaseDatabase database = FirebaseDatabase.instance;
  // print("after running");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gratitude App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(), //const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key}); //, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  // final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: GratitudeForm(),
            ),
          ],
        ),
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

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    //initializing database GratitudeLogs
    // dbRef = FirebaseDatabase.instance.ref().child('GratitudeLogs');
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
              DatabaseReference dbRef = FirebaseDatabase.instance.ref("/GratitudeLogs/123");
              await dbRef.set({
                "gratitude_item": myController.text,
                "date": DateTime.now().toIso8601String(),
              });
              //validate returns true if the form is valid, false otherwise
              // Map<String, String> gratitudeLogs = {
              //     'gratitude_item': myController.text,
              //     'date': DateTime.now().toIso8601String(),
              //   };
              //   //push creates a unique key?
              //   dbRef.push().set(gratitudeLogs);
              //   print(myController.text);
              // if (_formKey.currentState!.validate()) {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     const SnackBar(content: Text('Yay'))
              //   );

              //   print(myController.text);
              //   print(DateTime.now().toIso8601String());

                
              // }
            }, 
            child: Text('Done')
          ),
        ],
      )
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