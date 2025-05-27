import 'package:flutter/material.dart';
import 'package:gratitude_app/reflection_pages/new_reflection.dart';

class ReflectionDetailPage extends StatefulWidget {
  const ReflectionDetailPage({super.key, required this.details});

  final Map<dynamic, dynamic> details;

  @override
  State<ReflectionDetailPage> createState() => _ReflectionDetailPageState();
}


class _ReflectionDetailPageState extends State<ReflectionDetailPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.details['type'],
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewReflectionPage(type: widget.details['type'], preloadedResponses: widget.details))
                );
              }, 
              icon: Icon(Icons.edit)
            ),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(widget.details['format_date'],
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30,),
        
            //responses
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.details['responses'].length,
              itemBuilder: (context, index) {
                var responses = widget.details['responses'];
                return Column(
                  children: [
                    Text(responses[index]['prompt'], 
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Text(responses[index]['answer'],
                        style: Theme.of(context).textTheme.bodyLarge!,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(height: 30,),
                  ],
                );
              },
            ),
          ]
        ),
      )
    );
  }
}