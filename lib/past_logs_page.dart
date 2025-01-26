import 'package:flutter/material.dart';

//database imports
import 'package:firebase_database/firebase_database.dart';


class PastLogsPage extends StatefulWidget {
  const PastLogsPage({super.key});

  @override
  State<PastLogsPage> createState() => _PastLogsPageState();
}


class _PastLogsPageState extends State<PastLogsPage> {

  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('GratitudeLogs');
  List<Map<String, String>> gratitudeLogs = [];

  void readData() {

    dbRef.onValue.listen((event) {
      DataSnapshot dataSnapshot = event.snapshot;
      Map<dynamic, dynamic> values = dataSnapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, values) {
        print('Key: $key');
        print('Log: ${values['gratitude_item']}');
        print('Date: ${values['date']}');
        //add to gratitude logs + sort
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    dbRef.onValue.listen((event) {
      DataSnapshot dataSnapshot = event.snapshot;
      Map<dynamic, dynamic> values = dataSnapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, values) {
        print('Key: $key');
        print('Log: ${values['gratitude_item']}');
        print('Date: ${values['date']}');
      });
    });

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text(
              'Past Logs',
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            ElevatedButton(
              onPressed: readData, 
              child: Text("Read Data"))
          ],
        ),
      ),
    );
  }
}