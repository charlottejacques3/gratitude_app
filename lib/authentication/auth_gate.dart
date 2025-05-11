import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gratitude_app/authentication/login_page.dart';
import 'package:gratitude_app/main.dart';
import 'package:gratitude_app/withdraw_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ParticipantGate extends StatefulWidget {
  const ParticipantGate({super.key});

  @override
  State<ParticipantGate> createState() => _ParticipantGateState();
}

class _ParticipantGateState extends State<ParticipantGate> {

  Future<SharedPreferences> getPrefs() {
    return SharedPreferences.getInstance();
  }
  // final Future<bool> withdraw = await SharedPreferences.getInstance().then((value) => value.getBool('withdraw'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            //check for error
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '${snapshot.error} occurred',
                  style: TextStyle(fontSize: 18),
                ),
              );

              //future has complete, got data
            } else if (snapshot.hasData) {
              bool? withdraw = snapshot.data!.getBool('withdraw');
              if (withdraw == null || !withdraw) {
                return AuthGate();
              } else {
                return WithdrawPage();
              }
            }
          } 
          return CircularProgressIndicator();
        },
        future: getPrefs()
      )
    );
  }
}

//where you are brought upon opening the app, decides whether to go to login or home page 
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        //check whether still study participant
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        if (!snapshot.hasData) {
          return LoginPage();
        }
        return MyHomePage(startingPageIndex: 0,);
      },
    );
  }
}