import 'dart:math';

import 'package:flutter/material.dart';

import 'strategy_widgets.dart';


class StrategiesPage extends StatefulWidget {
  final Map<String, dynamic> initialReframingLogs;
  const StrategiesPage({super.key, required this.initialReframingLogs});

  @override
  State<StrategiesPage> createState() => _StrategiesPageState();
}


class _StrategiesPageState extends State<StrategiesPage> {

  Map<String, dynamic> reframingLogs = {};
  Map<String, List<String>> strategies = {
    'Substitution': ['Is there a more positive way to look at this situation?', 'For each negative thought, try to substitute a more positive and realistic thought below.'],
    'Double Standard Technique': ['If a close friend was having the same problem, would you talk to them in the same way that you are talking to yourself?', 'Why not?', 'What would you tell your friend instead?'],
    'Examine the Evidence': ['What is the evidence against this belief?', 'How can you weigh this evidence against the evidence for this belief?', 'Develop a more rational thought'],
    'Survey Technique': ['If I asked a close friend how they felt about my situation, would they agree with my thoughts?', 'What would they say instead? If you feel comfortable, you can ask someone.'],
    'Reattribution': ['Is there concrete evidence that I am solely to blame for this problem?', 'What are some other factors that contributed to the situation turning out the way it did?'],
  };

  List<PromptWidget> promptWidgets = [];
  
  //haven't got to thinking in shades of grey
  Map<String, List<String>> strategiesPerDistortion = {
    'All-or-Nothing Thinking': ['Substitution', 'Double Standard Technique', 'Examine the Evidence', 'Thinking in Shades of Gray', 'Semantic Method', 'Cost-Benefit Analysis'],
    'Overgeneralization': ['Substitution', 'Double Standard Technique', 'Examine the Evidence', 'Survey Technique', 'Defining Terms', 'Cost-Benefit Analysis'],
    'Mental Filter': ['Substitution', 'Double Standard Technique', 'Examine the Evidence', 'Reattribution', 'Cost-Benefit Analysis'],
    'Discounting the Positive': ['Substitution', 'Double Standard Technique', 'Examine the Evidence', 'Cost-Benefit Analysis',],
    'Fortune Telling': ['Substitution', 'Double Standard Technique', 'Examine the Evidence', 'Survey Technique', 'Find Inconsistencies', 'Future Projection', 'Cost-Benefit Analysis', 'Image Substitution'],
    'Mind Reading': ['Substitution', 'Double Standard Technique', 'Examine the Evidence', 'Survey Technique', 'Find Inconsistencies', 'Cost-Benefit Analysis', 'Image Substitution'],
    'Magnification and Minimization': ['Substitution', 'Double Standard Technique', 'Examine the Evidence', 'Cost-Benefit Analysis', 'Image Substitution'],
    'Emotional Reasoning': ['Substitution', 'Double Standard Technique', 'Examine the Evidence', 'Survey Technique', 'Find Inconsistencies', 'Future Projection', 'Humorous Imaging', 'Cost-Benefit Analysis',],
    'Should Statements': ['Substitution', 'Double Standard Technique', 'Examine the Evidence', 'Reattribution', 'Find Inconsistencies', 'Future Projection', 'Humorous Imaging', 'Cost-Benefit Analysis',],
    'Labeling': ['Substitution', 'Double Standard Technique', 'Examine the Evidence', 'Reattribution', 'Find Inconsistencies', 'Future Projection', 'Humorous Imaging', 'Cost-Benefit Analysis',],
    'Blame': ['Substitution', 'Double Standard Technique', 'Examine the Evidence', 'Reattribution', 'Find Inconsistencies', 'Future Projection', 'Cost-Benefit Analysis',],
  };

  @override
  void initState() {
    super.initState();
    setState(() {
      reframingLogs = widget.initialReframingLogs;
    });
    pickStrategy();
  }

  void pickStrategy() {
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

    //create new prompt widget
    setState(() {
      promptWidgets.add(PromptWidget(
        title: strategyOptions[strategyNum],
        controllers: newControllers, 
        prompt: selectedStrategyPrompts,
        refresh: () {},
      ));
    });
  }

  void addStrategy() {

  }

  void replaceStrategy() {

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

            //add another activity
            ElevatedButton(
              onPressed: () => pickStrategy(),
              child: Text('New Activity'),
            ),

            //bring back to main page
            ElevatedButton(
              onPressed: () {
                for(var i = 0; i < 4; i++) {
                  Navigator.pop(context);
                }
                Navigator.pop(context, {'guided':true});
              }, 
              child: Text("Let's do it!"))
          ],
        ),
      )
    );
  }
}