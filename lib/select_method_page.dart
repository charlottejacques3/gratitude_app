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
            Text('Welcome back! \n\nHow would you like to practice gratitude today?',
              style: Theme.of(context).textTheme.titleLarge!,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30,),
            NavigatorButton(
              pageIndex: 0, 
              text: "I can think of something to log - I'd like to go straight to the gratitude list!",
              icon: Icons.edit,
              iconLabel: 'Log',
            ),
            NavigatorButton(
              pageIndex: 1, 
              text: "Give me some inspiration of things to be grateful for.",
              icon: Icons.lightbulb,
              iconLabel: 'Ideas',
            ),
            NavigatorButton(
              pageIndex: 2, 
              text: "I have some negative emotions I'd like to work through before practicing gratitude.",
              icon: Icons.psychology,
              iconLabel: 'Reframe',
            ),
            NavigatorButton(
              pageIndex: 3, 
              text: "I'd like to do some deeper gratitude reflection activities.",
              icon: Icons.spa,
              iconLabel: 'Activities',
            ),
          ],
        ),
      )
    );
  }
}


class NavigatorButton extends StatelessWidget {
  const NavigatorButton({super.key, required this.pageIndex, required this.text, required this.icon, required this.iconLabel});

  final int pageIndex;
  final String text;
  final IconData icon;
  final String iconLabel;

  @override
  Widget build(BuildContext context) {
    
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(Globals.group)
                                                            .child(FirebaseAuth.instance.currentUser!.uid)
                                                            .child('Stats');

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton(
        child: Padding(
          padding: const EdgeInsets.only(top:8.0, bottom: 8, right:8),
          child: Row(
            children: [
              Container(
                height: 45,
                width: 55,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(icon),
                    Text(iconLabel,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    )
                  ],
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: Text(text,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
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