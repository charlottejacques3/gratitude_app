import 'package:flutter/material.dart';

//database imports
import 'package:firebase_database/firebase_database.dart';

//date formatting
import 'package:intl/intl.dart';

//helper functions
import 'helper_functions.dart';

class PastLogsPage extends StatefulWidget {
  const PastLogsPage({super.key});

  @override
  State<PastLogsPage> createState() => _PastLogsPageState();
}


class _PastLogsPageState extends State<PastLogsPage> {

  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('GratitudeLogs');
  List<Map<dynamic, dynamic>> gratitudeLogs = [];
  Map<String, List<Map<String, String>>> categorizedLogs = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    // print('initially mounted: $mounted');
    
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
        Map<String, String> data = {
          'log': item['gratitude_item'],
          'type': item['type']
        };

        if (mounted) {
          setState(() {
            if (categorizedLogs.containsKey(formatted)) {
              categorizedLogs[formatted]!.add(data);//item['gratitude_item']);
            } else {
              categorizedLogs[formatted] = [data];//item['gratitude_item']];
            }
          });
        }
      }
      print('logs: $categorizedLogs');
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: 
        loading //display progress indicator while loading
          ? Center(child: CircularProgressIndicator())
      : CustomScrollView( //otherwise display the logs
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, parentIndex) {
                List<Map<String, String>> lst = categorizedLogs.values.elementAt(categorizedLogs.length - 1 - parentIndex);
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
                          child: Builder(
                            builder: (context) {
                              print('before displaying list');
                              //displaying text
                              if ('text'.compareTo(lst[childIndex]['type']!) == 0) { 
                                return Text(lst[childIndex]['log']!,
                                  style: Theme.of(context).textTheme.bodyMedium!
                                );
                              } 

                              //displaying images
                              else if ('image'.compareTo(lst[childIndex]['type']!) == 0) {
                                try {
                                  return Image.network(
                                    lst[childIndex]['log']!,
                                    height: 100,
                                    width: 100,
                                  );
                                } catch (e) {
                                  print('error displaying image: $e');
                                  return Container();
                                }   
                              } else {
                                print('else case: ${lst[childIndex]['type']}');
                                return Container();
                              }
                            }
                          )
                            
                            //if it's an image (modify this logic if more cases are added!)
                            
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