import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gratitude_app/guiding_pages/inspiration_page.dart';
import 'package:gratitude_app/guiding_pages/log_emotions_page.dart';
import  'dart:math';
import 'package:gratitude_app/utilities/globals.dart';
import 'package:gratitude_app/utilities/widgets.dart';


class GuidingPage extends StatefulWidget {
  const GuidingPage({super.key});

  @override
  State<GuidingPage> createState() => _GuidingPageState();
}


class _GuidingPageState extends State<GuidingPage> {

  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(Globals.group)
                                                          .child(FirebaseAuth.instance.currentUser!.uid)
                                                          .child('Advice');
  StreamSubscription<DatabaseEvent>? listener;
  String selectedAdvice = '';

  @override
  void initState() {
    super.initState();
    dbRef.keepSynced(true);

    //choose a random piece of advice
    listener = dbRef.onValue.listen((event) {

      //get list of keys
      DataSnapshot dataSnapshot = event.snapshot;
      if (dataSnapshot.value != null) {
        Map<dynamic, dynamic> values = dataSnapshot.value as Map<dynamic, dynamic>;
        List<dynamic> keys = values.keys.toList();

        //pick random key
        final randomNum = Random().nextInt(values.length);
        dynamic pastLogKey = keys[randomNum];

        //set selectedPastLog to the log at that key
        if (mounted) {
          setState(() {
            selectedAdvice = values[pastLogKey]['advice'];
          });
        }
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
      appBar: AppBar(
        centerTitle: true,
        title: 
          Text('Log Gratitude',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold
            ),
          )
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(height: 30),
            Text("That's okay! Sometimes we have days like that.",
              style: Theme.of(context).textTheme.titleMedium!,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20,),

            //show advice if there is any
            selectedAdvice.isNotEmpty ? 
            Text('Remember, as past you said:\n$selectedAdvice',
              style: Theme.of(context).textTheme.titleMedium!,
              textAlign: TextAlign.center,
            )
            
            : Container(),
            SizedBox(height: 20,),

            Text("How would you like to move forward?",
              style: Theme.of(context).textTheme.titleMedium!,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),  

            //inspiration button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SwitchedColourButton(
                text: 'Give me some inspiration!', 
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InspirationPage())
                  );
                },
              )
            ), 

            //guiding button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SwitchedColourButton(
                text: "I want to work through what's bothering me", 
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LogEmotionsPage())
                  );
                }, 
              )
            ),      

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
        
            //     //generate past logs button
            //     Expanded(
            //       child: Padding(
            //         padding: EdgeInsets.only(left: 8.0, right: 4.0),
            //         child: Align(
            //           alignment: Alignment.center,
            //           child: ElevatedButton(
            //             onPressed: () {
            //               Navigator.push(
            //                 context,
            //                 MaterialPageRoute(builder: (context) => const InspirationPage())
            //               );
            //             },
            //             child: Text("Give me some inspiration!",
            //               textAlign: TextAlign.center,
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
        
            //     //negative emotions walkthrough button
            //     Expanded(
            //       child: Padding(
            //         padding: EdgeInsets.only(left: 4.0, right: 8.0),
            //         child: ElevatedButton(
            //           child: Text("I want to work through what's bothering me",
            //             textAlign: TextAlign.center,
            //           ),
            //           onPressed: () {
            //             Navigator.push(
            //               context,
            //               MaterialPageRoute(builder: (context) => const LogEmotionsPage())
            //             );
            //           }, 
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      )
    );
  }
}
