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
  Map<String, List<String>> categorizedLogs = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    print('initially mounted: $mounted');
    
    dbRef.onValue.listen((event) {
      //re-initialize gratitudeLogs to empty
      gratitudeLogs = [];

      DataSnapshot dataSnapshot = event.snapshot;
      Map<dynamic, dynamic> values = dataSnapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        
        // add to gratitude logs + sort
        if (mounted) {
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

      //sort by date in reverse order
      gratitudeLogs.sort((a, b) => a['date'].compareTo(b['date']));

      //group by date
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
        } else if (daysAgo <= 364) {
          formatted = DateFormat('MMMMEEEEd', 'en_US').format(date);
        } else {
          formatted = DateFormat.yMMMMEEEEd().format(date);
        }
        item['date'] = formatted;

        if (mounted) {
          setState(() {
            if (categorizedLogs.containsKey(formatted)) {
              categorizedLogs[formatted]!.add(item['gratitude_item']);
            } else {
              categorizedLogs[formatted] = [item['gratitude_item']];
              // categorizedLogs = {formatted: [item['gratitude_item']]} + categorizedLogs;
            }
          });
        }
      }
      print('logs: $categorizedLogs');
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
      appBar: AppBar(
        centerTitle: true,
        title: 
          Text('Past Logs',
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
      ),
      body: 
        loading //display "loading text while loading"
          ? Center(child: CircularProgressIndicator())
      : CustomScrollView( //otherwise display the logs
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, parentIndex) {
                List<String> lst = categorizedLogs.values.elementAt(categorizedLogs.length - 1 - parentIndex);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text(categorizedLogs.keys.elementAt(categorizedLogs.length - 1 - parentIndex),
                      style: Theme.of(context).textTheme.titleLarge!
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: lst.length,
                      itemBuilder: (context, childIndex) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(lst[childIndex],
                              style: Theme.of(context).textTheme.bodyMedium!
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
              childCount: categorizedLogs.length, // Number of parent items
            ),
          ),
        ],
      ),
    );
  }
}