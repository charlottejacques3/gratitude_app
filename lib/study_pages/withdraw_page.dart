import 'package:flutter/material.dart';


class WithdrawPage extends StatefulWidget {
  const WithdrawPage({super.key});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text('You have successfully withdrawn from the study.\n\nWe appreciate your participation, and you will receive an email from us within a day with instructions on how to access your compensation.',
            style: Theme.of(context).textTheme.titleMedium!,
            textAlign: TextAlign.center,
          )
        ),
      )
    );
  }
}