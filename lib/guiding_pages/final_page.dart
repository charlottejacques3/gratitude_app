import 'package:flutter/material.dart';


class FinalPage extends StatefulWidget {
  const FinalPage({super.key});

  @override
  State<FinalPage> createState() => _FinalPageState();
}


class _FinalPageState extends State<FinalPage> {

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