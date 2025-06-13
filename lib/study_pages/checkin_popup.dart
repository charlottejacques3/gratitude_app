import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gratitude_app/authentication/auth_service.dart';
import 'package:gratitude_app/resources_page.dart';
import 'package:gratitude_app/study_pages/withdraw_page.dart';
import 'package:gratitude_app/utilities/globals.dart';
import 'package:gratitude_app/utilities/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CheckinPopup extends StatefulWidget {
  const CheckinPopup({super.key});

  @override
  State<CheckinPopup> createState() => _CheckinPopupState();
}

class _CheckinPopupState extends State<CheckinPopup> {

  bool crisis = false;
  bool additionalDistress = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Color.fromARGB(255, 250, 240, 230),
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Before we get started, just a quick check-in...',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold
              ),
            ),
            YesNoRadio(
              label: 'Are you currently in crisis or experiencing extreme distress?',
              radioSelected: crisis, 
              onChanged: (bool newValue) {
                setState(() {
                  crisis = newValue;
                });
              }
            ),
            YesNoRadio(
              label: 'Is this app negatively affecting your wellbeing in any way?',
              radioSelected: additionalDistress, 
              onChanged: (bool newValue) {
                setState(() {
                  additionalDistress = newValue;
                });
              }
            ),
            Text('You are free to withdraw from this study at any point.'),
            SwitchedColourButton(
              text: 'Continue', 
              onClick: () {
                if (!crisis && !additionalDistress) {
                  Navigator.pop(context);
                } 

                //crisis handling
                else if (crisis) {
                  showDialog(
                    context: context, 
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: ListView(
                            children: [
                              Text('We are sorry to hear that you are experiencing extreme levels of distress. \n\nHowever, this app is not intended to be a clinical psychological intervention. As such, upon your confirmation we will be removing you from the study and we ask that you stop using this app. \n\nWe encourage you to reach out to a professional or emergency services, or consult the resources on the next page. \n\nWe appreciate the time you have put into this study, and you will receive an email from us within a day with instructions on how to access your compensation.',
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 15,),
                              SwitchedColourButton(
                                onClick: () {
                                  Navigator.pop(context);
                                }, 
                                text: 'No, go back'
                              ),
                              SwitchedColourButton(
                                onClick: () async {
                                  //save this to db
                                  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('WithdrawnInCrisis');
                                  dbRef.push().set({
                                    'uid': FirebaseAuth.instance.currentUser!.uid,
                                    'group': Globals.group,
                                    'date': DateTime.now().toIso8601String(),
                                  });
                                  //set preferences
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  prefs.setBool('withdraw_in_crisis', true);
                                  await AuthService().signout(context: context); //log out
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ResourcesPage(withdrawn: true,)));
                                }, 
                                text: 'Continue to resources'
                              ),
                            ],
                          )
                        ),
                      );
                    }
                  );
                }

                //making them feel worse
                else {
                  showDialog(
                    context: context, 
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              Text('We are sorry to hear that this app is negatively affecting your wellbeing. \n\nAs this is in no way the intention of this app or study, we would like to remind you that you are free to withdraw from the study or stop using the app at any time.',
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 15,),
                              SwitchedColourButton(
                                onClick: () {
                                  Navigator.pop(context);
                                }, 
                                text: 'No, go back'
                              ),
                              ElevatedButton(
                                style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                                  backgroundColor: WidgetStatePropertyAll<Color>(Color.fromARGB(255, 209, 108, 103)),
                                ),
                                onPressed: () async {
                                  //save this to db
                                  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('WithdrawnFeelingWorse');
                                  dbRef.push().set({
                                    'uid': FirebaseAuth.instance.currentUser!.uid,
                                    'group': Globals.group,
                                    'date': DateTime.now().toIso8601String(),
                                  });
                                  //set preferences
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  prefs.setBool('withdraw', true);
                                  await AuthService().signout(context: context); //log out
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WithdrawPage()));
                                }, 
                                child: Text('Yes, withdraw',
                                  style: TextStyle(
                                    color: Colors.white
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              ),
                            ],
                          )
                        ),
                      );
                    }
                  );
                }
              }
            )
          ],
        ),
      ),
    );
  }
}