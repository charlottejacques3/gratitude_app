import 'package:flutter/material.dart';
import 'package:gratitude_app/guiding_pages/inspiration_page.dart';
import 'package:gratitude_app/guiding_pages/log_emotions_page.dart';


class GuidingPage extends StatefulWidget {
  const GuidingPage({super.key});

  @override
  State<GuidingPage> createState() => _GuidingPageState();
}


class _GuidingPageState extends State<GuidingPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: 
          Text('Guidance',
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
            Text("That's okay! Sometimes we have days like that. How would you like to move forward?",
              style: Theme.of(context).textTheme.titleLarge!,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),        

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
        
                //generate past logs button
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.0, right: 4.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const InspirationPage())
                        );
                        },
                        child: Text("Give me some inspiration!",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
        
                //negative emotions walkthrough button
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 4.0, right: 8.0),
                    child: ElevatedButton(
                      child: Text("I want to work through what's bothering me",
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LogEmotionsPage())
                        );
                      }, 
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}
