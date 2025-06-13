import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key, this.withdrawn=false});

  final bool withdrawn;

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {

  Map<String, List<Map<String, String>>> resources = {
    'Canada': [
      {'name': 'Suicide Helpline', 'number': '988', 'text': '988', 'link':'https://988.ca/'},
      {'name': 'BC Mental Health Support Line & Crisis Chat', 'number': '3106789', 'link': 'https://www.crisiscentrechat.ca/'},
      {'name': 'Hope for Wellness Helpline (Indigenous support)', 'number': '18552423310', 'link':'https://www.hopeforwellness.ca/'},
      {'name': 'Other mental health resources', 'link': 'https://www.mhrc.ca/mh-resources'}
    ],
    'United States': [
      {'name': 'Suicide Helpline', 'number': '988', 'text':'988',
      'link': 'https://988lifeline.org/'},
      {'name': 'Crisis Text Line (text HOME)', 'text': ' 741741?body=HOME', 'link': 'https://www.crisistextline.org/'},
    ],
    'Mexico': [
      {'name': 'SAPTEL (mental health crisis support)', 'number':'5552598121', 'link':'http://www.saptel.org.mx/index.html'}
    ]
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Resources',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold
          ),
        ),
        actions: widget.withdrawn ? [] : [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Resource(name: 'For immediate emergency assistance, call 911 right away.', number: '911', link: null, textMess:null),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  var url = Uri.parse('https://findahelpline.com/');
                  launchUrl(url);
                },
                child: Text('Find A Helpline In Your Region',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.left,
                )
              ),
            ),

            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: resources.length,
              itemBuilder: (context, parentIndex) {
                return Column(
                  children: [
                    SizedBox(height: 20,),
                    Text(resources.keys.elementAt(parentIndex),
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                    ),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: resources.values.elementAt(parentIndex).length,
                      itemBuilder: (context, childIndex) {
                        List<Map<String, String>> resourcesByCountry = resources.values.elementAt(parentIndex);
                        return Resource(name: resourcesByCountry[childIndex]['name']!, number: resourcesByCountry[childIndex]['number'], link: resourcesByCountry[childIndex]['link'], textMess: resourcesByCountry[childIndex]['text'],);
                      }
                    )
                  ],
                );
              }
            )
          ]
        ),
      )
    );
  }
}

class Resource extends StatelessWidget {
  const Resource({super.key, required this.name, required this.number, required this.link, required this.textMess});

  final String name;
  final dynamic number;
  final dynamic link;
  final dynamic textMess;

  @override
  Widget build(BuildContext context) {

    void call(String number) async {
      var url = Uri.parse('tel:$number');
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        print('error making call: could not launch $url');
      }
    }

    void text(String number) async {
      var url = Uri.parse('sms:+$number');
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        print('error making text message: could not launch $url');
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (link != null) {
                  var url = Uri.parse(link);
                  launchUrl(url);
                }
              },
              child: Text(name,
              softWrap: true,
                style: link == null ? Theme.of(context).textTheme.bodyLarge!
                : Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: 15,),
          number != null ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: OutlinedButton(
              onPressed: () {
                call(number);
              }, 
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone),
                  SizedBox(width: 10,),
                  Text('Call'),
                ],
              )
            ),
          ) : Container(),
          textMess != null ? Padding(
            padding: const EdgeInsets.all(4.0),
            child: OutlinedButton(
              onPressed: () {
                text(textMess);
              }, 
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.message),
                  SizedBox(width: 10,),
                  Text('Text'),
                ],
              )
            ),
          ) : Container(),
        ],
      ),
    );
  }
}