import 'package:flutter/material.dart';

class SwitchedColourButton extends StatelessWidget {
  const SwitchedColourButton({super.key, required this.text, required this.onClick});

  final String text; 
  final Function onClick;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onClick(),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(Color.fromARGB(255, 125,78,125))
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Color.fromARGB(255, 249, 241, 237),
        ),
      ),
    );
  }
}