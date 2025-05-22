import 'package:flutter/material.dart';


class StrategiesPage extends StatefulWidget {
  const StrategiesPage({super.key});

  @override
  State<StrategiesPage> createState() => _StrategiesPageState();
}


class _StrategiesPageState extends State<StrategiesPage> {

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 30),
            Text("Good job! Now that you've managed to reframe some thoughts, can you think of anything to be grateful for?",
              style: Theme.of(context).textTheme.titleMedium!,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30,),
            Text("It doesn't have to be big or exciting, just try to think of one thing.",
              style: Theme.of(context).textTheme.titleMedium!,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30,),

            //bring back to main page
            ElevatedButton(
              onPressed: () {
                for(var i = 0; i < 4; i++) {
                  Navigator.pop(context);
                }
                Navigator.pop(context, {'guided':true});
              }, 
              child: Text("Let's do it!"))
          ],
        ),
      )
    );
  }
}