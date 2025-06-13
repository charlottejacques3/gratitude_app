import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gratitude_app/logs_model.dart';
import 'package:gratitude_app/main.dart';
import 'package:gratitude_app/utilities/globals.dart';
import 'package:gratitude_app/utilities/widgets.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utilities/date_functions.dart';
import 'package:photo_manager/photo_manager.dart';


//CHANGE SO ONLY READING FROM DATABASE/PHOTO LIBRARY ONCE!!


class InspirationPage extends StatefulWidget {

  const InspirationPage({super.key});

  @override
  State<InspirationPage> createState() => _InspirationPageState();
}


class _InspirationPageState extends State<InspirationPage> {

   DatabaseReference dbUserRef = FirebaseDatabase.instance.ref().child(Globals.group)
                                                          .child(FirebaseAuth.instance.currentUser!.uid);
  StreamSubscription<DatabaseEvent>? listener1;
  StreamSubscription<DatabaseEvent>? listener2;
  String inspoType = 'Random Past Log';
  List<String> selectedInspoTypes = ['Gratitude Prompt'];
  List<String> possibleInspoTypes = ['Gratitude Prompt'];

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
                          'What opportunities are you grateful for?',
                          'Has there been nice weather lately?',
                          'What good things have brought you to the place you are today?',
                          'What has someone said to you recently that you are grateful for?',
                          'What enjoyable activities have you done recently?',
                          'What do you enjoy about your career?',
                          'What is a sensation that you have seen/heard/smelled/tasted/felt recently that you are grateful for?',
                          'Who, or what, inspires you?',
                          'Think of a person, whether they are currently in your life or not, who has positively affected you.',
                          'What is the best gift you have ever received?',
                          'What made you laugh recently?',
                          'What is something that makes you feel better when you are sad?',
                          'What are you excited about?',
                          'What is something you are proud of yourself for?',
                          'What is one good thing that has happened today?',
                          'What place makes you feel calm and happy?',
                          'What is a song/movie/TV show that you are grateful for?',
                          'What important life lesson have you learned that you are grateful for?',
                          'Think of a recent memory that you are grateful for.',
                          'Can you think of a teacher or mentor who you are grateful for?',
                          'What is your favourite holiday or tradition?',
                          'What life experiences are you grateful for?',
                          'What do you appreciate about nature?',
                          'What is your favourite part of your daily routine?',
                          'What is something that makes you feel lucky?',
                          'What is a childhood experience that you are grateful for?',
                          'Think about a time when things worked out.',
                          'What are you grateful for about your home?',
                          'Who was the last person that helped you?',
                          'What is your favourite food?'
                          ];
  int selectedPromptIndex = 0;
  bool photoPermission = false;
  bool connection = true;
  List<dynamic> selectedAlbums = List.empty(growable: true);

  Map<String, int> inspoStats = {'Gratitude Prompt': 0, 'Random Photo': 0, 'Random Past Log': 0};

  @override
  void initState() {
    super.initState();
    dbUserRef.keepSynced(true);
    initialChecks();
    pickType();
    getAllowedAlbums();
  }

  @override
  void dispose() async{
    super.dispose();
    if (listener1 != null) {
      await listener1!.cancel();
    }
    if (listener2 != null) {
      await listener2!.cancel();
    }
    sendStats();
  }

  //update number of times used
  void sendStats() async {
    DatabaseReference statsRef = dbUserRef.child('Stats');
    final snapshot = await statsRef.child('inspo_used').get();

    //update inspoUsed if data already exists
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      inspoStats.forEach((type, timesUsed) {
        inspoStats[type] = data[type] + timesUsed;
      });
    } 
    //send to db
    statsRef.update({
      'inspo_used': inspoStats
    });
  }

  //check whether there are logs/permissions for photos
  void initialChecks() async {

    //check for internet
    bool conn = await InternetConnection().hasInternetAccess;
    setState(() {
      connection = conn;
    });

    //check for random photo
    await requestPermission();
    final PermissionState ps = await PhotoManager.getPermissionState(requestOption: const PermissionRequestOption());//await PhotoManager.requestPermissionExtend();
    if ((ps.isAuth || ps == PermissionState.limited) && connection) {
      setState(() {
        photoPermission = true;
        possibleInspoTypes.add('Random Photo');
        selectedInspoTypes.add('Random Photo');
      });
    }

    //check if there are logs
    listener1 = dbUserRef.child('GratitudeLogs').onValue.listen((event) {
      DataSnapshot dataSnapshot = event.snapshot;
      if (dataSnapshot.value != null) {
        Map<dynamic, dynamic> values =  dataSnapshot.value as Map<dynamic, dynamic>;

        //look for non-images if there's no internet
        bool validLogs = false;
        if (connection) {
          validLogs = values.isNotEmpty;
        } else {
          for (dynamic value in values.values) {
            if (value['type'].compareTo('text') == 0) {
              validLogs = true;
              break;
            }
          }
        }

        if (validLogs) {
          setState(() {
            possibleInspoTypes.add('Random Past Log');
            selectedInspoTypes.add('Random Past Log');
          });
        }
      }
    });
  }

  Future<void> requestPermission() async {
    final ps = await PhotoManager.getPermissionState(requestOption: const PermissionRequestOption());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? asked = prefs.getBool('asked_photo_permission');
    print('PERMISSION STATE: $ps');
    if (ps == PermissionState.denied && asked != null && !asked) {
      showDialog(
        context: context, 
        builder: (BuildContext context) => Dialog(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('This app would like to request access to your camera roll in order to generate a random photo that might spark gratitude',
                  textAlign: TextAlign.center,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            prefs.setBool('asked_photo_permission', true);
                            Navigator.pop(context);
                          }, 
                          child: Text('Deny')
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await PhotoManager.requestPermissionExtend();
                          }, 
                          child: Text('Allow')
                        ),
                      ),
                    )
                  ],
                )
              ],
            )
          ),
        )
      );
    }
  }

  //pick a category of inspiration
  void pickType() {
    //check for 0 length
    if (selectedInspoTypes.isEmpty) {
      setState(() {
        inspoType = 'none';
      });
      return;
    }

    setState(() {
      inspoType = selectedInspoTypes[Random().nextInt(selectedInspoTypes.length)]; //pick a random type
    });
    
    switch (inspoType) {
      case 'Random Past Log':
        generatePastLogs();
        inspoStats['Random Past Log'] = inspoStats['Random Past Log']! + 1;
        break;
      case 'Random Photo':
        getRandomPhoto();
        inspoStats['Random Photo'] = inspoStats['Random Photo']! + 1;
        break;
      case 'Gratitude Prompt':
        inspoStats['Gratitude Prompt'] = inspoStats['Gratitude Prompt']! + 1;
        //pick random number for prompt
        setState(() {
          selectedPromptIndex = Random().nextInt(prompts.length);
        });
        break;
    }
  }

  //dialog if the random log/photo don't work
  void dialog(String text, Function() actionButton, String actionButtonText, bool twoButtons) {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(text,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Row(
                children: [
                  twoButtons ? 
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context), 
                          child: Text('Cancel', 
                            textAlign: TextAlign.center,
                          )
                        ),
                      ),
                    )
                  : Container(),

                  //confirm opt out
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () => actionButton(),
                        child: Text(actionButtonText,
                          textAlign: TextAlign.center,
                        )
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        )
      )
    );
  }

  //randomly generate a past log from the database
  void generatePastLogs() {
    listener2 = dbUserRef.child('GratitudeLogs').onValue.listen((event) {

      //get list of keys
      DataSnapshot dataSnapshot = event.snapshot;
      if (dataSnapshot.value != null) {
        Map<dynamic, dynamic> values = dataSnapshot.value as Map<dynamic, dynamic>;
        //choose a different one if it's empty, if possible
        // if (values.isEmpty && selectedInspoTypes.length >) {

        // }
        List<dynamic> keys = values.keys.toList();

        //pick random key
        bool validPastLog = false;
        dynamic pastLogKey;
        while (!validPastLog) {
          final randomNum = Random().nextInt(values.length);
          pastLogKey = keys[randomNum];

          //check if it's an image for internet
          if (connection || values[pastLogKey]['type'].compareTo('text') == 0) {
            validPastLog = true;
          } 
        }

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

  //request permission for + get albums
  Future<List<AssetPathEntity>> getAlbums() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();

    // permission granted, get the photos
    if (ps.isAuth || ps == PermissionState.limited) {
      
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );
      return albums;
    } else {
      PhotoManager.openSetting();
    }
    return [];
  }

  void getAllowedAlbums() async {
    //get list of selected albums from db
    final snapshot = await dbUserRef.child('SelectedAlbums').get();
    if (snapshot.exists) {
      selectedAlbums = [];
      setState(() {
        selectedAlbums.addAll(snapshot.value as List<dynamic>);
      });
    }
  }

  //request permission for + get a random photo
  Future<void> getRandomPhoto() async {

    // final PermissionState ps = await PhotoManager.requestPermissionExtend();

    // // permission granted, get the photos
    // if (ps.isAuth) { //|| ps == PermissionState.limited) {
      List<AssetEntity> photos = [];
      
      // final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      //   type: RequestType.image,
      // );
      List<AssetPathEntity> albums = await getAlbums();
      // if (albums.isNotEmpty) {
      //   final AssetPathEntity cameraRoll = albums.first;
      //   photos = await cameraRoll.getAssetListPaged(page: 0, size: 100);
      // }
      for (final album in albums) {
        if (selectedAlbums.contains(album.name)) {
          photos.addAll(await album.getAssetListPaged(page: 0, size: 100));
        }
      }

      //get random photo
      if (photos.isNotEmpty) {
        int rand = Random().nextInt(photos.length);
        setState(() {
          selectedPhoto = photos[rand];
        });
      } else { //photos list is empty
        setState(() {
          selectedPhoto = null;
        });
      }
    } 
    
    //permission denied
    // else {
    //   PhotoManager.openSetting();
    // }
  // }

  //for saving to firebase
  Future<String> saveImageToFirebase() async {
    // selectedPhoto.file
    String filename = DateTime.now().toIso8601String(); //filename with datetime
    
    try {
    //save selected photo to storage
    // final byteData = await rootBundle.load('assets/$filename');
    // final file = File('${(await getTemporaryDirectory()).path}/$filename');
    // await file.create(recursive: true);
    // await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    //create references of folders/files
      if (selectedPhoto == null) throw Error();
      File? file = await selectedPhoto!.file;
      Reference refRoot = FirebaseStorage.instance.ref();

      Reference refImageDir = refRoot.child('images').child(FirebaseAuth.instance.currentUser!.uid); 
      Reference refImage = refImageDir.child(filename); //create a reference for the image to be stored

    //store file
      if (file == null) throw Error();
      await refImage.putFile(file);
      return await refImage.getDownloadURL(); //return download url
    } catch(e) {
      print('error storing images: $e');
      throw Error();
    }
  }

  void selectAlbumsDialog() async {
    //get all albums
    List<AssetPathEntity> allAlbums = await getAlbums(); //fix this function

    
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog( 
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: ListView(
                  children: [
                    Text('Please select some albums, containing photos that make you happy, that you would like to pull from.'),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: allAlbums.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Checkbox(
                            value: selectedAlbums.contains(allAlbums[index].name), 
                            onChanged: (isSelected) {
                              //add to list
                              if (isSelected == true) {
                                setState(() {
                                  selectedAlbums.add(allAlbums[index].name);
                                });
                              } else {
                                setState(() {
                                  selectedAlbums.remove(allAlbums[index].name);
                                });
                              }
                            }
                          ),
                          title: Text(allAlbums[index].name)
                        );
                      }
                    ),
                    SwitchedColourButton(
                      text: 'Update', 
                      onClick: () {
                        dbUserRef.update({'SelectedAlbums': selectedAlbums});
                        Navigator.pop(context);
                      }
                    )
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: 
      //     Text('Log Gratitude',
      //       style: Theme.of(context).textTheme.titleLarge!.copyWith(
      //         color: Theme.of(context).colorScheme.primary,
      //         fontWeight: FontWeight.bold
      //       ),
      //     ),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
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
                    return FutureBuilder<Uint8List?>(
                      future: selectedPhoto?.originBytes,
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
                                SizedBox(height: 20,),
                                TextButton(
                                  onPressed: () => selectAlbumsDialog(),
                                  child: Text('Select Albums')
                                )
                              ],
                            ),
                          );
                        } else {
                          return Column(
                            children: [
                              Text("No images found in your selected albums. Please select an album to use this feature.",
                                textAlign: TextAlign.center,
                              ),
                              TextButton(
                                onPressed: () => selectAlbumsDialog(),
                                child: Text('Select Albums')
                              )
                            ],
                          );
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
        
                  //nothing selected
                  else if(inspoType.compareTo('none') == 0) {
                    return Text(
                      'Please choose an inspiration type',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
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
                    onPressed: () async {
                      // Navigator.pop(context);
                      final prov = Provider.of<LogsModel>(context, listen:false);
                      if (inspoType.compareTo('Random Past Log') == 0) {
                        //send past log data back to main page
                        if (selectedPastLogType.compareTo('text') == 0) {
                          prov.addTextLog(DynamicFormWidget(key: Key('1'), logController: TextEditingController(text: selectedPastLog)), true);
                        } else if (selectedPastLogType.compareTo('image') == 0) {
                          prov.addImageUrl(selectedPastLog);
                          prov.incNumImages();
                        }
                        // Map<String, String> logData = {'type': selectedPastLogType, 'log': selectedPastLog, 'inspo': inspoType};
                        // Navigator.pop(context);
                        // Navigator.pop(context, logData);
                      } else if (inspoType.compareTo('Random Photo') == 0) {
                        //send image to firebase
                        try {
                          String url = await saveImageToFirebase();
                          prov.addImageUrl(url);
                          prov.incNumImages();
                          // Map<String, String> logData = {'type': 'image', 'log': url, 'inspo': inspoType};
                          // Navigator.pop(context);
                          // Navigator.pop(context, logData);
                        } catch(e) {
                          print('Error saving to Firebase');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Error saving image')),
                          );
                        //   Navigator.pop(context);
                        // Navigator.pop(context);
                        }
                      } 
                      prov.setInspoUsed(inspoType);
                      prov.setGuidingStage('');
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage(startingPageIndex: 0)));
                      // else {
                      //   Navigator.pop(context);
                      //   Navigator.pop(context, {'inspo': inspoType});
                      // }
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
                            menuChildren: ['Gratitude Prompt', 'Random Past Log', 'Random Photo'].map((e) {
                              return MenuItemButton(
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: selectedInspoTypes.contains(e) && possibleInspoTypes.contains(e), 
                                      side: selectedInspoTypes.contains(e) && !possibleInspoTypes.contains(e) 
                                        ? WidgetStateBorderSide.resolveWith(
                                          (states) => BorderSide(width: 1.5, color: Colors.grey),
                                        )
                                        : WidgetStateBorderSide.resolveWith(
                                          (states) => BorderSide(width: 1.5, color: Colors.black)
                                        ),
                                      onChanged: (isSelected) {
                                        //check if possible
                                        if (possibleInspoTypes.contains(e)) {
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
        
                                        //if not, show dialog
                                        else {
                                          // String msg = '';
                                          if (e.compareTo('Random Photo') == 0) {
                                            if (!connection) {
                                              dialog(
                                                'Please connect to the internet to use this feature',
                                                () {
                                                  Navigator.pop(context);
                                                },
                                                'Okay',
                                                false
                                              );
                                            } else {
                                              dialog(
                                                'Please allow access to the camera roll to use this feature',
                                                () {
                                                  PhotoManager.openSetting();
                                                },
                                                'Open Settings',
                                                true
                                              );
                                            }
                                          } else if (e.compareTo('Random Past Log') == 0) {
                                              dialog(
                                                'Please add a log to use this feature',
                                                () {
                                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage(startingPageIndex: 0)));
                                                },
                                                'Add a Log',
                                                true
                                              );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error: this feature is not currently available')),
                                            );
                                          }
                                          
                                        }
                                      }
                                    ),
                                    Text(e,
                                      style: TextStyle(
                                        color: possibleInspoTypes.contains(e) ? Colors.black : Colors.grey
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
        ),
      )
    );
  }
}