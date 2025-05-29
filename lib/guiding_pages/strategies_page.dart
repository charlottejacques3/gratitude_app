import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gratitude_app/guiding_pages/final_page.dart';
import 'package:gratitude_app/utilities/globals.dart';
import 'strategy_widgets.dart';


class StrategiesPage extends StatefulWidget {
  final Map<String, dynamic> initialReframingLogs;
  const StrategiesPage({super.key, required this.initialReframingLogs});

  @override
  State<StrategiesPage> createState() => _StrategiesPageState();
}


class _StrategiesPageState extends State<StrategiesPage> {

  //finish humorous imaging
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(Globals.group)
                                                          .child(FirebaseAuth.instance.currentUser!.uid)
                                                          .child('ReframingStrategies');
  Map<String, dynamic> reframingLogs = {};
  Map<String, List<String>> strategies = {
    'Substitution': ['Is there a more positive way to look at this situation?', 'For each negative thought, try to substitute a more positive and realistic thought below.'],
    'Double Standard Technique': ['If a close friend was having the same problem, would you talk to them in the same way that you are talking to yourself?', 'Why not?', 'What would you tell your friend instead?'],
    'Examine the Evidence': ['What is the evidence against this belief?', 'How can you weigh this evidence against the evidence for this belief?', 'Given the evidence, can you try to develop a more rational thought?'],
    'Survey Technique': ['If I asked a close friend how they felt about my situation, would they agree with my thoughts?', 'What would they say instead? If you feel comfortable, you can ask someone.'],
    'Reattribution': ['Is there concrete evidence that I am solely to blame for this problem?', 'What are some other factors that contributed to the situation turning out the way it did?'],
    'Socratic Questioning': ['What are some questions you could ask yourself to find inconsistencies in your thinking? For example, are you making assumptions or generalizations?', 'What kind of inconsistencies or falsehoods can you find by asking these questions?'],
    'Thinking in Shades of Grey': ['Can you identify any black-and-white thoughts you are currently having (e.g. thinking of your life as a total failure)?', 'Are these extreme thoughts absolutely true?', "Try to develop some more rational alternative thoughts. For example, maybe you're not a failure, you just need more practice."],
    'Semantic Method': ['Can you identify any extreme or unhelpful language that you are using, such as "should", "always", or "never"?', 'Can you replace these terms with more neutral wording?'],
    'Future Projection': ['Imagine a future version of yourself who has recovered from what you are going through at the moment. What would they say to you now?'],
    'Humorous Imaging': ['If you think this would be beneficial to you, try to imagine a humorous event relating to your situation. It can be real or made up. For example, if you are worried about an exam, you could picture a giraffe bursting into the room during the exam period.', 'Imagine this humorous scene with as much detail as you can. What is the scene you are picturing?'],
    'Cost-Benefit Analysis': ['Are there any benefits to thinking in this way?', 'What are the costs of thinking in this way?', 'How do the costs and benefits measure up?'],
    'Image Substitution': ['Try to replace the negative or frightening images in your head with a more peaceful, positive one. What image are you picturing?'],
  };

  List<PromptWidget> promptWidgets = [];
  
  Map<String, List<String>> strategiesPerDistortion = {
    'All-or-Nothing Thinking': ['Substitution', 'Double Standard Technique', 'Examine the Evidence', 'Thinking in Shades of Grey', 'Semantic Method', 'Cost-Benefit Analysis'],
    'Overgeneralization': ['Substitution', 'Double Standard Technique', 'Examine the Evidence', 'Survey Technique', 'Cost-Benefit Analysis'],
    'Mental Filter': ['Substitution', 'Double Standard Technique', 'Examine the Evidence', 'Reattribution', 'Thinking in Shades of Grey', 'Semantic Method', 'Cost-Benefit Analysis'],
    'Discounting the Positive': ['Substitution', 'Double Standard Technique', 'Examine the Evidence', 'Thinking in Shades of Grey', 'Cost-Benefit Analysis',],
    'Fortune Telling': ['Substitution', 'Double Standard Technique', 'Examine the Evidence', 'Survey Technique', 'Socratic Questioning', 'Humorous Imaging', 'Future Projection', 'Cost-Benefit Analysis', 'Image Substitution'],
    'Mind Reading': ['Substitution', 'Double Standard Technique', 'Examine the Evidence', 'Survey Technique', 'Socratic Questioning', 'Humorous Imaging', 'Cost-Benefit Analysis', 'Image Substitution'],
    'Magnification and Minimization': ['Substitution', 'Double Standard Technique', 'Examine the Evidence', 'Thinking in Shades of Grey', 'Semantic Method', 'Cost-Benefit Analysis', 'Image Substitution'],
    'Emotional Reasoning': ['Substitution', 'Double Standard Technique', 'Examine the Evidence', 'Survey Technique', 'Socratic Questioning', 'Semantic Method', 'Future Projection', 'Humorous Imaging', 'Cost-Benefit Analysis',],
    'Should Statements': ['Substitution', 'Double Standard Technique', 'Examine the Evidence', 'Reattribution', 'Socratic Questioning', 'Thinking in Shades of Grey', 'Semantic Method', 'Future Projection', 'Humorous Imaging', 'Cost-Benefit Analysis',],
    'Labeling': ['Substitution', 'Double Standard Technique', 'Examine the Evidence', 'Reattribution', 'Socratic Questioning', 'Thinking in Shades of Grey', 'Semantic Method', 'Future Projection', 'Humorous Imaging', 'Cost-Benefit Analysis',],
    'Blame': ['Substitution', 'Double Standard Technique', 'Examine the Evidence', 'Reattribution', 'Socratic Questioning', 'Thinking in Shades of Grey', 'Semantic Method', 'Future Projection', 'Cost-Benefit Analysis',],
  };

  @override
  void initState() {
    super.initState();
    setState(() {
      reframingLogs = widget.initialReframingLogs;
    });
    addStrategy();
  }

  @override
  void dispose() {
    super.dispose();
    for (final activity in promptWidgets) {
      for (final controller in activity.controllers) {
        controller.dispose();
      }
    }
  }

  PromptWidget pickStrategy(int index) {
    print('TOP');

    //pick a random trap
    List<String> selectedTraps = reframingLogs['thought_traps'];
    //default strategies if nothing chosen
    List<String> strategyOptions = ['Substitution', 'Double Standard Technique', 'Examine the Evidence', 'Cost-Benefit Analysis'];
    if (selectedTraps.isNotEmpty) {
      int trapNum = Random().nextInt(selectedTraps.length);

      print('BEFORE PICKING');
      //pick a random strategy
      if (strategiesPerDistortion[selectedTraps[trapNum]] != null) {
        strategyOptions = strategiesPerDistortion[selectedTraps[trapNum]]!;
      } 
    }
    
    int strategyNum = Random().nextInt(strategyOptions.length);
    print('STRATEGY: ${strategyOptions[strategyNum]}');
    List<String> selectedStrategyPrompts = strategies[strategyOptions[strategyNum]]!;

    //create text editing controllers
    List<TextEditingController> newControllers = [];
    for (int i = 0; i < selectedStrategyPrompts.length; i++) {
      newControllers.add(TextEditingController());
    }

    //return new prompt widget
    return PromptWidget(
      title: strategyOptions[strategyNum],
      controllers: newControllers, 
      prompt: selectedStrategyPrompts,
      refresh: () {
        print('refresh button: $index');
        replaceStrategy(index);
      }
    );
  }

  void addStrategy() {
    int index = promptWidgets.length;
    setState(() {
      promptWidgets.add(pickStrategy(index));
    });
  }

  void replaceStrategy(int index) {
    print('hello, index: $index');
    PromptWidget newStrategy = pickStrategy(index);
    setState(() {
      promptWidgets[index] = newStrategy;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: 
          Text('Log Gratitude',
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
            Text("Good job recognizing your cognitive distortions, that's an important step.",
              style: Theme.of(context).textTheme.titleMedium!,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30,),
            Text("Now let's try some activities to help you overcome these distortions.",
              style: Theme.of(context).textTheme.titleMedium!,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30,),

            //display prompts
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: promptWidgets.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                      child: promptWidgets[index]
                    ),
                  ),
                );
              },
            ),

            //buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                      
                //add another actiivity
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.0, right: 4.0),
                    child: ElevatedButton(
                      onPressed: () => addStrategy(),
                      child: Text("New Activity",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                      
                //next button
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                    child: ElevatedButton(
                      child: Text("Next",
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        List<String> logs = [];
                        for (final log in promptWidgets) { //go through all logs
                          
                          //get full text including prompt text
                          String wholeLog = '';
                          bool emptyLogs = true; 
                          for (var i = 0; i < log.prompt.length; i++) {
                            wholeLog += log.prompt[i];
                            if (i < log.controllers.length) {
                              if (log.controllers[i].text != '') {
                              wholeLog += ' ${log.controllers[i].text} ';
                              emptyLogs = false; 
                              }
                            }
                          }
                          //add to list if not empty
                          if (!emptyLogs) {
                            logs.add(wholeLog);
                          }
                        }
                        
                        //send info to the database
                        reframingLogs['reframed_thoughts'] = logs;
                        try {
                          dbRef.push().set(reframingLogs); 
                        } catch(e) {
                          print('error writing data: $e');
                        }

                        //go to next page
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => FinalPage())
                        );
                      }, 
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}