import 'dart:math';

import 'package:flutter/material.dart';

//database imports
import 'package:firebase_database/firebase_database.dart';

//date formatting
import 'package:intl/intl.dart';

//helper functions
import '../helper_functions.dart';


//type of inspiration constants
const PAST_LOG = 0;
const PROMPT = 1;
const PICTURE = 2;


class InspirationPage extends StatefulWidget {

  const InspirationPage({super.key});

  @override
  State<InspirationPage> createState() => _InspirationPageState();
}


class _InspirationPageState extends State<InspirationPage> {

  final TextEditingController logController = TextEditingController();
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('GratitudeLogs');
  int inspoType = 1;
  String selectedPastLog = '';
  String selectedLogRelativeDate = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();

    generatePastLogs();
  }

  //pick a category of inspiration
  void pickType() {
    final type = Random().nextInt(3);
    switch (type) {
      case PAST_LOG:
        generatePastLogs();
      case PROMPT:
      case PICTURE:
    }
  }

  //randomly generate a past log from the database
  void generatePastLogs() {
    dbRef.onValue.listen((event) {

      //get list of keys
      DataSnapshot dataSnapshot = event.snapshot;
      Map<dynamic, dynamic> values = dataSnapshot.value as Map<dynamic, dynamic>;
      List<dynamic> keys = values.keys.toList();

      //pick random key
      final randomNum = Random().nextInt(values.length);
      dynamic pastLogKey = keys[randomNum];

      //format the date
      DateTime date = DateTime.parse(values[pastLogKey]['date']);
        String formatted;
        int daysAgo = calculateDifference(date);

        if (daysAgo == 0) {
          formatted = 'Today';
        } else if (daysAgo == 1) {
          formatted = 'Yesterday';
        } else if (daysAgo <= 6){
          formatted = 'On ' + DateFormat('EEEE', 'en_US').format(date);
        } else if (daysAgo <= 364) {
          formatted = 'On ' + DateFormat('MMMMEEEEd', 'en_US').format(date);
        } else {
          formatted = 'On ' + DateFormat.yMMMMEEEEd().format(date);
        }

      //set selectedPastLog to the log at that key
      if (mounted) {
        setState(() {
          selectedPastLog = values[pastLogKey]['gratitude_item'];
          selectedLogRelativeDate = formatted;
          loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: 
          Text('Log Gratitude',
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            //display progress indicator if not loaded
            loading 
              ? CircularProgressIndicator()
            :
            //past log
            Text(selectedLogRelativeDate + ', you were grateful for',
              style: Theme.of(context).textTheme.titleMedium!,
            ),
            Text(selectedPastLog,
              style: Theme.of(context).textTheme.titleLarge!,
            ),

            //refresh button
            ElevatedButton(
              onPressed: generatePastLogs,
              child: Text('Refresh'),
            ),

            //log button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, selectedPastLog);
              }, 
              child: Text('Log this!')
            ),

            SizedBox(height: 150)
          ]
        ),
      )
    );
  }
}
