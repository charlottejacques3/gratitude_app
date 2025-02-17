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
  // String randomStartTime = '09:00';
  // String randomStartAMPM = 'AM';
  // String randomEndTime = '09:00';
  // String randomEndAMPM = 'PM';
  // String scheduledTime = '12:00';
  // String scheduleAMPM = 'PM';

  //controllers (dynamically set these later in initstate after reading from the database)
  TextEditingController randomStartTimeController= TextEditingController();//text: '09:00');
  TextEditingController randomStartAMPMController = TextEditingController();//text: 'AM');
  TextEditingController randomEndTimeController = TextEditingController();//text: '09:00');
  TextEditingController randomEndAMPMController = TextEditingController();//text: 'PM');

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
      if (mounted) {
        setState(() {
          print("in set state");
          randomStartTimeController = TextEditingController(text: startTime['hrs_mins']);
          randomStartAMPMController = TextEditingController(text: startTime['am_pm']);
          randomEndTimeController = TextEditingController(text: endTime['hrs_mins']);
          randomEndAMPMController = TextEditingController(text: endTime['am_pm']);
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
                  Text("Time Frame"),
                  Text("These are the time intervals when you want to receive a random notification"),
                  Row(
                    children: [
                      Expanded(child: TimePickerWidget(
                        timeController: randomStartTimeController,
                        amPmController: randomStartAMPMController,
                        // initialAmPm: randomStartAMPM,
                      )),
                      Text("     -     "),
                      Expanded(child: TimePickerWidget(
                        timeController: randomEndTimeController,
                        amPmController: randomEndAMPMController,
                        // initialAmPm: randomEndAMPM,
                      ))
                    ],
                  ),
                ]

                //scheduled notification settings
                : [
                  Text("Time")
                ],
            ),
            SizedBox(height: 20),

            //send settings to the database
            ElevatedButton(
              child: Text("Done"),
              onPressed: () {

                //random notifications
                if (randomNotifications) {
                  //start time
                  Map<String, int> time = amPmTo24(randomStartTimeController.text, randomStartAMPMController.text);
                  dbRef.child('random_start_time').update(time);
                  //end time
                  time = amPmTo24(randomEndTimeController.text, randomEndAMPMController.text);
                  dbRef.child('random_end_time').update(time);

                  //scheduled notifications
                } else {

                }
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
            // validator: (value) {
            //   if (value == null || value.isEmpty) {
            //     return 'Please enter some text';
            //   }
            //   return null;
            // },
          ),
        ),
        SizedBox(width: 8),
        DropdownMenu(
          controller: amPmController,
          requestFocusOnTap: true,
          // initialSelection: initialAmPm,
          dropdownMenuEntries: amPm,
          enableFilter: true,
          width: 100,
        ),
      ]
    );
  }
}