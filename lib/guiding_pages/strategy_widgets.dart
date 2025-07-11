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
                  style: Theme.of(context).textTheme.bodyMedium,
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
          onPressed: () {
            //check controllers for text
            bool hasText = false;
            for (final controller in controllers) {
              if (controller.text.isNotEmpty) {
                hasText = true;
                break;
              }
            }

            //if text, show dialog
            if (hasText) {
              showDialog(context: context, builder: (BuildContext context) => Dialog(
                child: Padding(
                  padding: EdgeInsetsGeometry.all(15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Are you sure you would like to change the activity?',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.center
                      ),
                      Text('This will delete anything you have already written for this activity.',
                        textAlign: TextAlign.center
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context), 
                                child: Text('Cancel', 
                                  textAlign: TextAlign.center,
                                )
                              ),
                            ),
                          ),

                          //confirm opt out
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                                  backgroundColor: WidgetStatePropertyAll<Color>(Color.fromARGB(255, 209, 108, 103)),
                                ),
                                onPressed: () {
                                  refresh();
                                  Navigator.pop(context);
                                },
                                child: Text('Yes, change',
                                  style: TextStyle(
                                    color: Colors.white
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  )
                )
              ));
            } else {
              refresh();
            }
          },
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