import 'package:flutter/material.dart';
import 'package:gratitude_app/init_mood_page.dart';
import 'package:gratitude_app/main.dart';
import 'package:gratitude_app/utilities/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';


class StudyCompletePage extends StatefulWidget {
  const StudyCompletePage({super.key});

  @override
  State<StudyCompletePage> createState() => _StudyCompletePageState();
}

class _StudyCompletePageState extends State<StudyCompletePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Thank you for participating in the study!',
              style: Theme.of(context).textTheme.titleLarge!,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30,),
            Text('We appreciate your time, and your data and input is valuable.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20,),
            Text('Please sign up for an interview (details will be provided in an email) if you have not already!',
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              child: Text('Back to main app'),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('study_complete', false);
                prefs.setBool('final_questionnaires_started', false);
                Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (BuildContext context) {
                    if (Globals.group.compareTo('experimental') == 0) {
                      return InitialMoodPage();
                    } else {
                      return MyHomePage(startingPageIndex: 0);
                    }
                  })
                );
              },
            )
          ]
        ),
      )
    );
  }
}