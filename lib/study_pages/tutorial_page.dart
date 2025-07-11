import 'package:flutter/material.dart';
import 'package:gratitude_app/init_mood_page.dart';


class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  int curPage = 1;
  int numPages = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: 
            Text('Tutorial',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold
              ),
            ),
        ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.5,
                  color: Colors.grey
                )
              ),
              child: Image.asset(
                'assets/tutorial_updated/$curPage.png',
                // height: ,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    onPressed: () {
                      if (curPage > 1) {
                        setState(() {
                          curPage--;
                        });
                      }
                    }, 
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll<Color>(Color.fromARGB(255, 250, 240, 230)),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: curPage > 1 ? Colors.black : Colors.grey,
                    )
                  ),
                ),
                Spacer(),
                
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () {
                      if (curPage < numPages) {
                        setState(() {
                          curPage++;
                        });
                      } else {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const InitialMoodPage()));
                      }
                    }, 
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll<Color>(Color.fromARGB(255, 250, 240, 230)),
                    ),
                    child: Icon(Icons.arrow_forward, color:Colors.black)
                  ),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}