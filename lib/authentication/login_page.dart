import 'package:flutter/material.dart';
import 'package:gratitude_app/authentication/auth_service.dart';
import 'package:gratitude_app/utilities/widgets.dart';
import 'package:url_launcher/url_launcher.dart';


class LoginPage extends StatefulWidget {

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {

  TextEditingController usernameController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  bool hasAccount = false;
  bool agreeToTerms = false;

  void switchPage() {
    setState(() {
      hasAccount = !hasAccount;
    });
  }

  @override
  void dispose() {
    super.dispose();
    usernameController.dispose();
    pwController.dispose();
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
        child: ListView(
          children: [
            //username/password
            Row(
              children: [
                Text('Username: '),
                Expanded(
                  child: TextFormField(
                    controller: usernameController,
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

            //switch login/signup
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
                    child: Text('Privacy Policy',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary
                      )
                    ),
                    onTap: () => launchUrl(Uri.parse('https://gratitude-buddy-privacy.netlify.app/'))
                  )
                ],
              )
            : Container(),
            SizedBox(height: 30,),
        
            //log in button
            SwitchedColourButton(
              onClick: () async {
                //sign up
                if (!hasAccount) {
                  //check if agreed to terms
                  if (!agreeToTerms) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please accept the Privacy Policy')),
                    );
                  } else {
                    await AuthService().signup(
                      username: usernameController.text,
                      password: pwController.text,
                      context: context
                    );
                  }
                } else {
                  //log in
                  await AuthService().signin(
                    username: usernameController.text,
                    password: pwController.text,
                    context: context
                  );
                }
              }, 
              text: hasAccount ? 'Log In' : 'Sign Up'
            ),

            // !hasAccount ? Column(
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.all(10.0),
            //       child: Text('Or',
            //         textAlign: TextAlign.center,
            //       ),
            //     ),
                
            //     Row(
            //       children: [
            //         Expanded(
            //           child: SwitchedColourButton(
            //             onClick: () async {
            //                if (!agreeToTerms) {
            //                 ScaffoldMessenger.of(context).showSnackBar(
            //                   const SnackBar(content: Text('Please accept the Privacy Policy')),
            //                 );
            //               } else {
            //                 await AuthService().signInAnon(context: context);
            //               }
            //             }, 
            //             text: 'Sign In Anonymously'
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ) : Container(),
          ],
        ),
      )
    );
  }
}