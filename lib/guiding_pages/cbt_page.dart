import 'package:flutter/material.dart';
import 'package:gratitude_app/guiding_pages/reframing_page.dart';

//database imports
import 'package:firebase_database/firebase_database.dart';


class CBTPage extends StatefulWidget {

  final Map<String, dynamic> initialReframingLogs;

  const CBTPage({super.key, required this.initialReframingLogs});

  @override
  State<CBTPage> createState() => _CBTPageState();
}


class _CBTPageState extends State<CBTPage> {

  //thought traps selection
  List<String> thoughtTraps = ['Catastrophizing', 'All-or-nothing thinking', 'Emotional reasoning', 'Mind reading', 'Overgeneralization', 'Personalization', 'Labeling'];
  Map<String, String> thoughtTrapsDetails = {
    'Catastrophizing': 'Catastrophizing is when we predict that the absolute worst-case scenario will happen. For example, after a bad grade on a test, we might start thinking that we will be kicked out of school and will never find a job, even though the chances of this happening are very slim.',
    'All-or-nothing thinking': 'All-or-nothing thinking is when we look at situations as being strictly good or bad, and are unable to see any nuance. This is a common thought trap to fall into after experiencing a small setback in a goal - we might believe that one mistake means we have failed, when in reality this is not the case.',
    'Emotional reasoning': 'Emotional reasoning is a distortion where we take our emotions as a fact, regardless of any evidence to the contrary. For example, if we feel stupid, we might take this as fact, even when it is not.', 
    'Mind reading': 'Mind-reading is when we believe that we know what other people are thinking, despite having no evidence to support these claims. For example, we might believe somebody does not like us, even though they have never said anything supporting this idea.', 
    'Overgeneralization': 'Overgeneralization is when we come to the conclusion that one negative event is actually part of a series of unending negative events. For example, if we have one bad day, we might start to think that we will be miserable forever.',
    'Personalization': 'Personalization is when we believe that the actions or words of others are a direct reaction to us. For example, if somebody is upset, we might believe that they are angry at us, when really they might just be having a bad day.',
    'Labeling': 'Labeling is a form of generalization, and occurs when we give ourselves or someone else a negative label after a single mistake.'
  };
  Set<int> selectedIndexes = {};
  Map<String, dynamic> reframingLogs = {};
  
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('NegativeEmotionLogs');

  //initialize reframingLogs with values passed
  @override
  void initState() {
    super.initState();
    setState(() {
      reframingLogs = widget.initialReframingLogs;
    });
  }

  //add data to reframingLogs map to send to database or next page
  void dataToMap() {
    List<String> selected_traps = [];
    for (final index in selectedIndexes) {
      selected_traps.add(thoughtTraps[index]);
    }
    reframingLogs['thought_traps'] = selected_traps;
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
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
                  return ListTile(
                    title: Text(thoughtTraps[index]),

                    //info button
                    trailing: GestureDetector(
                      onTap: () => showDialog(
                        context: context, 
                        builder: (BuildContext context) => Dialog(
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
                                SizedBox(height: 30,),
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
                    selectedTileColor: Colors.purple[100],
                  );
                },
              ),
          
              //buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  //go to next page
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        //add data to reframingLogs map
                        dataToMap();

                        //navigate to next page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ReframingPage(initialReframingLogs: reframingLogs))
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

                  //go back to logs + save negative emotion logs to database
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        //save to database
                        dataToMap();
                        dbRef.push().set(reframingLogs);

                        //go back to log page
                        for(var i = 0; i < 3; i++) {
                          Navigator.pop(context);
                        }
                      }, 
                      child: Text("I've thought of something to log!")
                    ),
                  ),
                ],
              ),
            ]
          ),
        ),
      )
    );
  }
}
