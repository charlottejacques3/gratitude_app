import 'package:flutter/material.dart';

//database imports
import 'package:firebase_database/firebase_database.dart';

//date formatting
import 'package:intl/intl.dart';

class PastLogsPage extends StatefulWidget {
  const PastLogsPage({super.key});

  @override
  State<PastLogsPage> createState() => _PastLogsPageState();
}


class _PastLogsPageState extends State<PastLogsPage> {

  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('GratitudeLogs');
  List<Map<dynamic, dynamic>> gratitudeLogs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    print('initially mounted: $mounted');
    
    dbRef.orderByChild('date').onValue.listen((event) {
      // if (mounted) {
        print('we here');
        //re-initialize gratitudeLogs to empty
        gratitudeLogs = [];

        DataSnapshot dataSnapshot = event.snapshot;
        Map<dynamic, dynamic> values = dataSnapshot.value as Map<dynamic, dynamic>;
        // print(values);
        values.forEach((key, value) {
          // print('Key: $key');
          // print('Log: ${value['gratitude_item']}');
          // print('Date: ${value['date']}');
          
          // add to gratitude logs + sort
          if (mounted) {
            print('mounted: $mounted');
            try {
              setState(() {
                gratitudeLogs.add(value);
                loading = false;
            });
            } catch (e) {
              print('error with setState $e');
            }
          }
          
        });

        //sort by date
        gratitudeLogs.sort((a, b) => a['date'].compareTo(b['date']));

        //group by date

        /** ideally: map with key being a date (in sorted order), value being a list of logs */
        for (final item in gratitudeLogs) {
          DateTime date = DateTime.parse(item['date']);
          String formatted;
          int daysAgo = calculateDifference(date);

          if (daysAgo == 0) {
            formatted = 'Today';
          } else if (daysAgo == 1) {
            formatted = 'Yesterday';
          } else if (daysAgo <= 6){
            formatted = DateFormat('EEEE', 'en_US').format(date);
          } else {
            formatted = DateFormat.yMMMMEEEEd().format(date);
          }
          item['date'] = formatted;
        }
      // }
    });
  }

  //calculates days between to see whether the logs are from today, yesterday, etc.
  int calculateDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day).difference(DateTime(date.year, date.month, date.day)).inDays;
  }

  @override
  Widget build(BuildContext context) {

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
            loading //display "loading text while loading"
              ? CircularProgressIndicator()
            : Expanded( //otherwise, display list of logs
              child: gratitudeLogs.isNotEmpty
                ? ListView.builder(
                  itemCount: gratitudeLogs.length,
                  prototypeItem: Text(
                    gratitudeLogs.first['date'] + ': ' + gratitudeLogs.first['gratitude_item']
                  ),
                  itemBuilder: (context, index) {
                    return Text(
                      gratitudeLogs[index]['date'] + ': ' + gratitudeLogs[index]['gratitude_item']
                    );
                  },
                )
                : Center(child: Text('No gratitude logs')),
            )
          ],
        ),
      ),
    );
  }
}