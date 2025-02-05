import 'dart:math';

import 'package:flutter/material.dart';

//database imports
import 'package:firebase_database/firebase_database.dart';

//date formatting
// import 'package:intl/intl.dart';


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

  void generatePastLogs() {
    dbRef.onValue.listen((event) {
      DataSnapshot dataSnapshot = event.snapshot;
      Map<dynamic, dynamic> values = dataSnapshot.value as Map<dynamic, dynamic>;
      print(values);

      final random_num = Random().nextInt(values.length);
      for (var i = 0; i < random_num; i++) {
        
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: 
          Text('Guidance',
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
      ),
    );
  }
}
