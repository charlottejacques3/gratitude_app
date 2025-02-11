import 'package:flutter/material.dart';
import 'dart:math';

//database imports
import 'package:firebase_database/firebase_database.dart';


class ReframingPage extends StatefulWidget {

  final Map<String, dynamic> initialReframingLogs;

  const ReframingPage({super.key, required this.initialReframingLogs});

  @override
  State<ReframingPage> createState() => _ReframingPageState();
}


class _ReframingPageState extends State<ReframingPage> {

  TextEditingController logController = TextEditingController();
  bool needHelp = false;

  List<PromptWidget> prompt_widgets = [];
  Map<String, dynamic> reframingLogs = {};
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('NegativeEmotionLogs');

  //prompts
  List<List<String>> prompts = [["I can't control ", " However, I can control "],
                                ["Although this situation is challenging, at least "],
                                ["Although it may seem this way in my brain, I don't actually have any evidence that "],
                                ["If a close friend was in my situation, I would tell them "]];

  
  //initialize reframingLogs with values passed
  @override
  void initState() {
    super.initState();
    setState(() {
      reframingLogs = widget.initialReframingLogs;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: 
          Text('Log Gratitude',
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
      ),
      body: CustomScrollView(
        slivers: [

          //prompting text
          SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 8),
            sliver: SliverToBoxAdapter(
              child: Text("Good job! Now that you've caught some of your thought traps, let's try to reframe the situation.",
                style: Theme.of(context).textTheme.bodyLarge!,
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
                    prompt_widgets[index]
                ]);
              },
              childCount: prompt_widgets.length,
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
                            onPressed: () {

                              //pick a random prompt + make controllers
                              final randomNum = Random().nextInt(prompts.length);
                              List<String> selectedPrompt = prompts[randomNum];
                              List<TextEditingController> newControllers = [];
                              for (int i = 0; i < prompts.length; i++) {
                                newControllers.add(TextEditingController());
                              }

                              //create a new prompt widget
                              setState(() {
                                prompt_widgets.add(PromptWidget(controllers: newControllers, prompt: selectedPrompt));
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
                      // padding: EdgeInsets.only(left: 4.0, right: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                        child: ElevatedButton(
                          child: Text("Next",
                            textAlign: TextAlign.center,
                          ),
                          onPressed: () {
                            List<String> logs = [];
                            for (final log in prompt_widgets) { //go through all logs
                              
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
                                print(wholeLog);
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
                          }, 
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          )
        ]
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: prompt.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Text(prompt[index]),
              TextFormField(controller: controllers[index])
            ],
          );
        },
      ),
    );
  }
}