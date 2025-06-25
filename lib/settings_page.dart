import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gratitude_app/authentication/auth_service.dart';
import 'package:gratitude_app/authentication/login_page.dart';
import 'package:gratitude_app/resources_page.dart';
import 'package:gratitude_app/study_pages/questionnaire_page.dart';
import 'package:gratitude_app/study_pages/withdraw_page.dart';
import 'package:gratitude_app/utilities/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'utilities/date_functions.dart';
import 'utilities/alarm_manager.dart';
import 'package:gratitude_app/utilities/globals.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}


class _SettingsPageState extends State<SettingsPage> {

  bool randomNotifications = true;
  final _formKey = GlobalKey<FormState>();

  //controllers
  TextEditingController randomStartTimeController= TextEditingController();
  TextEditingController randomStartAMPMController = TextEditingController();
  TextEditingController randomEndTimeController = TextEditingController();
  TextEditingController randomEndAMPMController = TextEditingController();
  TextEditingController scheduledTimeController = TextEditingController();
  TextEditingController scheduledAMPMController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getSharedPrefs();
  }

  @override
  void dispose() {
    super.dispose();
    randomStartTimeController.dispose();
    randomStartAMPMController.dispose();
    randomEndTimeController.dispose();
    randomEndAMPMController.dispose();
    scheduledTimeController.dispose();
    scheduledAMPMController.dispose();

    //check if notifs were updated
    checkNotifsUpdated();
  }

  void checkNotifsUpdated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? notifsAllowed = prefs.getBool('notifs_allowed');
    bool? alarmsAllowed = prefs.getBool('alarms_allowed');
    bool notifPermission = await Permission.notification.isGranted;
    bool alarmPermission = await Permission.scheduleExactAlarm.isGranted;
    if (notifPermission && (notifPermission != notifsAllowed || alarmPermission != alarmsAllowed)) {
      print('RESCHEDULING ONESHOT');
      await AndroidAlarmManager.oneShot(
        const Duration(seconds: 5), //schedule 5 seconds later
        0, 
        notificationScheduler,
        rescheduleOnReboot: true,
        allowWhileIdle: true,
        exact: alarmPermission,
        wakeup: true
      );
    }
    prefs.setBool('notifs_allowed', notifPermission);
    prefs.setBool('alarms_allowed', alarmPermission);
  }

  void getSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // bool? ai = prefs.getBool('allow_ai');
    bool ? rand = prefs.getBool('random_notifications');

    //set the defaults for the controllers
      Map<String, String> startTime = twenty4ToAmPm({
        'hours': prefs.getInt('random_start_hours'),
        'minutes': prefs.getInt('random_start_minutes'),
      });
      Map<String, String> endTime = twenty4ToAmPm({
        'hours': prefs.getInt('random_end_hours'),
        'minutes': prefs.getInt('random_end_minutes'),
      });
      Map<String, String> scheduledTime = twenty4ToAmPm({
        'hours': prefs.getInt('scheduled_hours'),
        'minutes': prefs.getInt('scheduled_minutes'),
      });

    //set state
    setState(() {
      // if (ai != null ) allowAI = ai;
      if (rand != null ) randomNotifications = rand;
      randomStartTimeController = TextEditingController(text: startTime['hrs_mins']);
      randomStartAMPMController = TextEditingController(text: startTime['am_pm']);
      randomEndTimeController = TextEditingController(text: endTime['hrs_mins']);
      randomEndAMPMController = TextEditingController(text: endTime['am_pm']);
      scheduledTimeController = TextEditingController(text: scheduledTime['hrs_mins']);
      scheduledAMPMController = TextEditingController(text: scheduledTime['am_pm']);
    });
  }

  Future<Map<String, bool>> getNotifPermissions() async {
    bool notifsAllowed = await Permission.notification.isGranted;
    bool alarmsAllowed = await Permission.scheduleExactAlarm.isGranted;
    return {'notifications': notifsAllowed, 'alarms': alarmsAllowed};
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: 
          Text('Settings',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold
            ),
          ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [

            Text('Notifications',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 10,),

            //check notification permissions
            FutureBuilder(
              future: getNotifPermissions(),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.hasData) {

                  //both notifs and alarms allowed - set scheduled or random
                  if (asyncSnapshot.data!['notifications']!) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text('Random Notifications', textAlign: TextAlign.center),
                                selected: randomNotifications,
                                selectedTileColor: Colors.purple[100],
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.grey, width: 0.5),
                                  borderRadius: BorderRadius.circular(5),
                                ), 
                                onTap: () {
                                  setState(() {
                                    randomNotifications = true;
                                  });
                                }
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Expanded(
                              child: ListTile(
                                title: Text('Scheduled Notifications', textAlign: TextAlign.center),
                                selected: !randomNotifications,
                                selectedTileColor: Colors.purple[100],
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.grey, width: 1),
                                  borderRadius: BorderRadius.circular(5),
                                ), 
                                onTap: () {
                                  setState(() {
                                    randomNotifications = false;
                                  });
                                }
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30,),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: 
                          
                              //random notification settings
                              randomNotifications ? [
                                Text("Set the time intervals when you want to receive a random notification",
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height:20),
                                Row(
                                  children: [
                                    Expanded(child: TimePickerWidget(
                                      timeController: randomStartTimeController,
                                      amPmController: randomStartAMPMController,
                                    )),
                                    Text("     -     "),
                                    Expanded(child: TimePickerWidget(
                                      timeController: randomEndTimeController,
                                      amPmController: randomEndAMPMController,
                                    ))
                                  ],
                                ),
                              ]
                          
                              //scheduled notification settings
                              : [
                                Text("Select the time you wish to receive a notification",
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height:20),
                                TimePickerWidget(
                                  timeController: scheduledTimeController, 
                                  amPmController: scheduledAMPMController
                                )
                              ],
                          ),
                        ),
                        SizedBox(height: 20),
                        
                        //send settings to shared preferences
                        ElevatedButton(
                          child: Text("Update"),
                          onPressed: () async {
                            //check for valid times
                            if (_formKey.currentState!.validate()) {
                        
                              //set up shared preferences
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              Map<String, int> time = {};
                              //random notifications
                              if (randomNotifications) {
                                
                                DateTime rn = DateTime.now();
                                //start time
                                Map<String, int> startTime = amPmTo24(randomStartTimeController.text, randomStartAMPMController.text);
                                DateTime startDT = DateTime(rn.year, rn.month, rn.day, startTime['hours']!, startTime['minutes']!);
                                //end time
                                Map<String, int> endTime = amPmTo24(randomEndTimeController.text, randomEndAMPMController.text);
                                DateTime endDT = DateTime(rn.year, rn.month, rn.day, endTime['hours']!, endTime['minutes']!);
                        
                                //check if second time is after first
                                if (endDT.isAfter(startDT)) {
                                  //if so, update shared preferences
                                  prefs.setInt('random_start_hours', startTime['hours']!);
                                  prefs.setInt('random_start_minutes', startTime['minutes']!);
                                  prefs.setInt('random_end_hours', endTime['hours']!);
                                  prefs.setInt('random_end_minutes', endTime['minutes']!);
                                } else {
                                  //otherwise don't update anything
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please ensure the end time is after the start time.')),
                                  );
                                  return;
                                }
                              } 
                              //scheduled notifications
                              else {
                                time = amPmTo24(scheduledTimeController.text, scheduledAMPMController.text);
                                prefs.setInt('schduled_hours', time['hours']!);
                                prefs.setInt('scheduled_minutes', time['minutes']!);
                              }
                              //set notification style
                              prefs.setBool('random_notifications', randomNotifications);
                        
                              
                              //cancel past alarms to avoid backlog
                              await AndroidAlarmManager.cancel(0) && await AndroidAlarmManager.cancel(1);
                        
                              //immediately schedule a one shot
                              //check for notification permission
                              final notificationPermission = await Permission.notification.status; 
                              final exactAlarmPermission = await Permission.scheduleExactAlarm.status;
                        
                              //schedule the next alarm if notifs allowed
                              if (notificationPermission.isGranted) {
                                await AndroidAlarmManager.oneShot(
                                  const Duration(seconds: 5), //schedule 5 seconds later
                                  0, 
                                  notificationScheduler,
                                  rescheduleOnReboot: true,
                                  allowWhileIdle: true,
                                  exact: exactAlarmPermission.isGranted,
                                  wakeup: true
                                );
                              }
                        
                              //back to previous page
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter a valid time.')),
                              );
                            }
                          },
                        ),

                        //enabled notifs, but not exact alarms
                        !asyncSnapshot.data!['alarms']! ? Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Container(
                            decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: Border.all(
                              width: 0.5,
                              color: Colors.grey
                            ),
                            color: Color.fromARGB(100, 209, 108, 103)
                          ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.error_outline,
                                        color: Color.fromARGB(255, 209, 108, 103),
                                      ),
                                      SizedBox(width: 8,),
                                      Expanded(child: Text('You have disabled exact alarms, which may lead to unpredictable notification behaviour. \nPlease allow Alarms and Reminders for the best experience.')),
                                    ],
                                  ),
                                  ElevatedButton(
                                    style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                                      backgroundColor: WidgetStatePropertyAll<Color>(Color.fromARGB(255, 249, 241, 237)),
                                    ),
                                    onPressed: () => openAppSettings(), 
                                    child: Text('Open Settings',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 209, 108, 103)
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ) : Container()
                      ],
                    );
                  } 

                  //notifs disabled
                  else {
                    return Column(
                      children: [
                        Text('Notifications have been disabled. Please enable notifications and allow Alarms and Reminders to proceed.'),
                        ElevatedButton(
                          onPressed: () => openAppSettings(),
                          child: Text('Open Settings'),
                        )
                      ],
                    );
                  }
                }
                return CircularProgressIndicator();
              }
            ),

            //study information
            SizedBox(height: 50,),
            Text('Study Information',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            InfoButton(
              text: 'Tutorial Video', 
              action: () => launchUrl(Uri.parse('https://youtube.com/shorts/Da3dlMjP1vg?feature=share'))
            ),

            //final questionnaire
            InfoButton(
              text: 'Fill Out Final Happiness Questionnaires',
              action: () => showDialog(
                context: context, 
                builder: (BuildContext context) => Dialog(
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Is the study period over?',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10,),
                        Text('Please only fill out these questionnaires once the study period has concluded!',
                          textAlign: TextAlign.center,
                        ),
                        Text('You will not be able to access the app after you fill out these questionnaires.',
                          textAlign: TextAlign.center,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context), 
                                  child: Text('No, go back', 
                                    textAlign: TextAlign.center,
                                  )
                                ),
                              ),
                            ),

                            //confirm study is over
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => QuestionnairePage(number: 2,))),
                                  child: Text('Yes, continue',
                                    textAlign: TextAlign.center,
                                  )
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                )
              )
            ),

            //resources
            InfoButton(
              text: 'Mental Health Resources', 
              action: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ResourcesPage()))
            ),

            //opt out of study (give them a week after the end date)
            DateTime.now().isBefore(Globals.inTheWildEndDate.add(Duration(days: 7))) ? InfoButton(
              text: 'Withdraw From Study', 
              action: () => showDialog(
                context: context, 
                builder: (BuildContext context) => Dialog(
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Are you sure you would like to withdraw from the study?',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10,),
                        Text('If you choose to withdraw from the study, your account will be deleted and you will no longer be able to use the app.',
                          textAlign: TextAlign.center,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context), 
                                  child: Text('No, go back', 
                                    textAlign: TextAlign.center,
                                  )
                                ),
                              ),
                            ),

                            //confirm opt out
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                                    backgroundColor: WidgetStatePropertyAll<Color>(Color.fromARGB(255, 209, 108, 103)),
                                  ),
                                  onPressed: () async {
                                    //add to withdrawn list
                                    DatabaseReference dbRef = FirebaseDatabase.instance.ref();
                                    dbRef.child('Withdrawn').push().set({
                                      'uid': FirebaseAuth.instance.currentUser!.uid,
                                      'group': Globals.group,
                                      'date': DateTime.now().toIso8601String(),
                                    });
                                    //delete data
                                    dbRef.child(Globals.group).child(FirebaseAuth.instance.currentUser!.uid).remove();
                                    Reference imgRef = FirebaseStorage.instance.ref().child('images').child(FirebaseAuth.instance.currentUser!.uid);
                                    imgRef.delete();
                                    //log out
                                    await AuthService().signout(context: context);
                                    //send to withdraw page and save preferences
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    prefs.setBool('withdraw', true);
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => WithdrawPage()));
                                  }, 
                                  child: Text('Yes, withdraw',
                                    style: TextStyle(
                                      color: Colors.white
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                )
              )
            ) : Container(),

            //licenses
            InfoButton(
              text: 'Licenses',
              action: () => showLicensePage(context: context)
            ),

            //account info
            SizedBox(height: 50,),
            Text('Account',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),

            //convert to permanent account if anon
            FirebaseAuth.instance.currentUser!.isAnonymous ? ElevatedButton(
              onPressed: () => showLoginDialog(
                context: context,
                header: 'Please choose a username and password',
                submitButton: 'Sign Up',
                username: TextEditingController(),
                pw: TextEditingController(),
                onSubmit: (TextEditingController username, TextEditingController pw) {
                  AuthService().anonToCredential(context: context, email: '${username.text}@mail.com', password: pw.text);
                  Navigator.pop(context);
                }
              ),
              child: Text('Convert to Permanent Account')
            ) 
            //otherwise show account info
            : Column(
              children: [
                Text('Username: ${FirebaseAuth.instance.currentUser!.email!.split('@')[0]}'),
                Text('Password: ${'*'*6}')
              ],
            ),

            //log out
            ElevatedButton(
              onPressed: () async {
                await AuthService().signout(context: context);
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (BuildContext context) => const LoginPage()),
                  (route) => false
                );
              }, 
              child: Text('Log Out')
            ),

            //delete account (if in the wild study is over)
            DateTime.now().isAfter(Globals.inTheWildEndDate) ? ElevatedButton(
              onPressed: () {
                //prompt to log in again if they have an account
                if (!FirebaseAuth.instance.currentUser!.isAnonymous) {
                  showLoginDialog(
                    context: context,
                    header: 'Please log in again to confirm your account deletion',
                    submitButton: 'Delete Account',
                    username: TextEditingController(),
                    pw: TextEditingController(),
                    onSubmit: (TextEditingController username, TextEditingController pw) {
                      AuthService().reAuthDelete(context: context, email: '${username.text}@mail.com', password: pw.text);
                    }
                  );
                } 
                //otherwise just delete their data
                else {
                  showDialog(context: context, builder: (context) => Dialog(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Are you sure you would like to delete your account?',
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10,),
                          Text('If you continue, you will be signed out and all your data will be deleted.',
                            textAlign: TextAlign.center,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pop(context), 
                                    child: Text('No, go back', 
                                      textAlign: TextAlign.center,
                                    )
                                  ),
                                ),
                              ),

                              //confirm opt out
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                                      backgroundColor: WidgetStatePropertyAll<Color>(Color.fromARGB(255, 209, 108, 103)),
                                    ),
                                    onPressed: () => AuthService().deleteAccount(context), 
                                    child: Text('Yes, delete account',
                                      style: TextStyle(
                                        color: Colors.white
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      )
                    )
                  ));
                }
              }, 
              style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                backgroundColor: WidgetStatePropertyAll<Color>(Color.fromARGB(255, 209, 108, 103)),
              ),
              child: Text('Delete Account',
                style: TextStyle(
                  color: Colors.white
                ),
              ),
            ) : Container()
          ],
        ),
      )
    );
  }
}


//study info buttons
class InfoButton extends StatelessWidget {
  const InfoButton({super.key, required this.text, required this.action});
  final String text;
  final Function action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary
          ),
        ),
      ),
      onTap: () => action(),
    );
  }
}


//time picker widget
class TimePickerWidget extends StatelessWidget {

  const TimePickerWidget({super.key, required this.timeController, required this.amPmController});

  final TextEditingController timeController;
  final TextEditingController amPmController;

  @override
  Widget build(BuildContext context) {
    
    List<DropdownMenuEntry<dynamic>> amPm = [DropdownMenuEntry(value: "AM", label: "AM"), DropdownMenuEntry(value: "PM", label: "PM")];

    return Row(
      children: [
        //time picker
        Expanded(
          child: TextFormField(
            controller: timeController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              TimeInputFormatter()
            ],
            //ensure valid time
            validator: (value) {
              RegExp exp = RegExp(r'^(0?[1-9]|1[012]):[0-5][0-9]$');
              if (value == null || value.isEmpty || !exp.hasMatch(value)) {
                return('Invalid time');
              }
              return null;
            },
          ),
        ),
        SizedBox(width: 8),
        DropdownMenu(
          controller: amPmController,
          initialSelection: amPmController.text,
          requestFocusOnTap: true,
          dropdownMenuEntries: amPm,
          enableFilter: true,
          width: 100,
        ),
      ]
    );
  }
}


//custom text input formatter + validator
class TimeInputFormatter extends TextInputFormatter {

  String mask = '##:##';

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    int oldlen = oldValue.text.length;
    int newlen = newValue.text.length;

    if (newlen > 0) {

      //typing more
      if (newlen > oldlen) {
        if (newlen == 1) {
          //add colon
          return TextEditingValue(
            text: '${newValue.text}:',
            selection: TextSelection.collapsed(
              offset: newValue.selection.end + 1
            )
          );
        } else if (newlen == 5) {
          //move colon
          return TextEditingValue(
            text: '${oldValue.text.substring(0,1)}${oldValue.text.substring(2,3)}:${newValue.text.substring(newlen-2)}'
          );
        } else if (newlen > mask.length) {
          return oldValue;
        }
      }

      //backspacing
      else {
        if (oldlen == 5 && newlen == 4) {
          //move colon
          return TextEditingValue(
            text: '${newValue.text.substring(0,1)}:${newValue.text.substring(1,2)}${newValue.text.substring(3,4)}'
          );
        } else if (oldlen == 2 && newlen == 1) {
          //automatically remove colon
          return TextEditingValue(
            text: '',
            selection: TextSelection.collapsed(
              offset: newValue.selection.end - 1
            )
          );
        }
      }
    }
    
    return newValue;
  }
}