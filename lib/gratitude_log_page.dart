import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gratitude_app/congrats_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gratitude_app/widgets.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'guiding_pages/main_guiding_page.dart';
import 'package:image_picker/image_picker.dart';
enum ImageSourceType { gallery, camera }


class GratitudeLogPage extends StatefulWidget {
  const GratitudeLogPage({super.key});

  @override
  State<GratitudeLogPage> createState() => _GratitudeLogPageState();
}


class _GratitudeLogPageState extends State<GratitudeLogPage> {
  
  List<DynamicFormWidget> dynamicForms = [];
  int nextKey = 2;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  DatabaseReference dbUserRef = FirebaseDatabase.instance.ref().child('users')
                                                          .child(FirebaseAuth.instance.currentUser!.uid);

  bool guided = false; //keeps track of whether they worked through emotions in this session
  String guidedStage = '';
  String inspirationUsed = ''; //keeps track of the type of inspiration used, if applicable

  //images
  List<String> imageUrls = [];
  int numImages = 0;

  //manage deletions of forms from the form widget
  void manageFormList(Key key) {

    //if was the last one, just clear it
    if (dynamicForms.length == 1) {
      dynamicForms[0].logController.clear();
    }

    //otherwise, find right one to delete
    else {
      for (var formWidget in dynamicForms) {
        if (formWidget.key == key) {
          setState(() {
            dynamicForms.remove(formWidget);
          });
        }
      }
    }
  }

  //get images
  void handleImageUpload(var source) async {
    
    //get image from camera/gallery
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: source);

    if (file == null) return;

    setState(() {
      numImages++;
    });

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
      setState(() {
        imageUrls.add(url);
      });
    } catch(e) {
      print('error storing images: $e');
    }
  }

  //reset "guided" variable
  @override
  void initState() {
    super.initState();
    setState(() {
      guided = false;
      dynamicForms = [DynamicFormWidget(key: Key('1'), logController: TextEditingController(), manageFormList: manageFormList)];
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
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: dynamicForms.length,
            prototypeItem: dynamicForms.first,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return dynamicForms[index];
            },
          ),

          // display images
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: numImages, //imageUrls.length,
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
                        index < imageUrls.length ? Image.network(
                          imageUrls[index],
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
                            setState(() {
                              imageUrls.removeAt(index);
                              numImages--;
                            });
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
                        dynamicForms.add(DynamicFormWidget(key: Key(nextKey.toString()), logController: TextEditingController(), manageFormList: manageFormList));
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
                try {
                  //send all text entries to database
                  for (final item in dynamicForms) {
                    String log = item.logController.text;
                    if (log.isNotEmpty) { //don't add empty entries
                      nonEmptyLogs = true;
                      numLogs++;
                      //map to a dictionary
                      Map<String, String> gratitudeLogs = {
                        'gratitude_item': log,
                        'date': DateTime.now().toIso8601String(),
                        'type': 'text'
                      };
                      //push creates a unique key
                      dbRef.push().set(gratitudeLogs);
              
                      //clear text fields
                      item.logController.text = '';
                    }
                  }

                  //send all image urls to database
                  for (final url in imageUrls) {
                    numLogs++;
                    //map to a dictionary
                    Map<String, String> gratitudeImages = {
                      'gratitude_item': url,
                      'date': DateTime.now().toIso8601String(),
                      'type': 'image'
                    };
                    //send to database
                    dbRef.push().set(gratitudeImages);
                    //remove images from screen
                    setState(() {
                      imageUrls = [];
                      numImages = 0;
                    });
                  }
                } catch (e) {
                  print('error writing data: $e');
                }

                //update stats
                DatabaseReference statsRef = dbUserRef.child('Stats');
                final snapshot = await statsRef.get();
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
                    for (final date in data['days_used']) {
                      DateTime dt = DateTime.parse(date);
                      if (dt.day == DateTime.now().day) {
                        todayAdded = true;
                        break;
                      }
                    }
                    if (!todayAdded) {
                      statsRef.update({
                        'days_used': data['days_used'].add(DateTime.now().toIso8601String())
                      });
                    }
                  } else {
                    statsRef.update({
                      'days_used': [DateTime.now().toIso8601String()]
                    });
                  }

                  //set inspiration used, if applicable
                  if (inspirationUsed.isNotEmpty) {
                    if (data['inspo_to_log'] != null) {
                      statsRef.child('inspo_to_log').update({
                        inspirationUsed: data['inspo_to_log'][inspirationUsed] + 1
                      });
                    } else {
                      Map<String, int> record = {'Gratitude Prompt': 0, 'Random Photo': 0, 'Random Past Log': 0};
                      record[inspirationUsed] = 1;
                      statsRef.update({
                        'inspo_to_log': record
                      });
                    }
                  }

                  //set guiding used, if applicable
                  if (guided && guidedStage.isNotEmpty) {
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
                  }
                } 
                //set for the first time
                else {
                  Map<String, int> guidingRecord = {'log_emotions': 0, 'thought_traps': 0, 'strategies': 0};
                  guidingRecord[guidedStage] = 1;
                  statsRef.set({
                    'num_logs': numLogs,
                    'days_used': [DateTime.now().toIso8601String()],
                    'guiding_to_log': guidingRecord
                  });
                }
                
                //navigate to congrats page
                if (nonEmptyLogs) {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => CongratsPage(reframed: guided,))
                  ).then((_) {
                    //update page
                    setState(() {
                      guided = false;
                      dynamicForms = [DynamicFormWidget(key: Key('1'), logController: TextEditingController(), manageFormList: manageFormList)];
                      dbRef.keepSynced(true);
                    });
                  });
                }
              }, 
              text: "Save",
            ),
          ),
          
          //button to send to inspiration page
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                backgroundColor: WidgetStatePropertyAll<Color>(Color.fromARGB(255, 249, 241, 237)),
              ),
              onPressed: () async {
                final preloaded = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GuidingPage())
                );

                if (preloaded != null) {
                  setState(() {
                    //if there is preloaded data from the inspiration page, set it
                    if (preloaded.containsKey('type') && preloaded.containsKey('log')) {
                      if (preloaded['type'].compareTo('text') == 0) {
                        dynamicForms = [DynamicFormWidget(key: Key('1'), logController: TextEditingController(text: preloaded['log']), manageFormList: manageFormList)];
                      } else if (preloaded['type'].compareTo('image') == 0) {
                        imageUrls.add(preloaded['log']);
                      }
                    }

                    //save the inspo type that was used
                    if(preloaded.containsKey('inspo')) {
                      inspirationUsed = preloaded['inspo'];
                    }

                    //keep track of whether they worked through their emotions in that session
                    if (preloaded.containsKey('guided')) {
                      guided = preloaded['guided'];
                    }
                    if (preloaded.containsKey('guiding_stage')) {
                      guidedStage = preloaded['guiding_stage'];
                    }
                  });
                }
              },
              child: Text("Help, I can't think of anything!",
                style: TextStyle(
                  color: Color.fromARGB(255, 209, 108, 103)
                ),
                textAlign: TextAlign.center,
              )
            ),
          ),
        ],
      ),
    );
  }
}



class DynamicFormWidget extends StatelessWidget {

  const DynamicFormWidget({super.key, required this.logController, required this.manageFormList});

  final TextEditingController logController; 
  final dynamic manageFormList;


  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
      
          //form entries
          Expanded(
            flex: 7,
            child: TextFormField(
              controller: logController,
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 3,
            ),
          ),
      
          //delete log button
          Expanded(
              child: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => manageFormList(key)
              ),
          )
        ],
      ),
    );
  }
}