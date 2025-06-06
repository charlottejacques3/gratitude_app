import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gratitude_app/guiding_pages/log_emotions_page.dart';
import  'dart:math';
import 'package:gratitude_app/utilities/globals.dart';
import 'package:gratitude_app/utilities/widgets.dart';


class MainReframingPage extends StatefulWidget {
  const MainReframingPage({super.key});

  @override
  State<MainReframingPage> createState() => _MainReframingPageState();
}


class _MainReframingPageState extends State<MainReframingPage> {

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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            SizedBox(height: 30),
            Text("To fully reap the benefits of gratitude, it can help to reframe your negative emotions.",
              style: Theme.of(context).textTheme.titleMedium!,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20,),

            //show advice if there is any
            selectedAdvice.isNotEmpty ? 
            Column(
              children: [
                Text('Remember, as past you said:',
                  style: Theme.of(context).textTheme.titleMedium!,
                  textAlign: TextAlign.center,
                ),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Container(
                      width: constraints.maxWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        border: Border.all(
                          width: 0.5,
                          color: Colors.grey
                        )
                      ),
                      child: Text(selectedAdvice,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                )
              ],
            ) : Container(),
            SizedBox(height: 20,),  

            //start button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SwitchedColourButton(
                text: 'Get Started', 
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LogEmotionsPage())
                  );
                },
              )
            ),     
          ],
        ),
      )
    );
  }
}
