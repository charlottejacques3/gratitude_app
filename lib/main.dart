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
  List<DynamicFormWidget> dynamicForms = [DynamicFormWidget()];
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('GratitudeLogs');

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
                  itemCount: dynamicForms.length,
                  prototypeItem: dynamicForms.first,
                  itemBuilder: (context, index) {
                    return dynamicForms[index];
                },
              ),
            ),
            ElevatedButton(
              child: Text('Done'),
              onPressed: () async {
              try {
                print("in the try blockk");

                //look through all the entries
                for (final item in dynamicForms) {
                  String log = item.logController.text;
                  if (log.isNotEmpty) { //don't add empty entries
                    //map to a dictionary
                    Map<String, String> gratitudeLogs = {
                      'gratitude_item': log,
                      'date': DateTime.now().toIso8601String(),
                    };
                    //push creates a unique key
                    dbRef.push().set(gratitudeLogs);
                  }
                }
              } catch (e) {
                print('error writing data: $e');
              }
            }, 
            )
          ],
        ),
      ), 
      //button to add another form entry
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            dynamicForms.add(DynamicFormWidget());
          });
        },
        child: Icon(Icons.add),
        ),
    );
  }
}



class DynamicFormWidget extends StatelessWidget {
  final TextEditingController logController = TextEditingController();

  //how to dispose of widget after?

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