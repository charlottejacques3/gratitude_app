import 'package:flutter/material.dart';

//database imports
import 'package:firebase_database/firebase_database.dart';



class GratitudeLogPage extends StatefulWidget {
  const GratitudeLogPage({super.key});

  @override
  State<GratitudeLogPage> createState() => _GratitudeLogPageState();
}


class _GratitudeLogPageState extends State<GratitudeLogPage> {
  
  List<DynamicFormWidget> dynamicForms = [DynamicFormWidget()];
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('GratitudeLogs');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Log Gratitude',
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 30),
          Center(
            child: Text(
              'What are you grateful for today?',
              style: Theme.of(context).textTheme.titleLarge!
            ),
          ),
          ListView.builder(
            itemCount: dynamicForms.length,
            prototypeItem: dynamicForms.first,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return dynamicForms[index];
            },
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

                  //clear text fields
                  item.logController.text = '';
                }
              }
            } catch (e) {
              print('error writing data: $e');
            }
          }, 
          ),
        ],
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

  //how to dispose of controller after?

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
        [Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
              controller: logController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
        )
        ]
    );
  }
}