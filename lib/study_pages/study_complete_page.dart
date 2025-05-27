import 'package:flutter/material.dart';


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
            )
          ]
        ),
      )
    );
  }
}