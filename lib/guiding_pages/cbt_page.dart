import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gratitude_app/guiding_pages/strategies_page.dart';


class CBTPage extends StatefulWidget {

  final Map<String, dynamic> initialReframingLogs;

  const CBTPage({super.key, required this.initialReframingLogs});

  @override
  State<CBTPage> createState() => _CBTPageState();
}


class _CBTPageState extends State<CBTPage> {

  //thought traps selection
  List<String> thoughtTraps = ['Magnification and Minimization', 'All-or-Nothing Thinking', 'Emotional Reasoning', 'Mind Reading', 'Overgeneralization', 'Blame', 'Labeling', 'Should Statements', 'Fortune Telling', 'Discounting the Positive', 'Mental Filter'];
  Map<String, String> thoughtTrapsDetails = {
    'Magnification and Minimization': 'Magnification is when we predict that the absolute worst-case scenario will happen. For example, after a bad grade on a test, we might start thinking that we will be kicked out of school and will never find a job. Minimization, on the other hand, is when we downplay the positive aspects of a situation.',
    'All-or-Nothing Thinking': 'All-or-nothing thinking is when we look at situations as being strictly good or bad, and are unable to see any nuance. This is a common thought trap to fall into after experiencing a small setback in a goal - we might believe that one mistake means we have failed, when in reality this is not the case.',
    'Emotional Reasoning': 'Emotional reasoning is a distortion where we take our emotions as a fact, regardless of any evidence to the contrary. For example, if we feel stupid, we might take this as fact, even when it is not.', 
    'Mind Reading': 'Mind-reading is when we believe that we know what other people are thinking, despite having no evidence to support these claims. For example, we might believe somebody does not like us, even though they have never said anything supporting this idea.', 
    'Overgeneralization': 'Overgeneralization is when we come to the conclusion that one negative event is actually part of a series of unending negative events. For example, if we have one bad day, we might start to think that we will be miserable forever.',
    'Blame': 'Blame is when we assume responsibility for any negative event even if it is not our fault, or there were multiple factors at play. For example, if somebody is upset, we might believe that they are angry at us, when really they might just be having a bad day.',
    'Labeling': 'Labeling is a form of generalization, and occurs when we give ourselves or someone else a negative label after a single mistake.',
    'Should Statements': '"Should" statements come from the belief that we, our other people or things, should be a certain way, and may also contain words such as "must" or "have to". In many cases, they represent unrealistic expectations we impose on ourselves, such as "I should be productive every day". However, "should" statements are unhelpful in actually achieving our goals, and often leave us feeling anxious and guilty.',
    'Fortune Telling': 'Fortune telling is when we imagine that bad things are going to happen, despite having no evidence to support this prediction.',
    'Discounting the Positive': 'Discounting the positive is when we ignore or dismiss positive information or events. For example, if we do well on a project at work, we might tell ourselves, "But that was easy, anybody could have done it".',
    'Mental Filter': "A mental filter is when we focus exclusively on a single (typically negative) detail, and ignore the big picture. For example, if we posted a picture on social media and received many positive comments but one negative comment, we might focus exclusively on the negative."
  };
  Set<int> selectedIndexes = {};
  Map<String, dynamic> reframingLogs = {};
  
   DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('users')
                                                          .child(FirebaseAuth.instance.currentUser!.uid)
                                                          .child('NegativeEmotionLogs');

  //initialize reframingLogs with values passed from previous pages
  @override
  void initState() {
    super.initState();
    setState(() {
      reframingLogs = widget.initialReframingLogs;
    });
  }

  //add data to reframingLogs map to send to database or next page
  void dataToMap() {
    List<String> selectedTraps = [];
    for (final index in selectedIndexes) {
      selectedTraps.add(thoughtTraps[index]);
    }
    reframingLogs['thought_traps'] = selectedTraps;
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
        padding: const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
        child: ListView(
          children: [
        
            //prompting text
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text("Good job getting that off your chest.",
                style: Theme.of(context).textTheme.bodyLarge!,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text("Often, our thinking can fall into cognitive distortions called thought traps.",
                style: Theme.of(context).textTheme.bodyLarge!,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text("Reflecting on the negative thoughts you just logged, can you identify any of these thought traps?",
                style: Theme.of(context).textTheme.bodyLarge!,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text("Tap the icon to learn what these thought traps mean.",
                style: Theme.of(context).textTheme.bodySmall!,
                textAlign: TextAlign.center,
              ),
            ),
        
            //multi-select thought traps
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: thoughtTraps.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    title: Text(thoughtTraps[index]),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey, width: 0.5),
                      borderRadius: BorderRadius.circular(5),
                    ), 
                  
                    //info button
                    trailing: GestureDetector(
                      onTap: () => showDialog(
                        context: context, 
                        builder: (BuildContext context) => Dialog(
                          backgroundColor: Color.fromARGB(255, 250, 240, 230),
                          child: Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(thoughtTraps[index],
                                  style: Theme.of(context).textTheme.headlineSmall!
                                ),
                                SizedBox(height: 15),
                                Text(thoughtTrapsDetails[thoughtTraps[index]]!, 
                                  textAlign: TextAlign.center
                                ),
                                SizedBox(height: 20,),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  }, 
                                  child: Text('Close')
                                )
                              ],
                            ),
                          ),
                        )
                      ),
                      child: Icon(Icons.info)
                    ),
                  
                    //select it
                    onTap: () {
                      setState(() {
                        if (selectedIndexes.contains(index)) {
                          selectedIndexes.remove(index);
                        } else {
                          selectedIndexes.add(index);
                        }
                      });
                    },
                    selected: selectedIndexes.contains(index),
                    selectedTileColor: Color.fromARGB(153, 236, 183, 234),
                  ),
                );
              },
            ),
        
            //buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
        
                //go back to logs + save negative emotion logs to database
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        //save to database
                        dataToMap();
                        dbRef.push().set(reframingLogs);
                  
                        //go back to log page
                        for(var i = 0; i < 2; i++) {
                          Navigator.pop(context);
                        }
                        Navigator.pop(context, {'guided':true, 'guiding_stage':'thought_traps'});
                      }, 
                      child: Text("I've thought of something to log!",
                        textAlign: TextAlign.center,
                      )
                    ),
                  ),
                ),
        
                //go to next page
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        //add data to reframingLogs map
                        dataToMap();
                  
                        //navigate to next page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => StrategiesPage(initialReframingLogs: reframingLogs))
                        );
                      }, 
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(80, 40)
                      ),
                      child: Text("Next",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ]
        ),
      )
    );
  }
}
