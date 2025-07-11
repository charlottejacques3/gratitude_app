import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gratitude_app/main.dart';
import 'package:gratitude_app/study_pages/tutorial_page.dart';
import 'package:gratitude_app/utilities/globals.dart';
import 'package:gratitude_app/utilities/widgets.dart';
import 'package:url_launcher/url_launcher.dart';


class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Welcome to the study!',
              style: Theme.of(context).textTheme.titleLarge!,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40,),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyLarge,
                children: [
                  TextSpan(
                    text: 'You have been randomly assigned to the '
                  ),
                  TextSpan(
                    text: Globals.group,
                    style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  TextSpan(
                    text: ' group.'
                  )
                ]
              )
            ),
            SizedBox(height: 30,),

            //experimental text
            Globals.group.compareTo('experimental') == 0 ? 
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyLarge,
                children: [
                  TextSpan(
                    text: 'This means that your version of the app will have '
                  ),
                  TextSpan(
                    text: 'additional features to help promote gratitude.',
                    style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  TextSpan(
                    text: '\n\nPlease use these features if they would be helpful to you!'
                  ),
                  TextSpan(
                    text: '\n\nIf you have forgotten how to use the app, see this '
                  ),
                  TextSpan(
                    text: 'tutorial video.',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.underline
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {
                      launchUrl(Uri.parse('https://youtube.com/shorts/jkGra8y_SuE?feature=share'));
                    },
                  )
                ]
              )
            ) : 
            
            //control text
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyLarge,
                children: [
                  TextSpan(
                    text: 'This means that you will have a '
                  ),
                  TextSpan(
                    text: 'simplified version of the app',
                    style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  TextSpan(
                    text: ', which only contains a gratitude log and no other features.'
                  ),
                  TextSpan(
                    text: '\n\nIf you have forgotten how to use the app, see this '
                  ),
                  TextSpan(
                    text: 'tutorial video.',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.underline
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {
                      launchUrl(Uri.parse('https://youtube.com/shorts/NupumZYB_VE?feature=share'));
                    },
                  ),
                  TextSpan(
                    text: '\n\nPlease remember to log at least one gratitude in the app every day for the 7-day period!',
                    style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                ]
              ),
            ),

            SizedBox(height: 30,),
            SwitchedColourButton(
              onClick: () {
                Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (BuildContext context) {
                    if (Globals.group.compareTo('experimental') == 0) {
                      return TutorialPage();
                    } else {
                      return MyHomePage(startingPageIndex: 0);
                    }
                  })
                );
              }, 
              text: 'Continue'
            )
          ]
        ),
      )
    );
  }
}