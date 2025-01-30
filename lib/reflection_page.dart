import 'package:flutter/material.dart';

//database imports
import 'package:firebase_database/firebase_database.dart';

//date formatting
import 'package:intl/intl.dart';

class ReflectionPage extends StatefulWidget {
  const ReflectionPage({super.key});

  @override
  State<ReflectionPage> createState() => _ReflectionPageState();
}


class _ReflectionPageState extends State<ReflectionPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: 
          Text('Reflection',
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
      ),
    );
  }
}
