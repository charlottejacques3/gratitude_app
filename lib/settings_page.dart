import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

//import files
import 'helper_functions.dart';

//database imports
import 'package:firebase_database/firebase_database.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}


class _SettingsPageState extends State<SettingsPage> {
  
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('Settings');

  bool randomNotifications = true;

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
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
              color: Theme.of(context).colorScheme.primary,
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
                      side: BorderSide(color: Colors.grey, width: 1),
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
            Column(
              children: 

                //random notification settings
                randomNotifications ? [
                  Text("These are the time intervals when you want to receive a random notification"),
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
                  Text("Select the time you wish to receive a notification"),
                  TimePickerWidget(
                    timeController: scheduledTimeController, 
                    amPmController: scheduledAMPMController
                  )
                ],
            ),
            SizedBox(height: 20),

            //send settings to the database
            ElevatedButton(
              child: Text("Update"),
              onPressed: () {

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

                  //scheduled notifications
                } else {
                  time = amPmTo24(scheduledTimeController.text, scheduledAMPMController.text);
                  dbRef.child('scheduled_time').update(time);
                }
                
                //set notification style
                dbRef.update({'random_notifications': randomNotifications});
              },
            )
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
              MaskedInputFormatter('##:##')
            ],
          ),
        ),
        SizedBox(width: 8),
        DropdownMenu(
          controller: amPmController,
          requestFocusOnTap: true,
          dropdownMenuEntries: amPm,
          enableFilter: true,
          width: 100,
        ),
      ]
    );
  }
}