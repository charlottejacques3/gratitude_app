import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gratitude_app/utilities/helper_functions.dart';
import 'package:gratitude_app/reflection_pages/new_reflection.dart';

import 'reflection_detail_page.dart';

class ReflectionPage extends StatefulWidget {
  const ReflectionPage({super.key});

  @override
  State<ReflectionPage> createState() => _ReflectionPageState();
}


class _ReflectionPageState extends State<ReflectionPage> {

  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('users')
                                                          .child(FirebaseAuth.instance.currentUser!.uid)
                                                          .child('Reflections');
  List<Map<dynamic, dynamic>> pastReflections = [];
  bool loading = true;

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

    dbRef.onValue.listen((event) {
      //re-inialize past reflections to empty
      pastReflections = [];

      DataSnapshot dataSnapshot = event.snapshot;
      if (dataSnapshot.value != null) {
        Map<dynamic, dynamic> values = dataSnapshot.value as Map<dynamic, dynamic>;

        values.forEach((key, value) {
          
          // add to past reflections
          if (mounted) {
            //format date
            value['format_date'] = formatDate(value['date']);
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
        loading //display progress indicator while loading
          ? Center(child: CircularProgressIndicator())
      : ListView(
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
              return ElevatedButton(
                child: Text('New Reflection'),
                onPressed: () {
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
                onPressed: () => newReflection('challenges')
              ),
              MenuItemButton(
                child: Text('Gratitude Letter'),
                onPressed: () => newReflection('letter')
              ),
              MenuItemButton(
                child: Text('Reflect on the Little Things'),
                onPressed: () => newReflection('little_things')
              ),
              MenuItemButton(
                child: Text('Independent Reflection'),
                onPressed: () => newReflection('independent')
              ),
            ],
          ),

          //past reflections
          pastReflections.isEmpty ?
          Column(
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
          )
          : ListView.builder(
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

                //navigate to the page for that reflection
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReflectionDetailPage(details:current))
                  );
                },
              );
            }
          ),
        ],
      ),
    );
  }
}
