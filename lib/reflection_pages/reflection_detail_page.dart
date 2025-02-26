import 'package:flutter/material.dart';

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
      ),

      body: ListView(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(responses.keys.elementAt(index),
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w500
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(responses.values.elementAt(index),
                    style: Theme.of(context).textTheme.bodyMedium!,
                  ),
                  SizedBox(height: 20,),
                ],
              );
            },
          ),
        ]
      )
    );
  }
}