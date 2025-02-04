import 'package:flutter/material.dart';


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
          Text('~Guidance~',
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
            Padding(
              padding: const EdgeInsets.all(8.0),
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
            ElevatedButton(
              onPressed: () {
                
              }, 
              child: Text("Next",
                textAlign: TextAlign.center,
              ),
            ),
          ]
        ),
      )
    );
  }
}
