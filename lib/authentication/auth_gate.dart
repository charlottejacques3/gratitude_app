import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gratitude_app/authentication/login_page.dart';
import 'package:gratitude_app/init_mood_page.dart';
import 'package:gratitude_app/main.dart';
import 'package:gratitude_app/utilities/globals.dart';

//where you are brought upon opening the app, decides whether to go to login or home page 
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoginPage();
        } else if (Globals.group.compareTo('experimental') == 0) {
          return InitialMoodPage();
        }
        return MyHomePage(startingPageIndex: 0,);
      },
    );
  }
}