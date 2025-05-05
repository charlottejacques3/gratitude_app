import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_multi_formatter/extensions/exports.dart';
import 'package:gratitude_app/guiding_pages/final_page.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ReframingPage extends StatefulWidget {

  final Map<String, dynamic> initialReframingLogs;

  const ReframingPage({super.key, required this.initialReframingLogs});

  @override
  State<ReframingPage> createState() => _ReframingPageState();
}


class _ReframingPageState extends State<ReframingPage> {

  TextEditingController logController = TextEditingController();
  bool needHelp = false;
  bool allowAI = false;

  List<PromptWidget> promptWidgets = [];
  Map<String, dynamic> reframingLogs = {};
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('users')
                                                          .child(FirebaseAuth.instance.currentUser!.uid)
                                                          .child('NegativeEmotionLogs');

  //prompts
  List<List<String>> prompts = [["I can't control ", " However, I can control "],
                                ["Although this situation is challenging, at least "],
                                ["Although it may seem this way in my brain, I don't actually have any evidence that "],
                                ["If a close friend was in my situation, I would tell them "]];
                                

  
  //initialize reframingLogs with values passed, and check AI settings
  @override
  void initState() {
    super.initState();
    setState(() {
      reframingLogs = widget.initialReframingLogs;
    });
    checkAIAllowed();
  }

   void checkAIAllowed() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? ai = prefs.getBool('allow_ai');
    if (ai != null) {
      setState(() {
        allowAI = ai;
      });
    }
  }

  Future<List<String>> generateAIContent() async {
    
    final instructions = Content.text('''
      <OBJECTIVE_AND_PERSONA>
        You are supportive and helping users to work through their negative emotions. 
        You are given a log of negative emotions and events, and a list of cognitive-behavioural therapy thought traps that the user is falling into.
        Your task is to generate a fill-in-the-blank prompt, written in the first person, to help the user reframe their emotions.
        Make the prompts 1-2 sentences in length, with 1-2 fill-in-the-blanks - however, do not put more than one fill-in-the-blank per sentence.
        Also, make sure the last sentence has a fill-in-the-blank.
        ONLY put periods at the end of the sentence if the sentence does not contain a fill-in-the-blank.
        Emphasize self-compassion and use reframing techniques from the cognitive-behavioural therapy thought traps specified in the input.
      </OBJECTIVE_AND_PERSONA>

      <INSTRUCTIONS>
        To complete the task, you need to follow these steps:
        1. Read through the log an understand what the user is struggling with.
        2. Based on the given CBT thought traps (or other CBT techniques), come up with a supportive reframing prompt.
      </INSTRUCTIONS>

      <CONSTRAINTS>
        Make sure to:
        1. Don't emphasize any sort of regret about the situation.
        2. Don't necessarily prompt action, instead, prompt a change in mindset. For example, this is NOT a good prompt:
          "In the future, I will _______" 
        3. DO NOT prompt the user to think about what the negative situation means. Do not put "Instead, it means _____ We want to avoid this because it could send the user into more of a spiral.
        3. Do make the prompts relatively simple - remember that this is a person in a vulnerable state.
      </CONSTRAINTS>

      <FEW_SHOT_EXAMPLES>
        Here is an example:
        1. Lost job
        Input: "Log: I was fired from my job, and I feel worthless. I feel like a failure, and I'll never amount to anything.
                Thought traps: [Catastrophizing, All-or-nothing thinking, Labeling, Overgeneralization]"
        Output: Instead of making the generalization that I'll never amount to anything, I can recognize that _______
        2. Worrying what other people think
        Input: "Log: I was hanging out with my friends today and I feel like they hate me. I don't think anybody likes me.
                Thought traps: [Mind reading]"
        Output: Even though my brain is telling me that my friends don't like me, I don't have any evidence of this. Here is some evidence that they DO like me: _______
        3. Breakup
        Input: "Log: My boyfriend just broke up with me. I must be a terrible person.
                Thought traps: [Personalization]"
        Output: It's okay to feel sad, but I can't control that my boyfriend broke up with me, and it may not be a direct reflection of me. However, I can control _______

        Here are some more general prompts, not tailored to any specific situation. However, something similar to these would be good.
        1. I can't control _______ However, I can control _______
        2. Although this situation is challenging, at least _______
        3. Although it may seem this way in my brain, I don't actually have any evidence that _______
        4. If a close friend was in my situation, I would tell them _______
      </FEW_SHOT_EXAMPLES>

      <SAFEGUARDS>
        DO NOT end the prompt with "instead this means _______" This can cause the user to spiral further, which we do NOT want.
      </SAFEGUARDS>
    ''');
    final model = FirebaseVertexAI.instance.generativeModel(model: 'gemini-2.0-flash', systemInstruction: instructions);

    //build prompt from logs
    final prompt = [Content.text("Log: ${reframingLogs['negative_emotions']} Thought traps: ${reframingLogs['thought_traps']}")];

    final response = await model.generateContent(prompt);

    //split string into separate prompts
    String formattedResponse = response.text!;
    while (formattedResponse.contains('_______.')) {
      int periodIndex = formattedResponse.indexOf('_______.') + 7;
      formattedResponse.removeCharAt(periodIndex); //remove extra period
    }
    List<String> split = response.text!.trim().split('_______');
    List<String> prompts = [];
    for (final str in split) {
      if (str.isNotEmpty) {
        prompts.add(str);
      }
    }
    return prompts;
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
        child: CustomScrollView(
          slivers: [
        
            //prompting text
            SliverPadding(
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 8),
              sliver: SliverToBoxAdapter(
                child: Text("Good job! Now that you've caught some of your thought traps, let's try to reframe the situation.",
                  style: Theme.of(context).textTheme.titleMedium!,
                  textAlign: TextAlign.center,
                ),
              )
            ),
        
            !needHelp ?
            //logging space
            SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: SliverToBoxAdapter(
                child: TextFormField(
                  controller: logController,
                  keyboardType: TextInputType.multiline,
                  minLines: 5,
                  maxLines: 15,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
              ),
            )
        
            : SliverList(
              delegate: SliverChildBuilderDelegate( 
                (context, index) {
                  return Column (
                    children: [
                      promptWidgets[index],
                      SizedBox(height: 10,)
                  ]);
                },
                childCount: promptWidgets.length,
              )
            ),
        
            //buttons
            SliverToBoxAdapter(
              child: Container(
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                            
                      //help button
                      Flexible(
                        fit: FlexFit.loose,
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.0, right: 4.0),
                          child: Align(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () async {
        
                                //pick a random prompt + make controllers
                                List<String> selectedPrompt = [];
                                bool connected = await InternetConnection().hasInternetAccess;
                                if (allowAI && connected) {
                                  selectedPrompt = await generateAIContent();
                                } else {
                                  final randomNum = Random().nextInt(prompts.length);
                                  selectedPrompt = prompts[randomNum];
                                }
                                List<TextEditingController> newControllers = [];
                                for (int i = 0; i < prompts.length; i++) {
                                  newControllers.add(TextEditingController());
                                }

                                //ai no wifi disclaimer
                                if (allowAI && !connected) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('To enable AI prompting, please connect to the internet')),
                                  );
                                }
        
                                //create a new prompt widget
                                setState(() {
                                  promptWidgets.add(PromptWidget(controllers: newControllers, prompt: selectedPrompt));
                                  needHelp = true;
                                });
                              },
                              child: Text("Give me some help with this",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                            
                      //next button
                      Flexible(
                        fit: FlexFit.loose,
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
                                    wholeLog += log.controllers[i].text;
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
                ),
            )
          ]
        ),
      )
    );
  }
}



//prompts
class PromptWidget extends StatelessWidget {

  const PromptWidget({super.key, required this.controllers, required this.prompt}); 

  final List<TextEditingController> controllers;
  final List<String> prompt;

  @override
  Widget build (BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        border: Border.all(
          width: 0.5,
          color: Colors.grey
        )
      ),
      //iterate through all fill-in-the-blanks
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: prompt.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(prompt[index], 
                  style: Theme.of(context).textTheme.bodyLarge!,
                  textAlign: TextAlign.center,
                ),
                TextFormField(
                  controller: controllers[index],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}