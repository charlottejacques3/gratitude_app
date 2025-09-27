import 'package:flutter/material.dart';
import 'package:gratitude_app/logs_model.dart';
import 'package:gratitude_app/select_method_page.dart';
import 'package:gratitude_app/utilities/widgets.dart';
import 'package:provider/provider.dart';


class InitialMoodPage extends StatefulWidget {
  const InitialMoodPage({super.key});

  @override
  State<InitialMoodPage> createState() => _InitialMoodPageState();
}

class _InitialMoodPageState extends State<InitialMoodPage> {

  // DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(Globals.group)
  //                                                         .child(FirebaseAuth.instance.currentUser!.uid);
  int selectedMood = 0;

  @override
  void initState() {
    super.initState();
  }

  

  void selectMood(int moodNum) {
    setState(() {
      selectedMood = moodNum;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(248, 227, 196, 225),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(0, 188, 143, 186),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SizedBox(height: 50,),
            Text('Welcome back! \n\nHow are you feeling today?',
              style: Theme.of(context).textTheme.titleLarge!,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50,),
            Row(
              children: [
                MoodButton(moodNum: 1, icon: Icons.sentiment_very_dissatisfied, onClick: () => selectMood(1), selectedMood: selectedMood, iconColour: Color.fromARGB(255, 250, 100, 100), initial: true,),
                MoodButton(moodNum: 2, icon: Icons.sentiment_dissatisfied, onClick: () => selectMood(2), selectedMood: selectedMood, iconColour: Color.fromARGB(255, 250, 142, 100), initial: true,),
                MoodButton(moodNum: 3, icon: Icons.sentiment_neutral, onClick: () => selectMood(3), selectedMood: selectedMood, iconColour: Color.fromARGB(255, 233, 189, 45), initial: true,),
                MoodButton(moodNum: 4, icon: Icons.sentiment_satisfied_alt, onClick: () => selectMood(4), selectedMood: selectedMood, iconColour: Color.fromARGB(255, 152, 201, 97), initial: true,),
                MoodButton(moodNum: 5, icon: Icons.sentiment_very_satisfied_rounded, onClick: () => selectMood(5), selectedMood: selectedMood, iconColour: Color.fromARGB(255, 105, 182, 159), initial: true,),
              ],
            ),
            SizedBox(height: 50,),
            SwitchedColourButton(
              text: 'Next', 
              onClick: () {
                // Map<String, dynamic> mood = {
                //   'mood': selectedMood,
                //   'date': DateTime.now().toIso8601String()
                // };
                // try {
                //   dbRef.child('InitMoods').push().set(mood);
                // } catch (e) {
                //   print('error writing mood to database: $e');
                // }
                Provider.of<LogsModel>(context, listen: false).setSessionMood(selectedMood);
                Navigator.push(context, MaterialPageRoute(builder: (context) => SelectMethodPage()));
              }
            ),
          ],
        ),
      )
    );
  }
}