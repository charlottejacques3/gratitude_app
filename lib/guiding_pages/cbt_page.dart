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
  List<String> thoughtTraps = ['Catastrophizing', 'All-or-nothing thinking', 'Emotional reasoning', 'Mind reading', 'Overgeneralization'];
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
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text("Reflecting on the negative thoughts you just logged, can you identify any of these thought traps?",
                  style: Theme.of(context).textTheme.bodyLarge!,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 30),
          
              //multi-select thought traps
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: thoughtTraps.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(thoughtTraps[index]),
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
          
              //next button
              ElevatedButton(
                onPressed: () async {
                  //add data to reframingLogs map
                  List<String> selected_traps = [];
                    for (final index in selectedIndexes) {
                      selected_traps.add(thoughtTraps[index]);
                    }
                    reframingLogs['thought_traps'] = selected_traps;

                  //send info to the database
                  // try {
                  //   dbRef.push().set(reframingLogs); 
                  // } catch(e) {
                  //   print('error writing data: $e');
                  // }

                  //navigate to next page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReframingPage(initialReframingLogs: reframingLogs))
                  );
                }, 
                child: Text('Next')
              )
            ]
          ),
        ),
      )
    );
  }
}
