import 'package:flutter/material.dart';

//database imports
import 'package:firebase_database/firebase_database.dart';

//import files
import 'guiding_pages/main_guiding_page.dart';


class GratitudeLogPage extends StatefulWidget {
  const GratitudeLogPage({super.key});

  @override
  State<GratitudeLogPage> createState() => _GratitudeLogPageState();
}


class _GratitudeLogPageState extends State<GratitudeLogPage> {
  
  List<DynamicFormWidget> dynamicForms = [DynamicFormWidget()];
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('GratitudeLogs');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Log Gratitude',
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(height: 30),
          Center(
            child: Text(
              'What are you grateful for today?',
              style: Theme.of(context).textTheme.titleLarge!
            ),
          ),
          ListView.builder(
            itemCount: dynamicForms.length,
            prototypeItem: dynamicForms.first,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return dynamicForms[index];
            },
          ),
          //button to add another form entry
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  dynamicForms.add(DynamicFormWidget());
                });
              }, 
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)
                ),
                minimumSize: Size(double.infinity, 35.0)
              ),
              child: Icon(Icons.add),
            ),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //guiding button
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 8.0, right: 4.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GuidingPage())
                        );
                      },
                      child: Text("I can't think of anything",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              //button to send logs to the database
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 4.0, right: 8.0),
                  child: ElevatedButton(
                    child: Text('Done'),
                    onPressed: () async {
                    try {
                      print("in the try blockk");
                  
                      //look through all the entries
                      for (final item in dynamicForms) {
                        String log = item.logController.text;
                        if (log.isNotEmpty) { //don't add empty entries
                          //map to a dictionary
                          Map<String, String> gratitudeLogs = {
                            'gratitude_item': log,
                            'date': DateTime.now().toIso8601String(),
                          };
                          //push creates a unique key
                          dbRef.push().set(gratitudeLogs);
                  
                          //clear text fields
                          item.logController.text = '';
                        }
                      }
                    } catch (e) {
                      print('error writing data: $e');
                    }
                  }, 
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



class DynamicFormWidget extends StatelessWidget {
  final TextEditingController logController = TextEditingController();

  //how to dispose of controller after?

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
          controller: logController,
          keyboardType: TextInputType.multiline,
          minLines: 1,
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
        ),
    );
  }
}