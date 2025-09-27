import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gratitude_app/init_mood_page.dart';
import 'package:gratitude_app/main.dart';
import 'package:gratitude_app/study_pages/study_complete_page.dart';
import 'package:gratitude_app/utilities/notification_service.dart';
import 'package:gratitude_app/utilities/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gratitude_app/utilities/globals.dart';


class QuestionnairePage extends StatefulWidget {
  final int number;
  const QuestionnairePage({super.key, required this.number});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}


class _QuestionnairePageState extends State<QuestionnairePage> {

  List<Map<String, dynamic>> gratitudeQuestions = [
    {'question': "I have so much in life to be thankful for.", 'controller': TextEditingController()},
    {'question': "If I had to list everything that I felt grateful for, it would be a very long list.", 'controller': TextEditingController()},
    {'question': "When I look at the world, I don't see much to be grateful for.", 'controller': TextEditingController()},
    {'question': "I am grateful to a wide variety of people.", 'controller': TextEditingController()},
    {'question': "As I get older I find myself more able to appreciate the people, events, and situations that have been part of my life history.", 'controller': TextEditingController()},
    {'question': "Long amounts of time can go by before I feel grateful to something or someone.", 'controller': TextEditingController()}
  ];

  List<Map<String, dynamic>> satisfactionQuestions = [
    {'question': "In most ways my life is close to ideal.", 'controller': TextEditingController()},
    {'question': "The conditions of my life are excellent.", 'controller': TextEditingController()},
    {'question': "I am satisfied with my life.", 'controller': TextEditingController()},
    {'question': "So far I have gotten the important things I want in life.", 'controller': TextEditingController()},
    {'question': "If I could live my life over, I would change almost nothing.", 'controller': TextEditingController()},
  ];

  List<Map<String, dynamic>> happinessQuestions = [
    {'question': "In general, I consider myself:", 'controller': TextEditingController()},
    {'question': "Compared to most of my peers, I consider myself:", 'controller': TextEditingController()},
    {'question': "Some people are generally very happy. They enjoy life regardless of what is going on, getting the most out of everything. To what extent does this characterization describe you?", 'controller': TextEditingController()},
    {'question': "Some people are generally not very happy. Although they are not depressed, they never seem as happy as they might be. To what extend does this characterization describe you?", 'controller': TextEditingController()},
  ];

  List<Map<String, dynamic>> reflectionQuestions = [
    {'question': "Using the system has led to a wake-up call to make changes in my life.", 'controller': TextEditingController(), 'subcategory': 'insight'},
    {'question': "As a result of using the system, I have changed how I approach things.", 'controller': TextEditingController(), 'subcategory': 'insight'},
    {'question': "Using the system gives me an idea on how to overcome challenges.", 'controller': TextEditingController(), 'subcategory': 'insight'},
    {'question': "I enjoy exploring my data with the system.", 'controller': TextEditingController(), 'subcategory': 'exploration'},
    {'question': "The system helps me to discuss my data with others.", 'controller': TextEditingController(), 'subcategory': 'exploration'},
    {'question': "The system makes it easy to review my long-term personal data.", 'controller': TextEditingController(), 'subcategory': 'exploration'},
  ];

  List<Map<String, dynamic>> helpfulnessQuestions = [
    {'question': "Random Past Log (from Inspiration page)", 'controller': TextEditingController(), 'order': 1},
    {'question': "Random Photo from Camera Roll", 'controller': TextEditingController(), 'order': 2},
    {'question': "Gratitude Prompt", 'controller': TextEditingController(), 'order': 3},
    {'question': "Reframing Negative Emotions", 'controller': TextEditingController(), 'order': 4},
    {'question': "Viewing Past Logs and Mood Changes", 'controller': TextEditingController(), 'order': 5},
    {'question': "Leaving Advice for your Future Self", 'controller': TextEditingController(), 'order': 6},
  ];

  List<String> features = ['Random Past Log', 'Random Photo', 'Gratitude Prompt', 'Reframing Negative Emotions', 'Viewing Past Logs and Mood Changes', 'Leaving Advice'];

  // List<Map<String, dynamic>> affectQuestions = [
  //   {'question': "Upset", 'controller': TextEditingController()},
  //   {'question': "Hostile", 'controller': TextEditingController()},
  //   {'question': "Alert", 'controller': TextEditingController()},
  //   {'question': "Ashamed", 'controller': TextEditingController()},
  //   {'question': "Inspired", 'controller': TextEditingController()},
  //   {'question': "Nervous", 'controller': TextEditingController()},
  //   {'question': "Determined", 'controller': TextEditingController()},
  //   {'question': "Attentive", 'controller': TextEditingController()},
  //   {'question': "Afraid", 'controller': TextEditingController()},
  //   {'question': "Active", 'controller': TextEditingController()},
  // ];

  List<DropdownMenuEntry<dynamic>> likert = [
    DropdownMenuEntry(value: "Strongly disagree", label: "Strongly disagree"), 
    DropdownMenuEntry(value: "Disagree", label: "Disagree"), 
    DropdownMenuEntry(value: "Slightly disagree", label: "Slightly disagree"), 
    DropdownMenuEntry(value: "Neutral", label: "Neutral"), 
    DropdownMenuEntry(value: "Slightly agree", label: "Slightly agree"), 
    DropdownMenuEntry(value: "Agree", label: "Agree"), 
    DropdownMenuEntry(value: "Strongly agree", label: "Strongly agree"), 
  ];

  List<DropdownMenuEntry<dynamic>> helpfulness = [
    DropdownMenuEntry(value: "Very unhelpful", label: "Very unhelpful"), 
    DropdownMenuEntry(value: "Unhelpful", label: "Unhelpful"), 
    DropdownMenuEntry(value: "Moderately unhelpful", label: "Moderately unhelpful"), 
    DropdownMenuEntry(value: "Neutral", label: "Neutral"), 
    DropdownMenuEntry(value: "Moderately helpful", label: "Moderately helpful"), 
    DropdownMenuEntry(value: "Helpful", label: "Helpful"), 
    DropdownMenuEntry(value: "Very helpful", label: "Very helpful"), 
    DropdownMenuEntry(value: "I did not use this feature", label: "I did not use this feature"), 
  ];

  // List<DropdownMenuEntry<dynamic>> frequencies = [
  //   DropdownMenuEntry(value: 1, label: "1 - Very slightly or not at all"), 
  //   DropdownMenuEntry(value: 2, label: "2 - A little"), 
  //   DropdownMenuEntry(value: 3, label: "3 - Moderately"), 
  //   DropdownMenuEntry(value: 4, label: "4 - Quite a bit"), 
  //   DropdownMenuEntry(value: 5, label: "5 - Extremely"), 
  // ];

  List<DropdownMenuEntry<dynamic>> customOptions(String start, String end) {
    return [
      DropdownMenuEntry(value: 1, label: "1 - $start"),
      DropdownMenuEntry(value: 2, label: "2"),
      DropdownMenuEntry(value: 3, label: "3"),
      DropdownMenuEntry(value: 4, label: "4"),
      DropdownMenuEntry(value: 5, label: "5"),
      DropdownMenuEntry(value: 6, label: "6"),
      DropdownMenuEntry(value: 7, label: "7 - $end")
    ];
  }

  List<String> findEmpty(List<Map<String, dynamic>> questions) {
    List<String> emptyFields = [];
    for (final q in questions) {
      if (q['controller'].text.isEmpty) {
        emptyFields.add(q['question']);
        setState(() {
          q['empty'] = true;
        });
      }
    }
    return emptyFields;
  }

  List<Map<String, String>> getResponseText(List<Map<String, dynamic>> questions) {
    List<Map<String, String>> responses = [];
    for (final q in questions) {
      Map<String, String> resp = {
        'question': q['question'],
        'response': q['controller'].text
      };
      //add type if applicable
      if (q['subcategory'] != null) {
        resp['subcategory'] = q['subcategory'];
      }
      responses.add(resp);
    }
    return responses;
  }

  int likertScore(String? response) {
    if (response == null) return 0;
    switch (response) {
      case 'Strongly disagree':
        return 1;
      case 'Disagree':
        return 2;
      case 'Slightly disagree':
        return 3;
      case 'Neutral':
        return 4;
      case 'Slightly agree':
        return 5;
      case 'Agree':
        return 6;
      case 'Strongly agree':
        return 7;
      default:
        return 0;
    }
  }

  int calculateGratitudeScore(List<Map<String, String>> responses) {
    int score = 0;
    for (var i = 0; i < responses.length; i++) {
      int inc = likertScore(responses[i]['response']);
      if ((i == 2 || i == 5) && inc != 0) inc = 8-inc;
      score += inc;
    }
    return score;
  }

  int calculateSatisfactionScore(List<Map<String, String>> responses) {
    int score = 0;
    for (final r in responses) {
      score += likertScore(r['response']);
    }
    return score;
  }

  int calculateHappinessScore(List<Map> responses) {
    int score = 0;
    for (var i = 0; i < responses.length; i++) {
      final r = responses[i];
      if (r['response'] != null && r['response'].isNotEmpty) {
        String num = r['response'].substring(0,1);
        if (i == 3) {
          score += 8-int.parse(num);
        } else {
          score += int.parse(num);
        }
      }
    }
    return score;
  }

  Map<String, int> calculateReflectionScore(List<Map> responses) {
    int insightScore = 0;
    int explorationScore = 0;
    for (final r in responses) {
      if ('insight'.compareTo(r['subcategory']) == 0) {
        insightScore += likertScore(r['response']);
      } else if ('exploration'.compareTo(r['subcategory']) == 0) {
        explorationScore += likertScore(r['response']);
      }
    }
    return {'insight': insightScore, 'exploration': explorationScore};
  }

  Map<String, dynamic> calculateFeatureScore(List<Map> responses) {
    int score = 0;
    int numFeaturesUsed = 0;
    for (final r in responses) {
      numFeaturesUsed++;
      switch (r['response']) {
        case 'Very unhelpful':
          score++;
          break;
        case 'Unhelpful':
          score+=2;
          break;
        case 'Moderately unhelpful':
          score+=3;
          break;
        case 'Neutral':
          score+=4;
          break;
        case 'Moderately helpful':
          score+=5;
          break;
        case 'Helpful':
          score+=6;
          break;
        case 'Very helpful':
          score+=7;
          break;
        case 'I did not use this feature':
          numFeaturesUsed--;
          break;
      }
    }
    return {'avg_score': score/numFeaturesUsed, 'features_used': numFeaturesUsed};
  }

  // int calculateAffectScore(List<Map> responses, bool positive) {
  //   int score = 0;
  //   for (final r in responses) {
  //     if (r['response'] != null && r['response'].isNotEmpty) {
  //       String num = r['response'].substring(0,1);
  //       if ((positive && ['Alert', 'Inspired', 'Determined', 'Attentive', 'Active'].contains(r['question']))
  //       || (!positive && ['Upset', 'Hostile', 'Ashamed', 'Nervous', 'Afraid'].contains(r['question']))) {
  //         score += int.parse(num);
  //       }
  //     }
  //   }
  //   return score;
  // }

  void submitForm() async {
    List<Map<String, String>> gratitudeResponses = getResponseText(gratitudeQuestions);
    List<Map<String, String>> satisfactionResponses = getResponseText(satisfactionQuestions);
    List<Map<String, String>> happinessResponses = getResponseText(happinessQuestions);
    // List<Map<String, String>> affectResponses = getResponseText(affectQuestions);

    //map to dictionary
    Map<String, dynamic> data = {
      'gratitude_responses': gratitudeResponses,
      'gratitude_score': calculateGratitudeScore(gratitudeResponses),
      'satisfaction_responses': satisfactionResponses,
      'satisfaction_score': calculateSatisfactionScore(satisfactionResponses),
      'happiness_responses': happinessResponses,
      'happiness_score': calculateHappinessScore(happinessResponses),
      // 'affect_responses': affectResponses,
      // 'positive_affect_score': calculateAffectScore(affectResponses, true),
      // 'negative_affect_score': calculateAffectScore(affectResponses, false)
    };

    //get reflection + feature data if applicable
    if (widget.number == 2) {
      List<Map<String, String>> reflectionResponses = getResponseText(reflectionQuestions);
      List<Map<String, String>> featureResponses = getResponseText(helpfulnessQuestions);
      data.addAll({
        'reflection_responses': reflectionResponses,
        'reflection_insight_score': calculateReflectionScore(reflectionResponses)['insight'],
        'reflection_exploration_score': calculateReflectionScore(reflectionResponses)['exploration'],
        'feature_responses': featureResponses,
        'feature_score': calculateFeatureScore(featureResponses),
        'feature_order': features
      });
    }

    //save to db
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(Globals.group).child(FirebaseAuth.instance.currentUser!.uid);
    if (widget.number == 1) {
      await dbRef.update({'HappinessQuestionnairesInitial': data});
    } else if (widget.number == 2) {
      await dbRef.update({'HappinessQuestionnairesFinal': data});
    }
    
    //study beginning
    if (widget.number == 1) {
      //update questionnaire complete
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('initial_questionnaires_complete', true);
      DateTime endTime = DateTime.now().add(Duration(days: 7)); 
      DateTime endDay = DateTime(endTime.year, endTime.month, endTime.day);
      prefs.setString('end_time', endTime.toIso8601String());
      prefs.setString('end_day', endDay.toIso8601String());
      print('END TIME: ${endTime.toIso8601String()}, END DATE: ${endDay.toIso8601String()}');

      //send to tutorial page
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) {
          // return WelcomePage();
          if (Globals.group.compareTo('experimental') == 0) {
            return InitialMoodPage();
          } else {
            return MyHomePage(startingPageIndex: 0);
          }
        })
      );
    } 
    
    //study concluded
    else if (widget.number == 2) {
      //log out
      // await AuthService().signout(context: context);

      //update study complete
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('study_complete', true);
      print('STUDY COMPLETE: ${prefs.getBool('study_complete')}');

      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) => StudyCompletePage())
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (final q in gratitudeQuestions) {
      q['controller'].dispose();
    }
    for (final q in satisfactionQuestions) {
      q['controller'].dispose();
    }
    for (final q in happinessQuestions) {
      q['controller'].dispose();
    }
    for (final q in reflectionQuestions) {
      q['controller'].dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Happiness Questionnaires',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // ElevatedButton(
            //   child: Text('Demographics'),
            //   onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DemographicsPage()))
            // ),
            Text("Please fill out the following questionnaires.",
              style: Theme.of(context).textTheme.bodyLarge!,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30,),

            //gratitude questionnaire
            Questionnaire(
              questions: gratitudeQuestions,
              name: 'Gratitude Questionnaire'
            ),

            //life satisfaction questionnaire
            Questionnaire(
              questions: satisfactionQuestions,
              name: 'Sastisfaction with Life Scale'
            ),

            //subjective happiness questionnaire
            Text("General Happiness Scale",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5,),
            Text('For each of the following statements and/or questions, please select the point on the scale that you feel is most appropriate in describing you.',
              style: Theme.of(context).textTheme.bodyMedium!,
              textAlign: TextAlign.center,
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: happinessQuestions.length,
              itemBuilder: (context, index) {
                List<DropdownMenuEntry<dynamic>> options = [];
                if (index == 0) {
                  options = customOptions('not a very happy person', 'a very happy person');
                } else if (index == 1) {
                  options = customOptions('less happy', 'more happy');
                } else {
                  options = customOptions('not at all', 'a great deal');
                }
                return Selector(
                  text: happinessQuestions[index]['question'],
                  dropdownController: happinessQuestions[index]['controller'],
                  dropdownOptions: options,
                  redBg: happinessQuestions[index]['empty'] != null && happinessQuestions[index]['empty'],
                );
              },
            ),
            SizedBox(height: 30,),

            //end of study questionnaires
            widget.number == 2 ? ListView(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [

                //reflection questionnaire
                Questionnaire(
                  questions: reflectionQuestions, 
                  name: 'Technology-Supported Reflection Inventory'
                ),

                //feature questions
                Globals.group.compareTo('experimental') == 0 ? ListView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    
                    //rate features helpfulness
                    Questionnaire(
                      questions: helpfulnessQuestions, 
                      name: 'App Feature Questions',
                      instructions: 'Please rate how helpful each feature was in promoting reflection and gratitude.',
                      customOptions: helpfulness,
                    ),

                    //order features
                    Text('Please re-order each of the features in terms of how helpful they were for promoting reflection and gratitude (most helpful at the top)\nHold down and drag to move items.',
                      // style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    SizedBox(height: 10,),
                    Text('Most helpful',
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      )
                    ),
                    ReorderableListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final String item = features.removeAt(oldIndex);
                          features.insert(newIndex, item);
                        });
                      },
                      children: [
                        for(int i = 0; i < features.length; i++) 
                          Padding(
                            key: Key('$i'),
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: ListTile(
                              key: Key('$i'),
                              title: Text(features[i]),
                              leading: Text('${i+1}'),
                              trailing: Icon(Icons.menu),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.grey, width: 0.5),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              ),
                          )
                      ], 
                    ),
                    Text('Least helpful',
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      )
                    ),
                    SizedBox(height: 30,)
                  ],
                ) : Container(),
              ]
              
            ) : Container(),

            //affect questionnaire
            // Text("Positive and Negative Affect Schedule",
            //   style: Theme.of(context).textTheme.titleMedium!.copyWith(
            //     fontWeight: FontWeight.bold
            //   ),
            //   textAlign: TextAlign.center,
            // ),
            // SizedBox(height: 5,),
            // Text('Thinking about yourself and how you normally feel, to what extend do you generally feel the following emotions on a scale of 1 to 5 (where 1 is very slightly or not at all and 5 is extremely)?',
            //   style: Theme.of(context).textTheme.bodyLarge!,
            //   textAlign: TextAlign.center,
            // ),
            // ListView.builder(
            //   physics: NeverScrollableScrollPhysics(),
            //   shrinkWrap: true,
            //   itemCount: affectQuestions.length,
            //   itemBuilder: (context, index) {
            //     return Selector(
            //       text: affectQuestions[index]['question'],
            //       dropdownController: affectQuestions[index]['controller'],
            //       dropdownOptions: frequencies,
            //     );
            //   },
            // ),
            // SizedBox(height: 30,),

            //submit
            SwitchedColourButton(
              onClick: () {
                //check all questions are submitted
                List<String> emptyFields = [];
                emptyFields.addAll(findEmpty(gratitudeQuestions));
                emptyFields.addAll(findEmpty(satisfactionQuestions));
                emptyFields.addAll(findEmpty(happinessQuestions));
                if (widget.number == 2) {
                  emptyFields.addAll(findEmpty(reflectionQuestions));
                  if (Globals.group.compareTo('experimental') == 0) {
                    emptyFields.addAll(findEmpty(helpfulnessQuestions));
                  }
                }

                print('EMPTY: $emptyFields, ${findEmpty(gratitudeQuestions)}');

                // emptyFields.addAll(findEmpty(affectQuestions));
                if (emptyFields.isNotEmpty) {
                  Flushbar(
                    message: 'Please fill out the empty fields.',
                    duration: Duration(milliseconds: 1500),
                    backgroundColor: Color.fromARGB(255, 209, 108, 103),
                  ).show(context);
                //   showDialog(
                //     context: context, 
                //     builder: (BuildContext context) => Dialog(
                //       child: Padding(
                //         padding: EdgeInsets.all(15),
                //         child: ListView(
                //           children: [
                //             Text(
                //               'The following questions are unanswered:',
                //               style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                //                 fontWeight: FontWeight.bold
                //               ),
                //               textAlign: TextAlign.center,
                //             ),
                //             ListView.builder(
                //               physics: NeverScrollableScrollPhysics(),
                //               shrinkWrap: true,
                //               itemCount: emptyFields.length,
                //               itemBuilder: (context, index) {
                //                 return ListTile(
                //                   leading: Icon(
                //                     Icons.circle,
                //                     size: 5,
                //                   ),
                //                   title: Text(
                //                     emptyFields[index],
                //                     style: Theme.of(context).textTheme.bodyLarge!
                //                   ),
                //                   dense: true,
                //                   visualDensity: VisualDensity(horizontal:VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
                //                 );
                //               },
                //             ),
                //             Text('Would you like to go back and answer these questions? You are not required to answer any questions that make you uncomfortable.',
                //               style: Theme.of(context).textTheme.bodyLarge!,
                //               textAlign: TextAlign.center,
                //             ),
                //             ElevatedButton(
                //               onPressed: () => Navigator.pop(context), 
                //               child: Text("Yes, fill out remaining fields", 
                //                 textAlign: TextAlign.center,
                //               )
                //             ),
                            
                //             //confirm ignore fields
                //             ElevatedButton(
                //               style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                //                 backgroundColor: WidgetStatePropertyAll<Color>(Color.fromARGB(255, 209, 108, 103)),
                //               ),
                //               onPressed: () => submitForm(), 
                //               child: Text("No, leave these fields blank",
                //                 style: TextStyle(
                //                   color: Colors.white
                //                 ),
                //                 textAlign: TextAlign.center,
                //               )
                //             )
                //           ],
                //         ),
                //       ),
                //     )
                  // );
                } 

                //no empty fields
                else {
                  submitForm();
                }
              }, 
              text: 'Submit'
            ),

            //TEMPORARY skip button
            SwitchedColourButton(
              text: widget.number == 1 ? 'Skip - TEMPORARY' : 'Back to main app', 
              onClick: () async {

                //update questionnaire complete
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('initial_questionnaires_complete', true);
                Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (BuildContext context) {
                    // return WelcomePage();
                    if (Globals.group.compareTo('experimental') == 0) {
                      return InitialMoodPage();
                    } else {
                      return MyHomePage(startingPageIndex: 0);
                    }
                  })
                );

                //set notifs
                await NotificationService.initNotifications();
              }
            ),
          ],
        ),
      )
    );
  }
}


class Questionnaire extends StatelessWidget {
  const Questionnaire({super.key, required this.questions, required this.name, this.instructions='Please select how much you agree with each statement.', this.customOptions});

  final List<Map<String, dynamic>> questions;
  final String name;
  final String instructions;
  final List<DropdownMenuEntry<dynamic>>? customOptions;

  @override
  Widget build(BuildContext context) {

    List<DropdownMenuEntry<dynamic>> likert = [
      DropdownMenuEntry(value: "Strongly disagree", label: "Strongly disagree"), 
      DropdownMenuEntry(value: "Disagree", label: "Disagree"), 
      DropdownMenuEntry(value: "Slightly disagree", label: "Slightly disagree"), 
      DropdownMenuEntry(value: "Neutral", label: "Neutral"), 
      DropdownMenuEntry(value: "Slightly agree", label: "Slightly agree"), 
      DropdownMenuEntry(value: "Agree", label: "Agree"), 
      DropdownMenuEntry(value: "Strongly agree", label: "Strongly agree"), 
    ];

    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [

        //reflection questionnaire
        Text(name,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 5,),
        Text(instructions,
          style: Theme.of(context).textTheme.bodyMedium!,
          textAlign: TextAlign.center,
        ),
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: questions.length,
          itemBuilder: (context, index) {
            return Selector(
              text: questions[index]['question'],
              dropdownController: questions[index]['controller'],
              dropdownOptions: customOptions == null ? likert : customOptions!,
              redBg: questions[index]['empty'] != null && questions[index]['empty'],
            );
          },
        ),
        SizedBox(height: 30,),
      ],
      
    );
  }
}


class Selector extends StatelessWidget {
  const Selector({super.key, required this.text, required this.dropdownController, required this.dropdownOptions, this.redBg=false});

  final String text;
  final TextEditingController dropdownController;
  final List<DropdownMenuEntry<dynamic>> dropdownOptions;
  final bool redBg;
  
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge!,
          ),
          SizedBox(width: 10,),
          DropdownMenu(
            controller: dropdownController,
            initialSelection: dropdownController.text,
            dropdownMenuEntries: dropdownOptions,
            menuStyle: MenuStyle(
              backgroundColor: WidgetStateColor.resolveWith(
                (Set<WidgetState> states) {
                  return Color.fromARGB(255, 249, 241, 237);
                }
              )
            ),
          ),
          redBg && dropdownController.text.isEmpty ? Text('Please fill out this question',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Color.fromARGB(255, 209, 108, 103)
            ),
          ) : Container()
        ],
      ),
    );
  }
}