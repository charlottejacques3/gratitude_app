import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gratitude_app/authentication/login_page.dart';
import 'package:gratitude_app/init_mood_page.dart';
import 'package:gratitude_app/main.dart';
import 'package:gratitude_app/resources_page.dart';
import 'package:gratitude_app/study_pages/consent_form_page.dart';
import 'package:gratitude_app/study_pages/study_complete_page.dart';
import 'package:gratitude_app/study_pages/demographics_page.dart';
import 'package:gratitude_app/study_pages/questionnaire_page.dart';
import 'package:gratitude_app/study_pages/withdraw_page.dart';
import 'package:gratitude_app/utilities/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ParticipantGate extends StatefulWidget {
  const ParticipantGate({super.key});

  @override
  State<ParticipantGate> createState() => _ParticipantGateState();
}

class _ParticipantGateState extends State<ParticipantGate> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            //check for error
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '${snapshot.error} occurred',
                  style: TextStyle(fontSize: 18),
                ),
              );

              //future has complete, got data
            } else if (snapshot.hasData) {

              //check if withdrawn from study
              bool? withdraw = snapshot.data!.getBool('withdraw');
              if (withdraw == null || !withdraw) {

                //check if completed consent form, demographics, questionnaires - CONSENT ONLY FOR IN THE WILD!
                // bool? consent = snapshot.data!.getBool('consent_complete');
                bool? demographics = snapshot.data!.getBool('demographics_complete');
                bool? questionnaire1 = snapshot.data!.getBool('initial_questionnaires_complete');
                bool? questionnaire2 = snapshot.data!.getBool('final_questionnaires_started');
                bool? studyComplete = snapshot.data!.getBool('study_complete');
                bool? withdrawInCrisis = snapshot.data!.getBool('withdraw_in_crisis');
                // if (consent != null && !consent) {
                //   return ConsentFormPage();
                // } 
                if (studyComplete != null && studyComplete) {
                  return StudyCompletePage();
                }
                else if (withdrawInCrisis != null && withdrawInCrisis) {
                  return ResourcesPage(withdrawn: true,);
                }
                else if (demographics != null && !demographics) {
                  return DemographicsPage();
                }
                else if (questionnaire1 != null && !questionnaire1) {
                  return QuestionnairePage(number: 1,);
                } 
                else if (questionnaire2 != null && questionnaire2) {
                  return QuestionnairePage(number: 2);
                }
                else {
                  if (FirebaseAuth.instance.currentUser == null) {
                    return LoginPage();
                  } else if (Globals.group.compareTo('experimental') == 0) {
                    return InitialMoodPage();
                  }
                  return MyHomePage(startingPageIndex: 0,);
                }
              } else {
                return WithdrawPage();
              }
            }
          } 
          return CircularProgressIndicator();
        },
        future: SharedPreferences.getInstance()
      )
    );
  }
}

//where you are brought upon opening the app, decides whether to go to login or home page 
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        //check whether still study participant
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        if (!snapshot.hasData) {
          return LoginPage();
        } else if (Globals.group.compareTo('experimental') == 0) {
          return InitialMoodPage();
        }
        return MyHomePage(startingPageIndex: 0,);
      },
    );
  }
}