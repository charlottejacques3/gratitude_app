import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../utilities/date_functions.dart';
import 'package:photo_manager/photo_manager.dart';


//CHANGE SO ONLY READING FROM DATABASE/PHOTO LIBRARY ONCE!!


class InspirationPage extends StatefulWidget {

  const InspirationPage({super.key});

  @override
  State<InspirationPage> createState() => _InspirationPageState();
}


class _InspirationPageState extends State<InspirationPage> {

  final TextEditingController logController = TextEditingController();
   DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('users')
                                                          .child(FirebaseAuth.instance.currentUser!.uid)
                                                          .child('GratitudeLogs');
  String inspoType = 'Random Past Log';
  List<String> selectedInspoTypes = ['Random Past Log', 'Random Photo', 'Gratitude Prompt'];

  String selectedPastLog = '';
  String selectedLogRelativeDate = '';
  bool loading = true;
  String selectedPastLogType = '';
  AssetEntity? selectedPhoto;
  List<String> prompts = ['What made you smile today?', 
                          'What is going well with your health?', 
                          'What is a small act of kindness that you have experienced recently?',
                          'What is something you have learned recently?',
                          'What do you appreciate about yourself?',
                          'What do you love about the place you live?',
                          'Who is a person in your life you are grateful for?',
                          'What activities do you enjoy?',
                          'What is something delicious you ate recently?',
                          'What everyday object are you grateful for?',
                          'What opportunities are you grateful for?'];
  int selectedPromptIndex = 0;

  @override
  void initState() {
    super.initState();
    dbRef.keepSynced(false);
    pickType();
  }

  //pick a category of inspiration
  void pickType() {
    setState(() {
      inspoType = selectedInspoTypes[Random().nextInt(selectedInspoTypes.length)]; //pick a random type
    });
    
    switch (inspoType) {
      case 'Random Past Log':
        generatePastLogs();
        break;
      case 'Random Photo':
        getRandomPhoto();
        break;
      case 'Gratitude Prompt':
        //pick random number for prompt
        setState(() {
          selectedPromptIndex = Random().nextInt(prompts.length);
        });
        break;
    }
  }

  //randomly generate a past log from the database
  void generatePastLogs() {
    dbRef.onValue.listen((event) {

      //get list of keys
      DataSnapshot dataSnapshot = event.snapshot;
      if (dataSnapshot.value != null) {
        Map<dynamic, dynamic> values = dataSnapshot.value as Map<dynamic, dynamic>;
        List<dynamic> keys = values.keys.toList();

        //pick random key
        final randomNum = Random().nextInt(values.length);
        dynamic pastLogKey = keys[randomNum];

        //format the date
        String formatted = formatDate(values[pastLogKey]['date']);
        if (formatted.compareTo('Today') != 0 && formatted.compareTo('Yesterday') != 0) {
          formatted = 'On $formatted';
        }

        //set selectedPastLog to the log at that key
        if (mounted) {
          setState(() {
            selectedPastLog = values[pastLogKey]['gratitude_item'];
            selectedLogRelativeDate = formatted;
            selectedPastLogType = values[pastLogKey]['type'];
            loading = false;
          });
        }
      }
    });
  }

  //request permission for + get a random photo
  Future<void> getRandomPhoto() async {

    final PermissionState ps = await PhotoManager.requestPermissionExtend();

    // permission granted, get the photos
    if (ps.isAuth || ps == PermissionState.limited) {
      List<AssetEntity> photos = [];
      
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );
      if (albums.isNotEmpty) {
        final AssetPathEntity cameraRoll = albums.first;
        photos = await cameraRoll.getAssetListPaged(page: 0, size: 100);
      }

      //get random photo
      int rand = Random().nextInt(photos.length);
      setState(() {
        selectedPhoto = photos[rand];
      });
    } 
    
    //permission denied
    else {
      PhotoManager.openSetting();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: 
          Text('Log Gratitude',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold
            ),
          ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Builder(
              builder: (context) {
                if (inspoType.compareTo('Random Past Log') == 0) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      selectedPastLog.isEmpty ? //no logs
                      Center(
                        child: Text(
                          'No logs yet, try choosing a different option',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ) :
                      //display progress indicator if not loaded
                      loading 
                        ? CircularProgressIndicator()
                      :
                      //past log
                      Text('$selectedLogRelativeDate, you were grateful for:',
                        style: Theme.of(context).textTheme.titleMedium!,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Builder(
                        builder: (context) {
                          //displaying text
                          if ('text'.compareTo(selectedPastLogType) == 0) { 
                            return Text(selectedPastLog,
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                              ),
                            );
                          } 
                  
                          //displaying images 
                          else if ('image'.compareTo(selectedPastLogType) == 0) {
                            try {
                              return Image.network(
                                selectedPastLog,
                                height: 200,
                                width: 200,
                              );
                            } catch (e) {
                              print('error displaying image: $e');
                              return Container();
                            }   
                          } else {
                            return Container();
                          }
                        }
                      ),
                    ]
                  );
                } 
                
                //pick a random photo
                else if (inspoType.compareTo('Random Photo') == 0) {
                  return selectedPhoto == null
                    ? CircularProgressIndicator()
                              
                  //display photo
                  : FutureBuilder<Uint8List?>(
                    future: selectedPhoto!.thumbnailData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text('Here is a past photo from your camera roll. Is there anything in this photo, big or small, that you can think of to be grateful for?',
                                style: Theme.of(context).textTheme.titleMedium!,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20,),
                              Image.memory(
                                snapshot.data!,
                                height: 200,
                                width: 200,
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Text("No image found");
                      }
                    },
                  );
                } 
                
                //gratitude prompt
                else if (inspoType.compareTo('Gratitude Prompt') == 0) {
                  return Text(prompts[selectedPromptIndex],
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                    );
                }
                
                else {
                  print('error: invalid inspo type: $inspoType');
                  return Container();
                }
              }
            ),
            
            //all types
            SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            
                //back to logs button
                ElevatedButton(
                  child: Text('Log this!'),
                  onPressed: () {
                    Navigator.pop(context);
                    if (inspoType.compareTo('Random Past Log') == 0) {
                      //send past log data back to main page
                      Map<String, String> logData = {'type': selectedPastLogType, 'log': selectedPastLog};
                      Navigator.pop(context, logData);
                    } else if (inspoType.compareTo('Past Photo') == 0) {
                      //send random photo back to main log page
                      // Map<String, String> logData = {'type': 'image', 'log': selectedPhoto};
                      // Navigator.pop(context, logData);
                    } else {
                      Navigator.pop(context);
                    }
                  }
                ),
                SizedBox(width: 20),

                //refresh button
                ElevatedButton(
                  style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                    padding: WidgetStateProperty.all<EdgeInsets>(
                      EdgeInsets.only(right: 0, left: 16)
                    ),
                  ),
                  onPressed: pickType,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        flex: 3,
                        fit: FlexFit.loose,
                        child: Text('Refresh')
                      ),

                      //select which options to allow
                      Flexible(
                        fit: FlexFit.loose,
                        child: MenuAnchor(
                          style: MenuStyle(
                            backgroundColor: WidgetStateColor.resolveWith(
                              (Set<WidgetState> states) {
                                return Color.fromARGB(255, 249, 241, 237);
                              }
                            )
                          ),
                          builder: (BuildContext context, MenuController controller, Widget? child) {
                            return IconButton(
                              icon: Icon(Icons.arrow_downward),
                              onPressed: () {
                                if (controller.isOpen) {
                                  controller.close();
                                } else {
                                  controller.open();
                                }
                              }, 
                            );
                          },
                          menuChildren: ['Random Past Log', 'Random Photo', 'Gratitude Prompt'].map((e) {
                            return MenuItemButton(
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: selectedInspoTypes.contains(e), 
                                    onChanged: (isSelected) {
                                      if (isSelected == true) {
                                        setState(() {
                                          selectedInspoTypes.add(e); //if just selected, add to list
                                        });
                                      } else {
                                        setState(() {
                                          selectedInspoTypes.remove(e); //if just unselected, remove from list
                                        });
                                      }
                                    }
                                  ),
                                  Text(e,
                                    style: TextStyle(
                                      color: Colors.black
                                    )
                                  ),
                                ],
                              )
                            );
                          }).toList(),
                        )
                      )
                    ],
                  ),
                ),
              ],
            )
          ]
        ),
      )
    );
  }
}