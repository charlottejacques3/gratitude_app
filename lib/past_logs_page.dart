import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gratitude_app/main.dart';
import 'package:gratitude_app/utilities/globals.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'utilities/date_functions.dart';

class PastLogsPage extends StatefulWidget {
  final bool editMode;

  const PastLogsPage({super.key, required this.editMode});

  @override
  State<PastLogsPage> createState() => _PastLogsPageState();
}


class _PastLogsPageState extends State<PastLogsPage> {

  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(Globals.group)
                                                          .child(FirebaseAuth.instance.currentUser!.uid);
                                                          // .child('GratitudeLogs');
  StreamSubscription<DatabaseEvent>? listener;
  List<Map<dynamic, dynamic>> gratitudeLogs = [];
  Map<String, Map<String, List<Map<String, String>>>> categorizedLogs = {};
  Map<String, int> moodsByDate = {};
  Map<String, int> moodsByTime = {};
  List<IconData> moods = [Icons.sentiment_very_dissatisfied, Icons.sentiment_dissatisfied, Icons.sentiment_neutral, Icons.sentiment_satisfied_alt, Icons.sentiment_very_satisfied_rounded];
  List<Color> colours = [Color.fromARGB(255, 250, 100, 100), Color.fromARGB(255, 250, 142, 100), Color.fromARGB(255, 214, 185, 87), Color.fromARGB(255, 152, 201, 97), Color.fromARGB(255, 105, 182, 159)];
  bool loading = true;
  List<dynamic> idsToDelete = [];
  bool connected = true;
  bool containsImages = false;

  @override
  void initState() {
    super.initState();
    dbRef.keepSynced(true);
    
    listener = dbRef.onValue.listen((event) async {
      //re-initialize gratitudeLogs to empty
      gratitudeLogs = [];

      DataSnapshot dataSnapshot = event.snapshot;
      if (dataSnapshot.value != null) {
        Map<dynamic, dynamic> values = dataSnapshot.value as Map<dynamic, dynamic>;

        //look through logs
        if (values['GratitudeLogs'] != null) {
          Map<dynamic, dynamic> logs = values['GratitudeLogs'];
          logs.forEach((key, value) {
            if (mounted) {
              try {
                setState(() {
                  Map<dynamic, dynamic> entry = value;
                  entry['id'] = key;
                  gratitudeLogs.add(entry);
              });
              } catch (e) {
                print('error with setState $e');
              }
            }
          });

          //sort by date 
          gratitudeLogs.sort((a, b) {
            int byDate = a['date'].compareTo(b['date']);
            if (byDate != 0) return byDate;
            return a['number'].compareTo(b['number']); 
          });

          //group by date
          for (final item in gratitudeLogs) {
            String formatted = formatDate(item['date']);
            // item['date'] = formatted;

            //so it will update if there's no internet
            bool connection = true;
            if (item['type'].compareTo('image') == 0 && connected) {
              connection = await InternetConnection().hasInternetAccess;
              if (mounted) {
                setState(() {
                  containsImages = true;
                  connected = connection;
                });
              }
            }

            //don't add images if no internet
            if (connected || item['type'].compareTo('image') != 0) {
              Map<String, String> data = {
              'log': item['gratitude_item'],
              'type': item['type'],
              'id': item['id']
              };

              if (mounted) {
                setState(() {
                  if (categorizedLogs.containsKey(formatted)) {
                    if (categorizedLogs[formatted]!.containsKey(item['date'])) {
                      categorizedLogs[formatted]![item['date']]!.add(data);
                    } else {
                      categorizedLogs[formatted]![item['date']] = [data];
                    }
                    // categorizedLogs[formatted]!.add(data);
                  } else {
                    categorizedLogs[formatted] = {
                      item['date']: [data]
                    };
                  }
                });
              }
            }
          }
        }

        print('LOGS: $categorizedLogs');

        //look through moods and group by date + pick the most recent one
        if (values['Moods'] != null) {
          List<dynamic> moods = [];
          values['Moods'].forEach((k,v) => moods.add(v));
          moods.sort((a, b) => a['date'].compareTo(b['date']));
          for(final moodLog in moods) {
            if (mounted) {
              // String formatted = formatDate(moodLog['date']);
              setState(() {
                try {
                  moodsByTime[moodLog['date']] = moodLog['mood'];
                } on Exception catch (e) {
                  print('error: $e');
                }
              });
            }
          }
        }
      }
      setState(() {
        loading = false;
      });

      if (!connected && containsImages) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please connect to the internet to view image logs')),
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (listener != null) {
      listener!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
        gratitudeLogs.isEmpty ? 
        Center(
          child: Text(
            'No logs yet!',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),
        ) :
        loading //display progress indicator while loading
          ? Center(child: CircularProgressIndicator())
      : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            CustomScrollView( //otherwise display the logs
              slivers: [
            
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, parentIndex) {
                      Map<String, List<Map<String, String>>> dateMap = categorizedLogs.values.elementAt(categorizedLogs.length - 1 - parentIndex);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          //display date
                          Wrap(
                            children: [
                              Text(categorizedLogs.keys.elementAt(categorizedLogs.length - 1 - parentIndex),
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                                )
                              ),
                              SizedBox(width: 15,),
                              //display mood if available
                              // moodsByDate.containsKey(categorizedLogs.keys.elementAt(categorizedLogs.length - 1 - parentIndex))
                              // ? Container(
                              //   decoration: BoxDecoration(
                              //     borderRadius: BorderRadius.all(Radius.circular(5)),
                              //     border: Border.all(
                              //       width: 0.5,
                              //       color: Colors.black
                              //     ),
                              //     color: colours[moodsByDate[categorizedLogs.keys.elementAt(categorizedLogs.length - 1 - parentIndex)]! - 1],
                              //   ),
                              //   child: Padding(
                              //     padding: const EdgeInsets.all(8.0),
                              //     child: Row(
                              //       mainAxisSize: MainAxisSize.min,
                              //       children: [
                              //         Text('Mood of the day: ',
                              //           style: Theme.of(context).textTheme.bodyLarge!
                              //         ),
                              //         Icon(moods[moodsByDate[categorizedLogs.keys.elementAt(categorizedLogs.length - 1 - parentIndex)]! - 1],
                              //         )
                              //       ],
                              //     ),
                              //   ),
                              // ) : Container(),
                            ],
                          ),
                          SizedBox(height: 5,),
                          
                          //boxes for individual log periods
                          ListView.builder(
                            itemCount: dateMap.length,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, middleIndex) {
                              List<Map<String, String>> lst = dateMap.values.elementAt(middleIndex);
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    border: Border.all(
                                      width: 0.5,
                                      color: Colors.grey
                                    )
                                  ),
                                  child: ListView(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    children: [
                                      //display mood
                                      moodsByTime.containsKey(dateMap.keys.elementAt(middleIndex)) ?
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                                    border: Border.all(
                                                      width: 0.5,
                                                      color: Colors.black
                                                    ),
                                                    color: colours[moodsByTime[dateMap.keys.elementAt(middleIndex)]! - 1],
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text('Mood: ',
                                                          style: Theme.of(context).textTheme.bodyLarge!
                                                        ),
                                                        Icon(moods[moodsByTime[dateMap.keys.elementAt(middleIndex)]! - 1],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                
                                      //display logs
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: lst.length,
                                        itemBuilder: (context, childIndex) {
                                          return Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: ListTile(
                                              title: Builder(
                                                builder: (context) {
                                      
                                                  //displaying text
                                                  if ('text'.compareTo(lst[childIndex]['type']!) == 0) { 
                                                    return Text(lst[childIndex]['log']!,
                                                      style: Theme.of(context).textTheme.bodyLarge!
                                                    );
                                                  } 
                                                  //displaying images
                                                  else if ('image'.compareTo(lst[childIndex]['type']!) == 0) {
                                                    //check internet connection
                                                    // bool connected = await InternetConnection().hasInternetAccess;
                                                    // if (!connected) {
                                                    //   return Text('No internet connection - please go online to view photo logs');
                                                    // }
                                                    try {
                                                      return ListTile(
                                                        title: Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: Image.network(
                                                            lst[childIndex]['log']!,
                                                            height: 130,
                                                            loadingBuilder: (context, child, loadingProgress) {
                                                              if (loadingProgress != null) {
                                                                return Align(
                                                                  alignment: Alignment.centerLeft,
                                                                  child: Container(
                                                                    alignment: Alignment.center,
                                                                    height: 200,
                                                                    width: 200,
                                                                    child: CircularProgressIndicator()
                                                                  )
                                                                );
                                                              } else {
                                                                return child;
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    } catch (e) {
                                                      print('error displaying image: $e');
                                                      return Container();
                                                    }   
                                                  } else {
                                                    return Container();
                                                  }
                                                }
                                              ),
                                              contentPadding: widget.editMode ? EdgeInsets.only(left:0) : EdgeInsets.only(left:10),
                                              dense: true,
                                              visualDensity: VisualDensity(horizontal:VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
                                              horizontalTitleGap: 0,
                                              minLeadingWidth: 0,
                                      
                                              //add leading if in edit mode
                                              leading: widget.editMode ? 
                                                Checkbox(
                                                  shape: CircleBorder(),
                                                  value: idsToDelete.contains(lst[childIndex]['id']), 
                                                  onChanged: (isSelected) {
                                                    if (isSelected == true) {
                                                    setState(() {
                                                      idsToDelete.add(lst[childIndex]['id']); //if just selected, add to list
                                                    });
                                                  } else {
                                                    setState(() {
                                                      idsToDelete.remove(lst[childIndex]['id']); //if just unselected, remove from list
                                                    });
                                                  }
                                                  }
                                                ) : Container(width: 0,)
                                              ) 
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          ),
                        ],
                      );
                    },
                    childCount: categorizedLogs.length, // number of parent items
                  ),
                ),
                SliverToBoxAdapter(
                  child: widget.editMode ? SizedBox(height: 60,) : Container()
                )
              ],
            ),

            //delete logs button
            widget.editMode ?
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: ElevatedButton(
                onPressed: () async {
                  //update stats
                  DatabaseReference statsRef = dbRef.child('Stats');
                  final snapshot = await statsRef.get();
                  if (snapshot.exists) {
                    final data = snapshot.value as Map<dynamic, dynamic>;

                    //update num logs
                    if (data['num_logs'] != null) {
                      statsRef.child('num_logs').set(data['num_logs'] - idsToDelete.length);
                    }
                  }
                  //loop through logs to delete
                  for (var id in idsToDelete) {
                    dbRef.child('GratitudeLogs').child(id).remove();
                  }
                  setState(() {
                    idsToDelete = [];
                  });
                  Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => MyHomePage(startingPageIndex: Globals.group.compareTo('experimental') == 0 ? 4 : 1,)
                    )
                  );
                }, 
                child: Text('Delete All Selected Logs')
              )
            ) : Container()
          ]
        ),
      ),
    );
  }
}