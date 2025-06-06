import 'package:flutter/material.dart';
import 'package:gratitude_app/main.dart';
import 'package:gratitude_app/select_method_page.dart';
import 'package:gratitude_app/study_pages/questionnaire_page.dart';
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
              child: Text('Control condition'),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('group', 'control');
                Globals.group = prefs.getString('group')!;
                prefs.setBool('study_complete', false);
                prefs.setBool('initial_questionnaires_complete', false);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => QuestionnairePage(number:1)));
              },
            )
          ]
        ),
      )
    );
  }
}