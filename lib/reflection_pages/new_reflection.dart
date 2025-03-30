import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class NewReflectionPage extends StatefulWidget {
  const NewReflectionPage({super.key, required this.type});

  final String type;

  @override
  State<NewReflectionPage> createState() => _NewReflectionPageState();
}


class _NewReflectionPageState extends State<NewReflectionPage> {
  
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('users')
                                                          .child(FirebaseAuth.instance.currentUser!.uid)
                                                          .child('Reflections');
  List<PromptWidget> prompts = [];
  String reflectionTitle = '';

  //initialize list of prompts based on the reflection type
  @override
  void initState() {
    super.initState();
    dbRef.keepSynced(true);

    //reflect on challenges
    if (widget.type.compareTo('challenges') == 0) {
      reflectionTitle = 'Reflect on Challenges';
      prompts = [
          PromptWidget(
            promptText: 'What is a challenge in your life that you have overcome?', 
            logController: TextEditingController()
          ),
          PromptWidget(
            promptText: 'Retrospectively, can you now see any positive consequences of this challenge? Have you learned something from it, or has it made you grow as a person?', 
            logController: TextEditingController()
          ),
          PromptWidget(
            promptText: 'How can you be grateful for this challenging experiences?', 
            logController: TextEditingController()
          ),
        ];
    }

    //gratitude letter
    else if (widget.type.compareTo('letter') == 0) {
      reflectionTitle = 'Gratitude Letter';
      prompts = [
          PromptWidget(
            promptText: 'Who is a person in your life who means a lot to you?', 
            logController: TextEditingController()
          ),
          PromptWidget(
            promptText: 'Why are you grateful for this person? How do they improve your life?', 
            logController: TextEditingController()
          ),
          PromptWidget(
            promptText: 'Write a gratitude letter to this person, thanking them for being in your life.', 
            logController: TextEditingController()
          ),
        ];
    }
    
    //reflect on the little things
    else if (widget.type.compareTo('little_things') == 0) {
      reflectionTitle = 'Reflect on the Little Things';
      prompts = [
          PromptWidget(
            promptText: 'What is something small in your everyday life that you tend to take for granted?', 
            logController: TextEditingController()
          ),
          PromptWidget(
            promptText: 'How has this positively affected your life?', 
            logController: TextEditingController()
          ),
          PromptWidget(
            promptText: 'How can you be more grateful for this in your day-to-day life?', 
            logController: TextEditingController()
          ),
        ];
    }
    
    //independent reflection
    else if (widget.type.compareTo('independent') == 0) {
      reflectionTitle = 'Independent Reflection';
      prompts = [PromptWidget(
        promptText: 'Reflect on anything in your life that brings you gratitude.', 
        logController: TextEditingController()
      )];
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
        padding: const EdgeInsets.all(8.0),
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
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
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
                //send to database
                try {
                  print("trying to send");
                  dbRef.push().set(reflectionLog);
                } catch (e) {
                  print('error writing data: $e');
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
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 20)
      ],
    );
  }
}