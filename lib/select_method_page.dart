import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gratitude_app/main.dart';
import 'package:gratitude_app/utilities/globals.dart';


class SelectMethodPage extends StatefulWidget {
  const SelectMethodPage({super.key});

  @override
  State<SelectMethodPage> createState() => _SelectMethodPageState();
}

class _SelectMethodPageState extends State<SelectMethodPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(248, 227, 196, 225),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(0, 188, 143, 186),
        actions: [
          Padding(
            padding: EdgeInsetsGeometry.all(8),
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage(startingPageIndex: 0))),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SizedBox(height: 50,),
            Text('How are you feeling today?',
              style: Theme.of(context).textTheme.titleLarge!,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50,),
            NavigatorButton(
              pageIndex: 0, 
              text: "I'm feeling good! I can think of things to be grateful for."
            ),
            NavigatorButton(
              pageIndex: 1, 
              text: "I'm feeling okay, but I could use a little inspiration."
            ),
            NavigatorButton(
              pageIndex: 2, 
              text: "I'm not feeling too good. I need to work through my negative emotions."
            ),
            NavigatorButton(
              pageIndex: 3, 
              text: "I'm feeling introspective! I'd like to do a deeper gratitude reflection."
            ),
          ],
        ),
      )
    );
  }
}


class NavigatorButton extends StatelessWidget {
  const NavigatorButton({super.key, required this.pageIndex, required this.text});

  final int pageIndex;
  final String text;

  @override
  Widget build(BuildContext context) {
    
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(Globals.group)
                                                            .child(FirebaseAuth.instance.currentUser!.uid)
                                                            .child('Stats');
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton(
        child: Text(text,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        onPressed: () async {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage(startingPageIndex: pageIndex)));

          //convert page index to page name
          String pageName;
          switch(pageIndex) {
            case 0:
              pageName = 'gratitude_log';
            case 1:
              pageName = 'inspiration';
            case 2:
              pageName = 'reframing';
            case 3:
              pageName = 'reflection';
            default:
              pageName = 'gratitude_log';
          }
          
          //update stats
          final snapshot = await dbRef.get();
          Map<dynamic, dynamic> dict;
          if (snapshot.exists) {
            Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
            if (data['selected_page'] != null) {
              dict = data['selected_page'];
            } else {
              dict = {
                'gratitude_log': 0,
                'inspiration': 0,
                'reframing': 0,
                'reflection': 0
              };
            }
          } else {
            dict = {
              'gratitude_log': 0,
              'inspiration': 0,
              'reframing': 0,
              'reflection': 0
            };
          }
          dict[pageName] = dict[pageName]! + 1;
          dbRef.update({'selected_page': dict});
        }
      ),
    );
  }

}