import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gratitude_app/guiding_pages/cbt_page.dart';
import 'package:gratitude_app/logs_model.dart';
import 'package:gratitude_app/main.dart';
import 'package:gratitude_app/resources_page.dart';
import 'package:gratitude_app/utilities/globals.dart';
import 'package:provider/provider.dart';


class LogEmotionsPage extends StatefulWidget {
  const LogEmotionsPage({super.key});

  @override
  State<LogEmotionsPage> createState() => _LogEmotionsPageState();
}


class _LogEmotionsPageState extends State<LogEmotionsPage> {

  final TextEditingController logController = TextEditingController();
   DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(Globals.group)
                                                          .child(FirebaseAuth.instance.currentUser!.uid)
                                                          .child('NegativeEmotionLogs');

  @override
  void dispose() {
    super.dispose();
    logController.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: 
          Text('Reframing',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold
            ),
          ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            SizedBox(height: 30),
            Text("Sounds like a plan. Use this space to log your negative emotions.",
              style: Theme.of(context).textTheme.titleMedium!,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),

            //logging space
            TextFormField(
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
                        Map<String, dynamic> reframingLogs = {
                          'negative_emotions': logController.text,
                          'date': DateTime.now().toIso8601String(),
                        };
                        try {
                          dbRef.push().set(reframingLogs);
                        } catch(e) {
                          print('ERROR SAVING REFRAMING LOGS: $e');
                        }
                  
                        //go back to log page
                        final prov = Provider.of<LogsModel>(context, listen:false);
                        prov.setGuidingStage('log_emotions');
                        prov.setInspoUsed('');
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage(startingPageIndex: 0)));

                        // Navigator.pop(context);
                        // Navigator.pop(context, {'guided':true, 'guiding_stage':'log_emotions'});
                      }, 
                      child: Text("Back to Gratitude Logs",
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
                        //create reframingLogs map to be passed through children and eventually saved to the database
                        Map<String, dynamic> reframingLogs = {
                          'negative_emotions': logController.text,
                          'date': DateTime.now().toIso8601String(),
                        };
                    
                        //navigate to next page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CBTPage(initialReframingLogs: reframingLogs))
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

            //resources
            SizedBox(height: 15,),
            TextButton(
              child: Text('Are you currently in crisis? View emergency mental health resources here'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ResourcesPage()));
              },
            )
          ]
        ),
      ),
      // bottomNavigationBar: NavigationBar(
      //   destinations: [  //experimental group
      //     NavigationDestination(
      //       icon: Icon(Icons.edit), 
      //       label: 'Log',
      //     ),
      //     NavigationDestination(
      //       icon: Icon(Icons.book), 
      //       label: 'Past Logs',
      //     ),
      //     NavigationDestination(
      //       icon: Icon(Icons.psychology), 
      //       label: 'Reflect',
      //     ),
      //   ]
      // ),
      // floatingActionButton: FloatingActionButton.extended(onPressed: () {}, label: Text('Switch strategies')),
    );
  }
}