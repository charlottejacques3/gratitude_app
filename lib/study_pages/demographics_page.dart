import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gratitude_app/study_pages/questionnaire_page.dart';
import 'package:gratitude_app/utilities/widgets.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gratitude_app/utilities/globals.dart';


class DemographicsPage extends StatefulWidget {
  const DemographicsPage({super.key});

  @override
  State<DemographicsPage> createState() => _DemographicsPageState();
}


class _DemographicsPageState extends State<DemographicsPage> {

  TextEditingController ageController = TextEditingController();
  List<DropdownMenuEntry<dynamic>> ageRanges = [
    DropdownMenuEntry(value: "19-29", label: "19-29"), 
    DropdownMenuEntry(value: "30-39", label: "30-39"),
    DropdownMenuEntry(value: "40-49", label: "40-49"), 
    DropdownMenuEntry(value: "50-59", label: "50-59"), 
    DropdownMenuEntry(value: "60+", label: "60+"), 
  ];

  TextEditingController genderController = TextEditingController();
  List<DropdownMenuEntry<dynamic>> genderOptions = [
    DropdownMenuEntry(value: "Female", label: "Female"), 
    DropdownMenuEntry(value: "Male", label: "Male"),
    DropdownMenuEntry(value: "Non-Binary", label: "Non-Binary"), 
    DropdownMenuEntry(value: "Other", label: "Other"), 
    DropdownMenuEntry(value: "Prefer not to say", label: "Prefer not to say"), 
  ];

  TextEditingController profController = TextEditingController();
  // Map<String, dynamic> textQuestions = {
  //   // 'Name': TextEditingController(),
  //   // 'Age': TextEditingController(),
  //   'Gender': TextEditingController(),
  //   'Profession': TextEditingController()
  // };

  Map<TextEditingController, TextEditingController> gratitudeApps = {};
  bool? useGratitudeApps;
  Map<TextEditingController, TextEditingController> otherApps = {};
  bool? useOtherApps;
  bool? happyGoal;
  bool? gratitudeNoApp;
  bool? gratitudeStruggles;

  List<DropdownMenuEntry<dynamic>> frequencies = [
    DropdownMenuEntry(value: "Always", label: "Always"), 
    DropdownMenuEntry(value: "Often", label: "Often"),
    DropdownMenuEntry(value: "Always", label: "Sometimes"), 
    DropdownMenuEntry(value: "Always", label: "Rarely"), 
    DropdownMenuEntry(value: "Always", label: "Never"), 
  ];

  List<String> selectedChallenges = [];
  List<String> challenges = [
    "I struggle to come up with things to write about",
    "I lose motivation quickly",
    "I find it difficult to see the positive when I feel down",
    "I don't know how to practice gratitude",
    "Other"
  ];
  TextEditingController otherController = TextEditingController();

  TextEditingController gratitudeNoAppController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    // textQuestions.forEach((key, value) => value.dispose());
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
      'age': ageController.text,
      'gender': genderController.text,
      'profession': profController.text,
      'use_gratitude_app': useGratitudeApps,
      'use_other_apps': useOtherApps,
      'analog_gratitude': gratitudeNoApp,
      'happiness_goal': happyGoal,
      'gratitude_struggles': gratitudeStruggles,
    };
    if (useGratitudeApps ?? false) {
      List<Map<String, String>> appList = [];
      gratitudeApps.forEach((name, freq) {
        appList.add ({
          'name': name.text,
          'frequency': freq.text
        });
      });
      demographics['gratitude_apps'] = appList;
    }
    if (useOtherApps != null && useOtherApps!) {
      List<Map<String, String>> appList = [];
      otherApps.forEach((name, freq) {
        appList.add ({
          'name': name.text,
          'frequency': freq.text
        });
      });
      demographics['other_apps'] = appList;
    }
    if (gratitudeNoApp ?? false) {
      demographics['analog_gratitude_freq'] = gratitudeNoAppController.text;
    }
    if (gratitudeStruggles ?? false) {
      demographics['challenge_list'] = selectedChallenges;
      if (otherController.text.isNotEmpty) {
        demographics['other_challenge'] = otherController.text;
      }
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
              'Thank you for agreeing to participate in the study! Please begin by filling out this short demographic questionnaire.',
              style: Theme.of(context).textTheme.bodyLarge!,
              textAlign: TextAlign.center,
              
            ),

            //age
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row (
                children: [
                  Text('Age'),
                  SizedBox(width: 10,),
                  DropdownMenu(
                    controller: ageController,
                    initialSelection: ageController.text,
                    dropdownMenuEntries: ageRanges,
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
            ),

            //gender
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row (
                children: [
                  Text('Gender'),
                  SizedBox(width: 10,),
                  DropdownMenu(
                    controller: genderController,
                    initialSelection: genderController.text,
                    dropdownMenuEntries: genderOptions,
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
            ),

            //profession
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Profession'),
                  SizedBox(width: 10,),
                  Expanded(
                    child: TextFormField(
                      controller: profController,
                    ),
                  ),
                ],
              ),
            ),

            // FormRow(
            //   label: 'Gender',
            //   controller: textQuestions['Gender']!,
            // ),
            // FormRow(
            //   label: 'Profession',
            //   controller: textQuestions['Profession']!,
            // ),

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
            (useGratitudeApps ?? false) ? Column(
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
            (useOtherApps ?? false) ? Column(
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
            (gratitudeNoApp ?? false) ? Column(
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
                SizedBox(height: 10,)
              ],
            ) : Container(),

            //difficulties practing gratitude
            (gratitudeNoApp ?? false) || (useGratitudeApps ?? false) ? Column(
              children: [
                YesNoRadio(
                  label: 'Do you ever experience challenges when trying to practice gratitude? ', 
                  radioSelected: gratitudeStruggles, 
                  onChanged: (bool newValue) {
                    setState(() {
                      gratitudeStruggles = newValue;
                    });
                  },
                  largeText: true,
                ),
                (gratitudeStruggles ?? false) ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10,),
                    Text('What kind of challenges do you experience?',
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.bodyLarge
                    ),
                    SizedBox(height: 10,),
                    
                    MultiSelectDialogField(
                      items: challenges.map((e) => MultiSelectItem(e, e)).toList(),
                      listType: MultiSelectListType.LIST,
                      onConfirm: (values) {
                        setState(() {
                          selectedChallenges = values;
                        });
                      },
                      itemsTextStyle: Theme.of(context).textTheme.bodyLarge,
                      selectedItemsTextStyle: Theme.of(context).textTheme.bodyLarge,
                    ),
                    SizedBox(height: 10,),

                    selectedChallenges.contains('Other') ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Other: please specify',
                          textAlign: TextAlign.left,
                        ),
                        TextFormField(
                          controller: otherController,
                          keyboardType: TextInputType.multiline,
                          minLines: 2,
                          maxLines: 5,
                          style: Theme.of(context).textTheme.bodyMedium,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ) : Container()
                  ],
                ) : Container(),
              ],
            ) : Container(),
            

            SwitchedColourButton (
              text: 'Submit',
              onClick: () {

                //check if there are empty fields
                String message = '';

                if (ageController.text.isEmpty) {
                  message = 'Please fill out your age';
                } else if (profController.text.isEmpty) {
                  message = 'Please fill out your profession';
                } else if (happyGoal == null) {
                  message = 'Please answer the question "Is being happy an important goal for you?"';
                } else if (useGratitudeApps == null) {
                  message = 'Please answer the question "Do you currently use a gratitude journaling app?"';
                } else if (useOtherApps == null) {
                  message = 'Please answer the question "Do you currently use any other wellness apps?"';
                } else if (gratitudeNoApp == null) {
                  message = 'Please answer the question "Do you practice gratitude without using a software application?"';
                } else if (((useGratitudeApps ?? false) || (gratitudeNoApp ?? false)) && gratitudeStruggles == null) {
                  message = 'Please answer the question "Do you ever experience challenges when trying to practice gratitude?"';
                } else if ((useGratitudeApps ?? false) && gratitudeApps.isEmpty) {
                  message = 'Please list each gratitude app and how often you use it';
                } else if ((useOtherApps ?? false) && otherApps.isEmpty) {
                  message = 'Please list each wellness app and how often you use it';
                } else if ((gratitudeNoApp ?? false) && gratitudeNoAppController.text.isEmpty) {
                  message = 'Please select how often you use a non-digital method of practing gratitude';
                } else if ((gratitudeStruggles ?? false) && selectedChallenges.isEmpty) {
                  message = 'Please select the challenges you have when practicing gratitude';
                } else if ((gratitudeStruggles ?? false) && selectedChallenges.contains('Other') && otherController.text.isEmpty) {
                  message = 'Please specify "Other"';
                } else {
                  //loop through apps
                  for (var i = 0; i < gratitudeApps.length; i++) {
                    if (gratitudeApps.keys.elementAt(i).text.isEmpty) {
                      message = 'Please list the name of each gratitude app';
                      break;
                    } else if (gratitudeApps.values.elementAt(i).text.isEmpty) {
                      message = 'Please select how often you use each gratitude app';
                      break;
                    }
                  }
                  if (message.isEmpty) {
                    for (var i = 0; i < otherApps.length; i++) {
                      if (otherApps.keys.elementAt(i).text.isEmpty) {
                        message = 'Please list the name of each wellness app';
                        break;
                      } else if (otherApps.values.elementAt(i).text.isEmpty) {
                        message = 'Please select how often you use each wellness app';
                        break;
                      }
                    }
                  }
                }
                
                if (message.isNotEmpty) {
                  Flushbar(
                    message: message,
                    duration: Duration(milliseconds: 1500),
                    backgroundColor: Color.fromARGB(255, 209, 108, 103),
                  ).show(context);
                }
                //otherwise submit form
                else {
                  submitForm();
                }
              }, 
            ),
          ],
        ),
      )
    );
  }
}


//form row
class FormRow extends StatelessWidget {
  const FormRow({super.key, required this.label, required this.controller, this.validator});

  final String label; 
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

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
            validator: validator != null ? (value) => validator!(value) : (value) =>  null
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