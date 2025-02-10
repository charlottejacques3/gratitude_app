// body: Padding(
      //   padding: const EdgeInsets.all(8.0),
      //   child: SingleChildScrollView(
      //     physics: ScrollPhysics(),
      //     child: Column(
      //       children: [
          
      //         //prompting text
      //         SizedBox(height: 30),
      //         Text("Good job! Now that you've caught some of your thought traps, let's try to reframe the situation.",
      //           style: Theme.of(context).textTheme.bodyLarge!,
      //           textAlign: TextAlign.center,
      //         ),
      //         SizedBox(height: 30),

      //         //logging space
      //         Padding(
      //           padding: const EdgeInsets.all(8.0),
      //           child: TextFormField(
      //             controller: logController,
      //             keyboardType: TextInputType.multiline,
      //             minLines: 5,
      //             maxLines: 15,
      //             decoration: InputDecoration(
      //               border: OutlineInputBorder(),
      //             ),
      //             validator: (value) {
      //               if (value == null || value.isEmpty) {
      //                 return 'Please enter some text';
      //               }
      //               return null;
      //             },
      //           ),
      //         ),

      //         //display prompt widgets
      //         ListView.builder(
      //           itemCount: prompt_widgets.length,
      //           itemBuilder: (context, index) {
      //             return prompt_widgets[index];
      //           },
      //         ),
          
      //         //buttons
              // Container(
              //   height: 100,
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
                          
              //       //help button
              //       Flexible(
              //         fit: FlexFit.loose,
              //         child: Padding(
              //           padding: EdgeInsets.only(left: 8.0, right: 4.0),
              //           child: Align(
              //             alignment: Alignment.center,
              //             child: ElevatedButton(
              //               onPressed: () {

              //                 //pick a random prompt + make controllers
              //                 final randomNum = Random().nextInt(prompts.length);
              //                 List<String> selectedPrompt = prompts[randomNum];
              //                 List<TextEditingController> controllers = [];
              //                 for (int i = 0; i < prompts.length; i++) {
              //                   controllers.add(TextEditingController());
              //                 }

              //                 //create a new prompt widget
              //                 prompt_widgets.add(PromptWidget(controllers: controllers, prompt: selectedPrompt));
              //               },
              //               child: Text("Give me some help with this",
              //                 textAlign: TextAlign.center,
              //               ),
              //             ),
              //           ),
              //         ),
              //       ),
                          
              //       //next button
              //       Flexible(
              //         fit: FlexFit.loose,
              //         // padding: EdgeInsets.only(left: 4.0, right: 8.0),
              //         child: Padding(
              //           padding: const EdgeInsets.only(left: 8.0, right: 4.0),
              //           child: ElevatedButton(
              //             child: Text("Next",
              //               textAlign: TextAlign.center,
              //             ),
              //             onPressed: () {
                            
              //             }, 
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            // ],
      //     ),
      //   ),
      // )