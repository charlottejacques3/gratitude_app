import 'package:flutter/material.dart';

//import files
import 'package:gratitude_app/guiding_pages/cbt_page.dart';


class LogEmotionsPage extends StatefulWidget {
  const LogEmotionsPage({super.key});

  @override
  State<LogEmotionsPage> createState() => _LogEmotionsPageState();
}


class _LogEmotionsPageState extends State<LogEmotionsPage> {

  final TextEditingController logController = TextEditingController();

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
        child: Column(
          children: [
            SizedBox(height: 30),
            Text("Let's do it! Use this space to log your negative emotions.",
              style: Theme.of(context).textTheme.titleLarge!,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),

            //logging space
            Flexible(
              fit: FlexFit.loose,
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

            //next button
            Flexible(
              fit: FlexFit.loose,
              child: ElevatedButton(
                onPressed: () {
                  //create reframingLogs map to be passed through children and eventually saved to the database
                  Map<String, dynamic> reframingLogs = {
                    'negative_emotions': logController.text,
                    'date': DateTime.now().toIso8601String(),
                  };
                  //push creates a unique key
                  // dbRef.push().set(emotionLogs);

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
          ]
        ),
      )
    );
  }
}