import 'package:flutter/material.dart';
import 'package:gratitude_app/authentication/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';


class LoginPage extends StatefulWidget {

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  bool hasAccount = true;
  bool agreeToTerms = false;

  void switchPage() {
    setState(() {
      hasAccount = !hasAccount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: hasAccount ?
          Text('Log In',
           style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold
            ),
          )
        : Text('Sign Up',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold
          ),
        )
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            //email/password
            Row(
              children: [
                Text('Email: '),
                Expanded(
                  child: TextFormField(
                    controller: emailController,
                  ),
                )
              ],
            ),
            Row(
              children: [
                Text('Password: '),
                Expanded(
                  child: TextFormField(
                    controller: pwController,
                    obscureText: true,
                  ),
                )
              ],
            ),

            //agree to terms if signing up
            !hasAccount ? 
              Row(
                children: [
                  Checkbox(
                    value: agreeToTerms, 
                    onChanged: (isSelected) {
                      setState(() {
                        agreeToTerms = isSelected!;
                      });
                    }
                  ),
                  Text('I agree to the '),
                  InkWell(
                    child: Text('Terms of Use',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary
                      )
                    ),
                    onTap: () {} //ADD TERMS OF USE ONCE I HAVE THEM!!
                  )
                ],
              )
            : Container(),
        
            //log in button
            ElevatedButton(
              onPressed: () async {
                //sign up
                if (!hasAccount) {
                  //check if agreed to terms
                  if (!agreeToTerms) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please accept the Terms of Use')),
                    );
                  } else {
                    await AuthService().signup(
                      email: emailController.text,
                      password: pwController.text,
                      context: context
                    );
                  }
                } else {
                  //log in
                  await AuthService().signin(
                    email: emailController.text,
                    password: pwController.text,
                    context: context
                  );
                }
                
              }, 
              child: hasAccount ?
                Text('Log In')
              : Text('Sign Up')
            ),
        
            //switch log in / sign up pages
            Row(
              children: 
                hasAccount ? [
                  Text("Don't have an account?"),
                  TextButton(
                    onPressed: switchPage, 
                    child: Text('Sign up')
                  )
                ] : [
                  Text("Already have an account?"),
                  TextButton(
                    onPressed: switchPage, 
                    child: Text('Log in')
                  )
                ],
            )
          ],
        ),
      )
    );
  }
}