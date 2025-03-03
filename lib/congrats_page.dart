import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


class CongratsPage extends StatefulWidget {
  const CongratsPage({super.key, required this.reframed});

  final bool reframed;

  @override
  State<CongratsPage> createState() => _CongratsPageState();
}


class _CongratsPageState extends State<CongratsPage> {

  TextEditingController adviceController = TextEditingController();
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('Advice');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            
            children: [
              Spacer(
                flex: 1
              ),
              Text('Congratulations!',
                style: Theme.of(context).textTheme.headlineLarge!,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 50,
              ),
              
              
              widget.reframed ?
                //if reframed, give option for advice
                Column(
                  children: [
                    Text('Good job logging your gratitude, and working through your negative emotions!',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10,),
                    Text('Having gone through this experience, is there any advice you would leave for your future self the next time you experience negative feelings like this?',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10,),
                    TextFormField(
                      controller: adviceController,
                      keyboardType: TextInputType.multiline,
                      minLines: 3,
                      maxLines: 15,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20,),
                    //send advice to database
                    ElevatedButton(
                      onPressed: () async {
                        if (adviceController.text.isNotEmpty) {
                          Map<String, dynamic> advice = {
                            'advice': adviceController.text,
                            'date': DateTime.now().toIso8601String()
                          };
                          try {
                            dbRef.push().set(advice);
                          } catch (e) {
                            print('error writing to database: $e');
                          }
                        }
                        Navigator.pop(context, {'guided':false});
                      },
                      child: Text('Save')
                    )
                  ],
                )
                //
              : Text('Good job logging your gratitude!'),
              Spacer(
                flex: 2
              )
            ],
          ),
        )
      )
    );
  }
}