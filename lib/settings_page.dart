  import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
  import 'package:flutter/services.dart';

  //import files
  import 'utilities/helper_functions.dart';
  import 'utilities/alarm_manager.dart';
  import 'authentication/auth_service.dart';

  //database imports
  import 'package:firebase_database/firebase_database.dart';


  class SettingsPage extends StatefulWidget {
    const SettingsPage({super.key});

    @override
    State<SettingsPage> createState() => _SettingsPageState();
  }


  class _SettingsPageState extends State<SettingsPage> {
    
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('users')
                                                            .child(FirebaseAuth.instance.currentUser!.uid)
                                                            .child('Settings');

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

      //read from the database
      dbRef.onValue.listen((event) {
        DataSnapshot dataSnapshot = event.snapshot;
        Map<dynamic, dynamic> values = dataSnapshot.value as Map<dynamic, dynamic>;
        //set the defaults for the controllers
        Map<String, String> startTime = twenty4ToAmPm(values['random_start_time']);
        Map<String, String> endTime = twenty4ToAmPm(values['random_end_time']);
        Map<String, String> scheduledTime = twenty4ToAmPm(values['scheduled_time']);
        if (mounted) {
          setState(() {
            randomStartTimeController = TextEditingController(text: startTime['hrs_mins']);
            randomStartAMPMController = TextEditingController(text: startTime['am_pm']);
            randomEndTimeController = TextEditingController(text: endTime['hrs_mins']);
            randomEndAMPMController = TextEditingController(text: endTime['am_pm']);
            scheduledTimeController = TextEditingController(text: scheduledTime['hrs_mins']);
            scheduledAMPMController = TextEditingController(text: scheduledTime['am_pm']);
            randomNotifications = values['random_notifications'];
          });
        }
      });
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
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [

              //pick random or scheduled notifications
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text('Random Notifications', textAlign: TextAlign.center),
                      selected: randomNotifications,
                      selectedTileColor: Colors.purple[100],
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Color.fromARGB(153, 236, 183, 234), width: 0.5),
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

              //send settings to the database
              ElevatedButton(
                child: Text("Update"),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    print(FirebaseAuth.instance.currentUser!.uid);
                    //update database
                    Map<String, int> time = {};
                    //random notifications
                    if (randomNotifications) {
                      //check valid time 
                      if (!validTime(randomStartTimeController.text) || !validTime(randomEndTimeController.text)) {
                        
                      }
                      //start time
                      time = amPmTo24(randomStartTimeController.text, randomStartAMPMController.text);
                      dbRef.child('random_start_time').update(time);
                      //end time
                      time = amPmTo24(randomEndTimeController.text, randomEndAMPMController.text);
                      dbRef.child('random_end_time').update(time);
                    } 
                    //scheduled notifications
                    else {
                      time = amPmTo24(scheduledTimeController.text, scheduledAMPMController.text);
                      dbRef.child('scheduled_time').update(time);
                    }
                    //set notification style
                    dbRef.update({'random_notifications': randomNotifications});


                    //update alarm manager

                    //see if the period is over
                    DateTime rn = DateTime.now();
                    if (randomNotifications) {
                      //end of allowed period
                      time = amPmTo24(randomEndTimeController.text, randomEndAMPMController.text);
                    } else {
                      //just normal scheduled time
                      time = amPmTo24(scheduledTimeController.text, scheduledAMPMController.text);
                    }
                    DateTime endTime = DateTime(rn.year, rn.month, rn.day, time['hours']!, time['minutes']!);

                    
                    //cancel past alarms to avoid backlog
                    bool success = await AndroidAlarmManager.cancel(0) && await AndroidAlarmManager.cancel(1);
                    print("Canceled alarm with IDs 0 and 1: $success");

                    //if the period is not over, schedule today's notification with a one shot
                    if (endTime.isAfter(rn)) {
                      print('scheduling oneshot');
                      await AndroidAlarmManager.oneShot(
                        const Duration(seconds: 30), //schedule 30 seconds later
                        1, 
                        notificationScheduler,
                        rescheduleOnReboot: true,
                        allowWhileIdle: true,
                        exact: true,
                        wakeup: true
                      );
                    }

                    //schedule the next alarm
                    DateTime startTime = await startAlarmManager();
                    print('scheduling periodic for $startTime');
                    await AndroidAlarmManager.periodic(
                      const Duration(days: 1), 
                      0, 
                      notificationScheduler,
                      startAt: startTime, //DateTime(2025, 2, 24, 11, 18),
                      rescheduleOnReboot: true,
                      allowWhileIdle: true,
                      exact: true,
                      wakeup: true
                    );

                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid time.')),
                    );
                  }
                },
              ),

              //log out
              ElevatedButton(
              onPressed: () async {
                await AuthService().signout(context: context);
              }, 
              child: Text('Log Out')
            ),
            ],
          ),
        )
      );
    }
  }


  //time picker widget
  class TimePickerWidget extends StatelessWidget {

    const TimePickerWidget({super.key, required this.timeController, required this.amPmController});//, required this.initialAmPm});//required this.initialTime});

    // final String initialTime;
    // final String initialAmPm;
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
      print('old: $oldValue');
      print('new: $newValue');
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
              text: '',//newValue.text.substring(0,1),
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