import 'package:flutter/material.dart';

class PromptWidget extends StatelessWidget {

  const PromptWidget({super.key, required this.title, required this.controllers, required this.prompt, required this.refresh}); 

  final String title;
  final List<TextEditingController> controllers;
  final List<String> prompt;
  final Function refresh;

  @override
  Widget build (BuildContext context) {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10,),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: prompt.length,
          itemBuilder: (context, index) {
            return ListView(
              padding: const EdgeInsets.all(8.0),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                Text(prompt[index], 
                  style: Theme.of(context).textTheme.bodyLarge!,
                  textAlign: TextAlign.center,
                ),
                TextFormField(
                  controller: controllers[index],
                  keyboardType: TextInputType.multiline,
                  minLines: 2,
                  maxLines: 25,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            );
          },
        ),
        
        //refresh button
        TextButton(
          onPressed: () => refresh(),
          child: Row(
            children: [
              Icon(Icons.refresh),
              Text(' Change Activity')
            ],
          )
        ),
      ],
    );
  }
}