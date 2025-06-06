import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gratitude_app/main.dart';
import 'package:gratitude_app/utilities/date_functions.dart';
import 'package:gratitude_app/reflection_pages/new_reflection.dart';
import 'package:gratitude_app/utilities/widgets.dart';
import 'reflection_detail_page.dart';
import 'package:gratitude_app/utilities/globals.dart';

class ReflectionPage extends StatefulWidget {
  final bool editMode; 

  const ReflectionPage({super.key, required this.editMode});

  @override
  State<ReflectionPage> createState() => _ReflectionPageState();
}


class _ReflectionPageState extends State<ReflectionPage> {

  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(Globals.group)
                                                          .child(FirebaseAuth.instance.currentUser!.uid)
                                                          .child('Reflections');
  StreamSubscription<DatabaseEvent>? listener;
  List<Map<dynamic, dynamic>> pastReflections = [];
  bool loading = true;
  List<dynamic> idsToDelete = [];

  void newReflection(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewReflectionPage(type:type))
    );
  }

  //read past reflections from the database
  @override
  void initState() {
    super.initState();
    dbRef.keepSynced(true);

    listener = dbRef.onValue.listen((event) {
      //re-inialize past reflections to empty
      pastReflections = [];

      DataSnapshot dataSnapshot = event.snapshot;
      if (dataSnapshot.value != null) {
        Map<dynamic, dynamic> values = dataSnapshot.value as Map<dynamic, dynamic>;

        values.forEach((key, value) {
          
          // add to past reflections
          if (mounted) {
            value['id'] = key; //key for edit/delete
            value['format_date'] = formatDate(value['date']); //format date
            setState(() {
              pastReflections.add(value);
            });
          }

          //sort by date (most recent first)
          setState(() {
            pastReflections.sort((a, b) => b['date'].compareTo(a['date']));
          });
        });
      }
    });

    //done loading
    setState(() {
      loading = false;
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
        loading //display progress indicator while loading
          ? Center(child: CircularProgressIndicator())
      : Stack(
        children: [
          ListView(
            children: [
          
              //add new reflection button 
              MenuAnchor(
                style: MenuStyle(
                  backgroundColor: WidgetStateColor.resolveWith(
                    (Set<WidgetState> states) {
                      return Color.fromARGB(255, 249, 241, 237);
                    }
                  )
                ),
                builder: (BuildContext context, MenuController controller, Widget? child) {
                  return SwitchedColourButton(
                    text: 'New Reflection',
                    onClick: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    }, 
                  );
                },
                //dropdown options
                menuChildren: <MenuItemButton>[
                  MenuItemButton(
                    child: Text('Reflect on Challenges'),
                    onPressed: () => newReflection('Reflect on Challenges')
                  ),
                  MenuItemButton(
                    child: Text('Gratitude Letter'),
                    onPressed: () => newReflection('Gratitude Letter')
                  ),
                  MenuItemButton(
                    child: Text('Reflect on the Little Things'),
                    onPressed: () => newReflection('Reflect on the Little Things')
                  ),
                  MenuItemButton(
                    child: Text('Independent Reflection'),
                    onPressed: () => newReflection('Independent Reflection')
                  ),
                ],
              ),
          
              //past reflections
              if (pastReflections.isEmpty) Column(
                children: [
                  SizedBox(height: 30,),
                  Text(
                    'No reflections yet!',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ) else ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: pastReflections.length,
                itemBuilder: (context, index) {
                  var current = pastReflections[index];
                  return ListTile(
                    title: Text(current['type']),
                    subtitle: Text(current['format_date']),
                    trailing: Icon(Icons.arrow_forward_ios),
                    //checkbox for edit mode
                    leading: widget.editMode ? Checkbox(
                      shape: CircleBorder(),
                      value: idsToDelete.contains(current['id']), 
                      onChanged: (isSelected) {
                        if (isSelected == true) {
                        setState(() {
                          idsToDelete.add(current['id']); //if just selected, add to list
                        });
                      } else {
                        setState(() {
                          idsToDelete.remove(current['id']); //if just unselected, remove from list
                        });
                      }
                      }
                    ) : Container(width: 0,),
                    contentPadding: widget.editMode ? EdgeInsets.only(left:0) : EdgeInsets.only(left:10),
                    visualDensity: VisualDensity(horizontal:VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
                    minLeadingWidth: 0,
          
                    //navigate to the page for that reflection
                    onTap: () {
                      if (!widget.editMode) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ReflectionDetailPage(details:current))
                        );
                      } else {
                        if (idsToDelete.contains(current['id'])) {
                          setState(() {
                            idsToDelete.remove(current['id']);
                          });
                        } else {
                          setState(() {
                            idsToDelete.add(current['id']);
                          });
                        }
                      }
                    },
                  );
                }
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
                      builder: (BuildContext context) => MyHomePage(startingPageIndex: Globals.group.compareTo('experimental') == 0 ? 3 : 2,)
                    )
                  );
                }, 
                child: Text('Delete All Selected Reflections')
              )
            ) : Container()
        ],
      ),
    );
  }
}
