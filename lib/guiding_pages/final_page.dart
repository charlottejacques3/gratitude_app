import 'package:flutter/material.dart';
import 'package:gratitude_app/logs_model.dart';
import 'package:gratitude_app/main.dart';
import 'package:provider/provider.dart';


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
          Text('Reframing',
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
                final prov = Provider.of<LogsModel>(context, listen:false);
                prov.setGuidingStage('strategies');
                prov.setInspoUsed('');
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage(startingPageIndex: 0)));
              }, 
              child: Text("Let's do it!"))
          ],
        ),
      )
    );
  }
}