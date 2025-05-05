import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gratitude_app/main.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'utilities/date_functions.dart';

class PastLogsPage extends StatefulWidget {
  final bool editMode;

  const PastLogsPage({super.key, required this.editMode});

  @override
  State<PastLogsPage> createState() => _PastLogsPageState();
}


class _PastLogsPageState extends State<PastLogsPage> {

  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('users')
                                                          .child(FirebaseAuth.instance.currentUser!.uid)
                                                          .child('GratitudeLogs');
  List<Map<dynamic, dynamic>> gratitudeLogs = [];
  Map<String, List<Map<String, String>>> categorizedLogs = {};
  bool loading = true;
  List<dynamic> idsToDelete = [];
  bool connected = false;
  bool checkingInternet = true;

  @override
  void initState() {
    super.initState();
    dbRef.keepSynced(true);
    
    dbRef.onValue.listen((event) async {
      //re-initialize gratitudeLogs to empty
      gratitudeLogs = [];

      DataSnapshot dataSnapshot = event.snapshot;
      if (dataSnapshot.value != null) {
        Map<dynamic, dynamic> values = dataSnapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          
          // add to gratitude logs + sort
          if (mounted) {
            try {
              setState(() {
                Map<dynamic, dynamic> entry = value;
                entry['id'] = key;
                gratitudeLogs.add(entry);
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
          String formatted = formatDate(item['date']);
          item['date'] = formatted;

          //so it will give the no internet notice
          bool connection = true;
          if (item['type'].compareTo('image') == 0) {
            connection = await checkInternetConnection();
          }

          //don't add images if no internet
          // if (connection && item['type'].compareTo('image') != 0) {
            Map<String, String> data = {
            'log': item['gratitude_item'],
            'type': item['type'],
            'id': item['id']
          };

          if (mounted) {
            setState(() {
              if (categorizedLogs.containsKey(formatted)) {
                categorizedLogs[formatted]!.add(data);
              } else {
                categorizedLogs[formatted] = [data];
              }
            });
          // }
          }
          
        }
      }
    });
  }

  Future<bool> checkInternetConnection() async {
    bool conn = await InternetConnection().hasInternetAccess;
    if (!conn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please connect to the internet to view image logs')),
      );
    }
    return conn;
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
                      List<Map<String, String>> lst = categorizedLogs.values.elementAt(categorizedLogs.length - 1 - parentIndex);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          //display date
                          Text(categorizedLogs.keys.elementAt(categorizedLogs.length - 1 - parentIndex),
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            )
                          ),
                          SizedBox(height: 5,),
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
                                                      child: Center(child: CircularProgressIndicator())
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
                      );
                    },
                    childCount: categorizedLogs.length, // number of parent items
                  ),
                ),
              ],
            ),

            //delete logs button
            widget.editMode ?
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: ElevatedButton(
                  onPressed: () {
                    //loop through logs to delete
                    for (var id in idsToDelete) {
                      dbRef.child(id).remove();
                      
                    }
                    setState(() {
                      idsToDelete = [];
                    });
                    Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => MyHomePage(startingPageIndex: 1,)
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