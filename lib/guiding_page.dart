import 'package:flutter/material.dart';


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
          Text('~Guidance~',
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
      ),
      body: Column(
        children: [
        ],
      )
    );
  }
}
