import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gratitude_app/study_pages/questionnaire_page.dart';
import 'package:gratitude_app/utilities/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gratitude_app/utilities/globals.dart';


class DemographicsPage extends StatefulWidget {
  const DemographicsPage({super.key});

  @override
  State<DemographicsPage> createState() => _DemographicsPageState();
}


class _DemographicsPageState extends State<DemographicsPage> {

  Map<String, dynamic> textQuestions = {
    'Name': TextEditingController(),
    'Age': TextEditingController(),
    'Gender': TextEditingController(),
    'Profession': TextEditingController()
  };

  Map<TextEditingController, TextEditingController> gratitudeApps = {};
  bool useGratitudeApps = false;
  Map<TextEditingController, TextEditingController> otherApps = {};
  bool useOtherApps = false;
  bool happyGoal = false;
  bool gratitudeNoApp = false;

  List<DropdownMenuEntry<dynamic>> frequencies = [
    DropdownMenuEntry(value: "Always", label: "Always"), 
    DropdownMenuEntry(value: "Often", label: "Often"),
    DropdownMenuEntry(value: "Always", label: "Sometimes"), 
    DropdownMenuEntry(value: "Always", label: "Rarely"), 
    DropdownMenuEntry(value: "Always", label: "Never"), 
  ];

  TextEditingController gratitudeNoAppController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    textQuestions.forEach((key, value) => value.dispose());
    gratitudeApps.forEach((key, value) {
      key.dispose();
      value.dispose();
    });
    otherApps.forEach((key, value) {
      key.dispose();
      value.dispose();
    });
    gratitudeNoAppController.dispose();
  }

  void deleteApp(index, appList) {
    setState(() {
      appList.remove(appList.keys.elementAt(index));
    });
  }

  void submitForm() async {
    //map to a dictionary
    Map<String, dynamic> demographics = {
      'use_gratitude_app': useGratitudeApps,
      'use_other_apps': useOtherApps,
      'analog_gratitude': gratitudeNoApp,
      'happiness_goal': happyGoal
    };
    textQuestions.forEach((label, controller) {
      if (label.compareTo('Age') == 0 && controller.text.isNotEmpty) {
        demographics[label] = int.parse(controller.text);
      } else {
        demographics[label] = controller.text;
      }
    });
    if (useGratitudeApps) {
      List<Map<String, String>> appList = [];
      gratitudeApps.forEach((name, freq) {
        appList.add ({
          'name': name.text,
          'frequency': freq.text
        });
      });
      demographics['gratitude_apps'] = appList;
    }
    if (useOtherApps) {
      List<Map<String, String>> appList = [];
      otherApps.forEach((name, freq) {
        appList.add ({
          'name': name.text,
          'frequency': freq.text
        });
      });
      demographics['other_apps'] = appList;
    }
    if (gratitudeNoApp) {
      demographics['analog_gratitude_freq'] = gratitudeNoAppController.text;
    }

    //save to db
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(Globals.group).child(FirebaseAuth.instance.currentUser!.uid);
    await dbRef.update({'Demographics': demographics});

    //update demographics complete
    SharedPreferences prefs = await SharedPreferences.getInstance(); 
    prefs.setBool('demographics_complete', true);

    Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (BuildContext context) => QuestionnairePage(number: 1,))
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: 
          Text('Demographic Questionnaire',
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
            Text(
              'Thank you for agreeing to participate in the study! Please begin by filling out this short demographic questionnaire. You do not have to answer any questions that make you uncomfortable.',
              style: Theme.of(context).textTheme.bodyLarge!,
              textAlign: TextAlign.center,
            ),

            //basic questions
            FormRow(
              label: 'Name',
              controller: textQuestions['Name']!,
            ),
            Row( //age
              children: [
                Text('Age'),
                SizedBox(width: 10,),
                Expanded(
                  child: TextFormField(
                    controller: textQuestions['Age']!,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            FormRow(
              label: 'Gender',
              controller: textQuestions['Gender']!,
            ),
            FormRow(
              label: 'Profession',
              controller: textQuestions['Profession']!,
            ),

            //more questions
            YesNoRadio(
              label: 'Is being happy an important goal for you?', 
              radioSelected: happyGoal, 
              onChanged: (bool newValue) {
                setState(() {
                  happyGoal = newValue;
                });
              },
              largeText: true,
            ),

            //gratitude trackers
            SizedBox(height: 10,),
            YesNoRadio(
              label: 'Do you currently use a gratitude journaling app?', 
              radioSelected: useGratitudeApps, 
              onChanged: (bool newValue) {
                setState(() {
                  useGratitudeApps = newValue;
                });
              },
              largeText: true,
            ),
            useGratitudeApps ? Column(
              children: [
                SizedBox(height: 10,),
                Text(
                  'For each application you use, please add its name and select how often you use it.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10,),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: gratitudeApps.length,
                  itemBuilder: (context, index) {
                    return ApplicationInfo(
                      nameController: gratitudeApps.keys.elementAt(index), 
                      freqController: gratitudeApps.values.elementAt(index), 
                      onDelete: () => deleteApp(index, gratitudeApps),
                      frequencies: frequencies,
                    );
                  },
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      gratitudeApps[TextEditingController()] = TextEditingController();
                    });
                  }, 
                  child: Row(
                    children: [
                      Icon(Icons.add),
                      Text('Add an application')
                    ],
                  )
                ),
              ],
            ) : Container(),

            //wellbeing trackers
            SizedBox(height: 10,),
            YesNoRadio(
              label: 'Do you currently use any other wellness apps (e.g. mood tracker, meditation app)?', 
              radioSelected: useOtherApps, 
              onChanged: (bool newValue) {
                setState(() {
                  useOtherApps = newValue;
                });
              },
              largeText: true,
            ),
            useOtherApps ? Column(
              children: [
                SizedBox(height: 10,),
                Text(
                  'For each application you use, please add its name and select how often you use it.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10,),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: otherApps.length,
                  itemBuilder: (context, index) {
                    return ApplicationInfo(
                      nameController: otherApps.keys.elementAt(index), 
                      freqController: otherApps.values.elementAt(index), 
                      onDelete: () => deleteApp(index, otherApps),
                      frequencies: frequencies,
                    );
                  },
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      otherApps[TextEditingController()] = TextEditingController();
                    });
                  }, 
                  child: Row(
                    children: [
                      Icon(Icons.add),
                      Text('Add an application')
                    ],
                  )
                ),
              ],
            ) : Container(),

            //non-digital gratitude journaling
            YesNoRadio(
              label: 'Do you practice gratitude without using a software application (e.g., by journaling in a diary)? ', 
              radioSelected: gratitudeNoApp, 
              onChanged: (bool newValue) {
                setState(() {
                  gratitudeNoApp = newValue;
                });
              },
              largeText: true,
            ),
            gratitudeNoApp ? Column(
              children: [
                SizedBox(height: 10,),
                Text('How often do you use the non-digital method for practing gratitude?'),
                SizedBox(height: 10,),
                Align(
                  alignment: Alignment.centerLeft,
                  child: DropdownMenu(
                    controller: gratitudeNoAppController,
                    initialSelection: gratitudeNoAppController.text,
                    dropdownMenuEntries: frequencies,
                    menuStyle: MenuStyle(
                      backgroundColor: WidgetStateColor.resolveWith(
                        (Set<WidgetState> states) {
                          return Color.fromARGB(255, 249, 241, 237);
                        }
                      )
                    ),
                  ),
                ),
              ],
            ) : Container(),

            SwitchedColourButton (
              text: 'Submit',
              onClick: () {

                //check if there are empty fields
                List emptyFields = [];
                textQuestions.forEach((label, text) {
                  if (text.text.isEmpty) {
                    emptyFields.add(label);
                  }
                });
                if (useGratitudeApps && gratitudeApps.isEmpty) {
                  emptyFields.add('List how often you use each gratitude app');
                }
                if (useOtherApps && otherApps.isEmpty) {
                  emptyFields.add('List how often you use each wellness app');
                }
                if (gratitudeNoApp && gratitudeNoAppController.text.isEmpty) {
                  emptyFields.add('Select how often you use a non-digital method of practing gratitude');
                }

                //show popup if there are empty fields
                if (emptyFields.isNotEmpty) {
                  showDialog(
                    context: context, 
                    builder: (BuildContext context) => Dialog(
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'The following fields are empty:',
                              style: Theme.of(context).textTheme.bodyLarge!
                            ),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: emptyFields.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Icon(
                                    Icons.circle,
                                    size: 5,
                                  ),
                                  title: Text(
                                    emptyFields[index],
                                    style: Theme.of(context).textTheme.bodyLarge!
                                  ),
                                  dense: true,
                                  visualDensity: VisualDensity(horizontal:VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
                                );
                              },
                            ),
                            Text('Would you like to go back and fill out these fields? You are not required to answer any questions that make you uncomfortable.',
                              style: Theme.of(context).textTheme.bodyLarge!,
                              textAlign: TextAlign.center,
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context), 
                              child: Text("Yes, fill out remaining fields", 
                                textAlign: TextAlign.center,
                              )
                            ),
                            
                            //confirm ignore fields
                            ElevatedButton(
                              style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                                backgroundColor: WidgetStatePropertyAll<Color>(Color.fromARGB(255, 209, 108, 103)),
                              ),
                              onPressed: () => submitForm(), 
                              child: Text("No, leave these fields blank",
                                style: TextStyle(
                                  color: Colors.white
                                ),
                                textAlign: TextAlign.center,
                              )
                            )
                          ],
                        ),
                      ),
                    )
                  );
                } 
                //if nothing empty, then submit
                else {
                  submitForm();
                }
              }, 
            )
          ],
        ),
      )
    );
  }
}


//form row
class FormRow extends StatelessWidget {
  const FormRow({super.key, required this.label, required this.controller});

  final String label; 
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        SizedBox(width: 10,),
        Expanded(
          child: TextFormField(
            controller: controller,
          ),
        ),
      ],
    );
  }
}


//select application + its frequency
class ApplicationInfo extends StatelessWidget {
  const ApplicationInfo({super.key, required this.nameController, required this.freqController, required this.onDelete, required this.frequencies});

  final TextEditingController nameController;
  final TextEditingController freqController;
  final Function onDelete;
  final List<DropdownMenuEntry<dynamic>> frequencies;
  

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all(
            width: 0.5,
            color: Colors.grey
          )
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              FormRow(
                label: 'Application Name',
                controller: nameController,
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Text('Frequency'),
                  SizedBox(width: 10,),
                  DropdownMenu(
                    controller: freqController,
                    initialSelection: freqController.text,
                    dropdownMenuEntries: frequencies,
                    menuStyle: MenuStyle(
                      backgroundColor: WidgetStateColor.resolveWith(
                        (Set<WidgetState> states) {
                          return Color.fromARGB(255, 249, 241, 237);
                        }
                      )
                    ),
                  ),
                ],
              ),
              TextButton(
              onPressed: () => onDelete(),
              child: Row(
                children: [
                  Icon(Icons.delete),
                  Text('Remove')
                ],
              )
            ),
            ],
          ),
        ),
      ),
    );
  }
}