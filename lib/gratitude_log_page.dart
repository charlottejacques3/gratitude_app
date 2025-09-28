import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gratitude_app/congrats_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gratitude_app/logs_model.dart';
import 'package:gratitude_app/main.dart';
import 'package:gratitude_app/utilities/globals.dart';
import 'package:gratitude_app/utilities/widgets.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
enum ImageSourceType { gallery, camera }


class GratitudeLogPage extends StatefulWidget {
  const GratitudeLogPage({super.key});

  @override
  State<GratitudeLogPage> createState() => _GratitudeLogPageState();
}


class _GratitudeLogPageState extends State<GratitudeLogPage> {
  
  int nextKey = 2;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  DatabaseReference dbUserRef = FirebaseDatabase.instance.ref().child('users')
                                                          .child(FirebaseAuth.instance.currentUser!.uid);

  // bool guided = true; //keeps track of whether they worked through emotions in this session
  // String guidedStage = '';

  //get images
  void handleImageUpload(var source) async {
    
    //get image from camera/gallery
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: source);

    if (file == null) return;

    // setState(() {
    //   numImages++;
    // });
    Provider.of<LogsModel>(context, listen: false).incNumImages();

    //create unique filename with the datetime
    String filename = DateTime.now().toIso8601String();

    //create references of folders/files
    Reference refRoot = FirebaseStorage.instance.ref();

    Reference refImageDir = refRoot.child('images').child(uid); //get reference to storage root and the user's folder
    Reference refImage = refImageDir.child(filename); //create a reference for the image to be stored
    

    //store file
    try {
      await refImage.putFile(File(file.path));
      //get download url
      String url = await refImage.getDownloadURL();
      // setState(() {
      //   imageUrls.add(url);
      // });
      Provider.of<LogsModel>(context, listen:false).addImageUrl(url);
    } catch(e) {
      print('error storing images: $e');
    }
  }

  //reset "guided" variable
  @override
  void initState() {
    super.initState();
    setState(() {
      dbUserRef.keepSynced(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          SizedBox(height: 30),
          Center(
            child: Text(
              'What are you grateful for today?',
              style: Theme.of(context).textTheme.titleMedium!,
              textAlign: TextAlign.center,
            ),
          ),

          //display form fields
          Consumer<LogsModel>(
            builder: (context, logs, child) {
              return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: logs.textLogs.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return logs.textLogs[index];
                },
              );
            }
          ),

          // display images
          Consumer<LogsModel>(
            builder: (context, logs, child) {
              return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: logs.numImages, //imageUrls.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  try {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 7,
                            child: 
                            //display image if added to list
                            index < logs.imageUrls.length ? Image.network(
                              logs.imageUrls[index],
                              height: 200,
                              width: 200,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress != null) {
                                  return Container(
                                    alignment: Alignment.center,
                                    height: 200,
                                    width: 200,
                                    child: CircularProgressIndicator()
                                  );
                                } else {
                                  return child;
                                }
                              },
                            )
                            //otherwise display circular progress indicator
                            : Container(
                              alignment: Alignment.center,
                              height: 200,
                              width: 200,
                              child: CircularProgressIndicator()
                            )
                          ),
                      
                          //remove image
                          Expanded(
                            child: IconButton(
                              onPressed: () {
                                // setState(() {
                                //   imageUrls.removeAt(index);
                                //   numImages--;
                                // });
                                Provider.of<LogsModel>(context, listen: false).removeImageUrl(index);
                              }, 
                              icon: Icon(Icons.delete)
                            ),
                          )
                        ],
                      ),
                    );
                  } catch (e) {
                    print('error displaying image: $e');
                    return Container();
                  }
                }
              );
            }
          ),

          
          //buttons to add form entries/multimedia
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [

                //add form entries
                Expanded(
                  flex: 7,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        Provider.of<LogsModel>(context, listen:false).addTextLog(DynamicFormWidget(key: Key(nextKey.toString()), logController: TextEditingController()), false);
                        // dynamicForms.add(DynamicFormWidget(key: Key(nextKey.toString()), logController: TextEditingController(), manageFormList: manageFormList));
                        nextKey++;
                      });


                    }, 
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)
                      ),
                      minimumSize: Size(double.infinity, 35.0)
                    ),
                    child: Icon(Icons.add),
                  ),
                ),

                //add multimedia
                Expanded(
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
                        onPressed: () async {
                          bool connection = await InternetConnection().hasInternetAccess;
                          if (connection) {
                            if (controller.isOpen) {
                              controller.close();
                            } else {
                              controller.open();
                            }
                          } else {
                            showDialog(
                              context: context, 
                              builder: (BuildContext context) => Dialog(
                                child: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Please connect to the internet to add image logs.',
                                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          onPressed: () => Navigator.pop(context), 
                                          child: Text('Okay', 
                                            textAlign: TextAlign.center,
                                          )
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              )
                            );
                          }
                        }, 
                        icon: Icon(Icons.camera_alt),
                      );
                    },
                    menuChildren: <MenuItemButton>[
                      //take photo
                      MenuItemButton(
                        child: Text('Take Photo'),
                        onPressed: () async {
                          handleImageUpload(ImageSource.camera);
                        },
                      ),
                      //choose from library
                      MenuItemButton(
                        child: Text('Choose From Library'),
                        onPressed: () async {
                          handleImageUpload(ImageSource.gallery);
                        }
                      )
                    ],
                  )
                )
              ],
            ),
          ),
          SizedBox(height: 16),

          //button to send logs to the database
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SwitchedColourButton (
              onClick: () async {
                DatabaseReference dbRef = dbUserRef.child('GratitudeLogs');
                int numLogs = 0; //keep track of number of logs
                bool nonEmptyLogs = false;
                String dateAdded = DateTime.now().toIso8601String();
                try {
                  //send all text entries to database
                  for (final item in Provider.of<LogsModel>(context, listen:false).textLogs) {
                    String log = item.logController.text;
                    if (log.isNotEmpty) { //don't add empty entries
                      nonEmptyLogs = true;
                      //map to a dictionary
                      Map<String, dynamic> gratitudeLogs = {
                        'gratitude_item': log,
                        'date': dateAdded,
                        'type': 'text',
                        'number': numLogs
                      };
                      numLogs++;
                      //push creates a unique key
                      dbRef.push().set(gratitudeLogs);
              
                      //clear text fields
                      item.logController.text = '';
                    }
                  }

                  //send all image urls to database
                  for (final url in Provider.of<LogsModel>(context, listen:false).imageUrls) {
                    nonEmptyLogs = true;
                    //map to a dictionary
                    Map<String, dynamic> gratitudeImages = {
                      'gratitude_item': url,
                      'date': dateAdded,
                      'type': 'image',
                      'number': numLogs,
                    };
                    numLogs++;
                    //send to database
                    dbRef.push().set(gratitudeImages);
                    //remove images from screen
                    // setState(() {
                    //   imageUrls = [];
                    //   numImages = 0;
                    // });
                    Provider.of<LogsModel>(context, listen:false).removeAllImageUrls();
                  }
                } catch (e) {
                  print('error writing data: $e');
                }

                //update stats
                DatabaseReference statsRef = dbUserRef.child('Stats');
                final snapshot = await statsRef.get();
                final prov = Provider.of<LogsModel>(context, listen:false);
                if (snapshot.exists) {
                  final data = snapshot.value as Map<dynamic, dynamic>;

                  //update num logs
                  int initial = 0;
                  if (data['num_logs'] != null) {
                    initial = data['num_logs'];
                  }
                  statsRef.update({
                    'num_logs': initial + numLogs,
                  });
                  
                  //check if today is in dates list
                  if (data['days_used'] != null) {
                    bool todayAdded = false;
                    print('PREV DATA: ${data['days_used']}, type: ${data['days_used'].runtimeType}');
                    List<dynamic> dates = [];
                    for (final date in data['days_used']) {
                      DateTime dt = DateTime.parse(date);
                      print('DT: $dt');
                      if (dt.day == DateTime.now().day) {
                        todayAdded = true;
                      } else {
                        dates.add(date);
                      }
                    }
                    // print('INITIAL: $dates');
                    if (!todayAdded) {
                      dates.add(DateTime.now().toIso8601String());
                      // print('AFTER: $dates');
                      // print(data['days_used'].runtimeType);
                      // List<dynamic> prevDays = data['days_used'];
                      // prevDays.add(DateTime.now().toIso8601String());
                      statsRef.update({
                        'days_used': dates//data['days_used'].add(DateTime.now().toIso8601String())
                      });
                    }
                  } else {
                    statsRef.update({
                      'days_used': [DateTime.now().toIso8601String()]
                    });
                  }

                  //set inspiration used, if applicable
                  String inspirationUsed = prov.inspoUsed;
                  if (inspirationUsed.isNotEmpty) {
                    try {
                      if (data['inspo_to_log'] != null) {
                        statsRef.child('inspo_to_log').update({
                          inspirationUsed: data['inspo_to_log'][inspirationUsed] + 1
                        });
                      } else {
                        Map<String, int> record = {'Gratitude Prompt': 0, 'Random Photo': 0, 'Random Past Log': 0, 'Past Advice': 0};
                        record[inspirationUsed] = 1;
                        statsRef.update({
                          'inspo_to_log': record
                        });
                      }
                    } on Exception catch (e) {
                      print('INSPIRATION EXCEPTION: $e');
                    }
                  }

                  //set guiding used, if applicable
                  String guidedStage = prov.guidingStage;
                  print(guidedStage);
                  if (guidedStage.isNotEmpty) {
                    try {
                      if (data['guiding_to_log'] != null) {
                        statsRef.child('guiding_to_log').update({
                          guidedStage: data['guiding_to_log'][guidedStage] + 1
                        });
                      } else {
                        Map<String, int> record = {'log_emotions': 0, 'thought_traps': 0, 'strategies': 0};
                        record[guidedStage] = 1;
                        statsRef.update({
                          'guiding_to_log': record
                        });
                      }
                    } on Exception catch (e) {
                      print('GUIDING TO LOG EXCEPTION: $e');
                    }
                  }
                } 
                //set for the first time
                else {
                  try {
                    statsRef.child('num_logs').set(numLogs);
                    // statsRef.set({
                    //   'num_logs': numLogs,
                    //   // 'days_used': [DateTime.now().toIso8601String()],
                    //   'guiding_to_log': guidingRecord
                    // });
                    if (Globals.group.compareTo('experimental') == 0) {
                      Map<String, int> guidingRecord = {'log_emotions': 0, 'thought_traps': 0, 'strategies': 0};
                      String guidedStage = prov.guidingStage;
                      if (guidedStage.isNotEmpty) {
                        guidingRecord[guidedStage] = 1;
                      }
                      statsRef.child('guiding_to_log').set(guidingRecord);
                    }
                  } on Exception catch (e) {
                    print('FIRST TIME EXCEPTION: $e');
                  }
                }
                
                //navigate to congrats page
                if (nonEmptyLogs) {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => CongratsPage(reframed: prov.guidingStage.isNotEmpty, dateAdded: dateAdded,))
                  ).then((_) {
                    //update page
                    setState(() {
                      // guided = false;
                      final prov = Provider.of<LogsModel>(context, listen:false);
                      prov.resetTextLogs();
                      prov.setGuidingStage('');
                      prov.setInspoUsed('');
                      // dynamicForms = [DynamicFormWidget(key: Key('1'), logController: TextEditingController())];
                      dbRef.keepSynced(true);
                    });
                  });
                }
              }, 
              text: "Save",
            ),
          ),
          
          //help button
          Globals.group.compareTo('experimental') == 0 ? 
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: MenuAnchor(
              style: MenuStyle(
                backgroundColor: WidgetStateColor.resolveWith(
                  (Set<WidgetState> states) {
                    return Color.fromARGB(255, 249, 241, 237);
                  }
                )
              ),
              menuChildren: [
                MenuItemButton(
                  child: Text('Give me some inspiration!'),
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage(startingPageIndex: 1))),
                ),
                MenuItemButton(
                  child: Text("I want to work through what's bothering me"),
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage(startingPageIndex: 2))),
                )
              ],
              builder: (BuildContext context, MenuController controller, Widget? child) {
                return ElevatedButton(
                  style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                    backgroundColor: WidgetStatePropertyAll<Color>(Color.fromARGB(255, 249, 241, 237)),
                  ),
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                    // final preloaded = await Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const GuidingPage())
                    // );
                
                    // if (preloaded != null) {
                    //   setState(() {
                    //     //if there is preloaded data from the inspiration page, set it
                    //     if (preloaded.containsKey('type') && preloaded.containsKey('log')) {
                    //       final prov = Provider.of<LogsModel>(context, listen:false);
                    //       if (preloaded['type'].compareTo('text') == 0) {
                    //         prov.addTextLog(DynamicFormWidget(key: Key('1'), logController: TextEditingController(text: preloaded['log'])), true);
                    //         // dynamicForms.add(DynamicFormWidget(key: Key('1'), logController: TextEditingController(text: preloaded['log'])));
                    //       } else if (preloaded['type'].compareTo('image') == 0) {
                    //         // imageUrls.add(preloaded['log']);
                    //         // numImages++;
                    //         prov.addImageUrl(preloaded['log']);
                    //         prov.incNumImages();
                    //       }
                    //     }
                
                    //     //save the inspo type that was used
                    //     // if(preloaded.containsKey('inspo')) {
                    //     //   inspirationUsed = preloaded['inspo'];
                    //     // }
                
                    //     //keep track of whether they worked through their emotions in that session
                    //     // if (preloaded.containsKey('guided')) {
                    //     //   guided = preloaded['guided'];
                    //     // }
                    //     // if (preloaded.containsKey('guiding_stage')) {
                    //     //   guidedStage = preloaded['guiding_stage'];
                    //     // }
                    //   });
                    // }
                  },
                  child: Text("Help, I can't think of anything!",
                    style: TextStyle(
                      color: Color.fromARGB(255, 209, 108, 103)
                    ),
                    textAlign: TextAlign.center,
                  )
                );
              }
            ),
          ) : Container(),
        ],
      ),
    );
  }
}
