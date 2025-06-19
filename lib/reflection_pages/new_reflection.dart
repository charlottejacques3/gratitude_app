import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gratitude_app/utilities/widgets.dart';
import 'package:gratitude_app/utilities/globals.dart';


class NewReflectionPage extends StatefulWidget {
  const NewReflectionPage({super.key, required this.type, this.preloadedResponses});

  final String type;
  final Map<dynamic, dynamic>? preloadedResponses;

  @override
  State<NewReflectionPage> createState() => _NewReflectionPageState();
}


class _NewReflectionPageState extends State<NewReflectionPage> {
  
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(Globals.group)
                                                          .child(FirebaseAuth.instance.currentUser!.uid)
                                                          .child('Reflections');
  List<PromptWidget> prompts = [];
  String reflectionTitle = '';
  List<String> preloaded = [];

  //initialize list of prompts based on the reflection type
  @override
  void initState() {
    super.initState();
    dbRef.keepSynced(true);
    setState(() {
      reflectionTitle = widget.type;
    });

    //add preloaded responses
    if (widget.preloadedResponses != null) {
      for(final resp in widget.preloadedResponses!['responses']) {
        setState(() {
          preloaded.add(resp['answer']);
        });
      }
    }

    //reflect on challenges
    if (widget.type.compareTo('Reflect on Challenges') == 0) {
      prompts = [
          PromptWidget(
            promptText: 'What is a challenge in your life that you have overcome?', 
            logController: TextEditingController(text: preloaded.isNotEmpty ? preloaded[0] : '')
          ),
          PromptWidget(
            promptText: 'Retrospectively, can you now see any positive consequences of this challenge? Have you learned something from it, or has it made you grow as a person?', 
            logController: TextEditingController(text: preloaded.isNotEmpty ? preloaded[1] : '')
          ),
          PromptWidget(
            promptText: 'How can you be grateful for this challenging experience?', 
            logController: TextEditingController(text: preloaded.isNotEmpty ? preloaded[2] : '')
          ),
        ];
    }

    //gratitude letter
    else if (widget.type.compareTo('Gratitude Letter') == 0) {
      prompts = [
          PromptWidget(
            promptText: 'Who is a person in your life who means a lot to you?', 
            logController: TextEditingController(text: preloaded.isNotEmpty ? preloaded[0] : '')
          ),
          PromptWidget(
            promptText: 'Why are you grateful for this person? How do they improve your life?', 
            logController: TextEditingController(text: preloaded.isNotEmpty ? preloaded[1] : '')
          ),
          PromptWidget(
            promptText: 'Write a gratitude letter to this person, thanking them for being in your life.', 
            logController: TextEditingController(text: preloaded.isNotEmpty ? preloaded[2] : '')
          ),
        ];
    }
    
    //reflect on the little things
    else if (widget.type.compareTo('Reflect on the Little Things') == 0) {
      prompts = [
          PromptWidget(
            promptText: 'What is something small in your everyday life that you tend to take for granted?', 
            logController: TextEditingController(text: preloaded.isNotEmpty ? preloaded[0] : '')
          ),
          PromptWidget(
            promptText: 'How has this positively affected your life? What would happen if this little thing was absent from your daily life?', 
            logController: TextEditingController(text: preloaded.isNotEmpty ? preloaded[1] : '')
          ),
          PromptWidget(
            promptText: 'How can you be more grateful for this in your day-to-day life?', 
            logController: TextEditingController(text: preloaded.isNotEmpty ? preloaded[2] : '')
          ),
        ];
    }
    
    //independent reflection
    else if (widget.type.compareTo('Independent Reflection') == 0) {
      prompts = [PromptWidget(
        promptText: 'Reflect on anything in your life that brings you gratitude.', 
        logController: TextEditingController(text: preloaded.isNotEmpty ? preloaded[0] : '')
      )];
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (final prompt in prompts) {
      prompt.logController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: 
          Text(reflectionTitle,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold
            ),
          ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          shrinkWrap: true,
          children: [

            //list of prompts
            ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: NeverScrollableScrollPhysics(),
              itemCount: prompts.length,
              itemBuilder: (context, index) {
                return prompts[index];
              },
            ),

            //send reflections to database
            SwitchedColourButton(
              text: 'Save',
              onClick: () {
                //create initial map
                Map<String, dynamic> reflectionLog = {
                  'date': DateTime.now().toIso8601String(),
                  'type': reflectionTitle
                };
                List<Map<String, String>> responses = [];
                //loop through all prompts
                for (final prompt in prompts) {
                  //add to dictionary
                  Map<String, String> response = {'prompt': prompt.promptText, 'answer': prompt.logController.text};
                  responses.add(response);
                }
                reflectionLog['responses'] = responses;

                //update in database
                if (widget.preloadedResponses != null) {
                  dbRef.update({
                    widget.preloadedResponses!['id']: reflectionLog
                  });
                  Navigator.pop(context);
                }

                //create new log
                else {
                  try {
                    dbRef.push().set(reflectionLog);
                  } catch (e) {
                    print('error writing data: $e');
                  }
                }

                Navigator.pop(context);
              } 
            )
          ],
        ),
      )
    );
  }
}


//prompt widget
class PromptWidget extends StatelessWidget {

  const PromptWidget({super.key, required this.promptText, required this.logController});

  final String promptText;
  final TextEditingController logController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(promptText,
          style: Theme.of(context).textTheme.bodyLarge!,
          textAlign: TextAlign.center,

        ),
        SizedBox(height: 8),
    
        //logging space
        TextFormField(
          controller: logController,
          keyboardType: TextInputType.multiline,
          minLines: 3,
          maxLines: 15,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 20)
      ],
    );
  }
}