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

        if (mounted) {
          setState(() {
            if (categorizedLogs.containsKey(formatted)) {
              categorizedLogs[formatted]!.add(item['gratitude_item']);
            } else {
              categorizedLogs[formatted] = [item['gratitude_item']];
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
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              flexibleSpace:
                Center(
                  child: Text('Past Logs',
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, parentIndex) {
                  List<String> lst = categorizedLogs.values.elementAt(parentIndex);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(categorizedLogs.keys.elementAt(parentIndex))
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: lst.length,
                        itemBuilder: (context, childIndex) {
                            return Text(lst[childIndex]);
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

      // body: Center(

      //   child: SingleChildScrollView(
      //     child: Column(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         Text(
      //           'Past Logs',
      //           style: Theme.of(context).textTheme.displayMedium!.copyWith(
      //             color: Theme.of(context).colorScheme.primary,
      //           ),
      //         ),
      //         // loading //display "loading text while loading"
      //           // ? CircularProgressIndicator()
      //         // : Expanded( //otherwise, display list of logs
      //         //   child: gratitudeLogs.isNotEmpty
      //             // ? ListView.builder(
      //             //   itemCount: gratitudeLogs.length,
      //             //   prototypeItem: Text(
      //             //     gratitudeLogs.first['date'] + ': ' + gratitudeLogs.first['gratitude_item']
      //             //   ),
      //             //   itemBuilder: (context, index) {
      //             //     return Text(
      //             //       gratitudeLogs[index]['date'] + ': ' + gratitudeLogs[index]['gratitude_item']
      //             //     );
      //             //   },
      //             // )
      //             ListView.builder(
      //               itemCount: categorizedLogs.length,
      //               // prototypeItem: ListView(),
      //               shrinkWrap: true,
      //               physics: NeverScrollableScrollPhysics(),
      //               itemBuilder: (context, index) {
      //                 List<String> lst = categorizedLogs.values.elementAt(index);
      //                 return ListView(
      //                   // crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     Text(categorizedLogs.keys.elementAt(index)),
      //                     RepaintBoundary(
      //                       child: ListView.builder(
      //                         itemCount: lst.length,
      //                         prototypeItem: Text('fdsj'),
      //                         itemBuilder: (context, index) {
      //                           return Text(lst[index]);
      //                         },
      //                         shrinkWrap: true,
      //                         physics: NeverScrollableScrollPhysics(),
      //                       ),
      //                     )
      //                   ],
      //                 );
      //               },
      //             )
      //             // : Center(child: Text('No gratitude logs')),
      //         // )
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}