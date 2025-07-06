import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gratitude_app/logs_model.dart';
import 'package:gratitude_app/utilities/globals.dart';
import 'package:gratitude_app/utilities/widgets.dart';
import 'package:provider/provider.dart';


class CongratsPage extends StatefulWidget {
  const CongratsPage({super.key, required this.reframed, required this.dateAdded});

  final bool reframed;
  final String dateAdded;

  @override
  State<CongratsPage> createState() => _CongratsPageState();
}

//where it goes after submitting logs
class _CongratsPageState extends State<CongratsPage> {

  TextEditingController adviceController = TextEditingController();
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(Globals.group)
                                                          .child(FirebaseAuth.instance.currentUser!.uid);
  int selectedMood = 0;

  void selectMood(int moodNum) {
    setState(() {
      selectedMood = moodNum;
    });
  }

  @override
  void dispose() {
    super.dispose();
    adviceController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            
            //experimental group
            Globals.group.compareTo('experimental') == 0 ? Column(
              children: [
                Text('Good work!',
                  style: Theme.of(context).textTheme.headlineLarge!,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 50,
                ),
        
                //log mood
                Text('After completing this gratitude activity, how do you feel today?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge!,
                ),
                Row(
                  children: [
                    MoodButton(moodNum: 1, icon: Icons.sentiment_very_dissatisfied, onClick: () => selectMood(1), selectedMood: selectedMood, iconColour: Color.fromARGB(255, 250, 100, 100)),
                    MoodButton(moodNum: 2, icon: Icons.sentiment_dissatisfied, onClick: () => selectMood(2), selectedMood: selectedMood, iconColour: Color.fromARGB(255, 250, 142, 100)),
                    MoodButton(moodNum: 3, icon: Icons.sentiment_neutral, onClick: () => selectMood(3), selectedMood: selectedMood, iconColour: Color.fromARGB(255, 214, 185, 87)),
                    MoodButton(moodNum: 4, icon: Icons.sentiment_satisfied_alt, onClick: () => selectMood(4), selectedMood: selectedMood, iconColour: Color.fromARGB(255, 152, 201, 97)),
                    MoodButton(moodNum: 5, icon: Icons.sentiment_very_satisfied_rounded, onClick: () => selectMood(5), selectedMood: selectedMood, iconColour: Color.fromARGB(255, 105, 182, 159)),
                  ],
                ),
                SizedBox(height: 50,),

                widget.reframed ?
                  //if reframed, give specific dialog
                  Text('Good job working through your negative emotions!\n\nHaving gone through this experience, is there any advice you would leave for your future self the next time you experience negative feelings like this?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge!,
                  ) : Text('Do you have any advice you would like to leave for your future self?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge!,
                  ),
                  SizedBox(height: 10,),
                  TextFormField(
                    controller: adviceController,
                    keyboardType: TextInputType.multiline,
                    minLines: 3,
                    maxLines: 15,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 30,),
              

                //send advice/moods to database
                SwitchedColourButton(
                  onClick: () async {

                    //send advice
                    if (adviceController.text.isNotEmpty) {
                      Map<String, dynamic> advice = {
                        'advice': adviceController.text,
                        'date': DateTime.now().toIso8601String()
                      };
                      try {
                        if (widget.reframed) {
                          dbRef.child('NegativeAdvice').push().set(advice);
                        } else {
                          dbRef.child('Advice').push().set(advice);
                        }
                      } catch (e) {
                        print('error writing advice to database: $e');
                      }
                    }

                    //send moods
                    Map<String, dynamic> mood = {
                      'date': widget.dateAdded
                    };
                    if (selectedMood != 0) {
                      mood['final_mood'] = selectedMood;
                    }
                    int initMood = Provider.of<LogsModel>(context, listen:false).sessionMood;
                    if (initMood != 0) {
                      mood['initial_mood'] = initMood;
                    }
                    try {
                      dbRef.child('Moods').push().set(mood);
                    } catch (e) {
                      print('error writing mood to database: $e');
                    }
                    Navigator.pop(context);
                  },
                  text: 'Save'
                ),
              ]
            ) 
            
            //control group
            : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(height: 100,),
                Text('Good work!',
                  style: Theme.of(context).textTheme.headlineLarge!,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        )
      )
    );
  }
}