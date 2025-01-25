import 'package:flutter/material.dart';

//firebase imports
import 'package:firebase_core/firebase_core.dart';
//database imports
import 'package:firebase_database/firebase_database.dart';

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