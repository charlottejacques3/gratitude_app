import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gratitude_app/congrats_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gratitude_app/utilities/firebase_storage.dart';
import 'package:gratitude_app/utilities/upload_task.dart';
import 'package:gratitude_app/widgets.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/timezone.dart';
import 'guiding_pages/main_guiding_page.dart';
import 'package:image_picker/image_picker.dart';
enum ImageSourceType { gallery, camera }


class GratitudeLogPage extends StatefulWidget {
  const GratitudeLogPage({super.key, });

  @override
  State<GratitudeLogPage> createState() => _GratitudeLogPageState();
}


class _GratitudeLogPageState extends State<GratitudeLogPage> {
  
  List<DynamicFormWidget> dynamicForms = [];
  int nextKey = 2;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('users')
                                                          .child(FirebaseAuth.instance.currentUser!.uid)
                                                          .child('GratitudeLogs');

  bool guided = false; //keeps track of whether they worked through emotions in this session

  //images
  List<String> imageUrls = [];
  int numImages = 0;

  //local image caching for no wifi
  final uploadsBox = Hive.box<UploadTaskData>('uploads');
  Map<String, File> localImages = {};

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
    // File file;
    
    // if (xfile != null) {
    //   file = File(xfile.path);
    // } else {
    //   return;
    // }

    setState(() {
      numImages++;
    });


    //create unique filename with the datetime
    String filename = DateTime.now().toIso8601String();

    //save locally
    final dir = await getApplicationDocumentsDirectory();
      final localPath = '${dir.path}/$filename';
      final localFile = File(localPath);

      await File(file.path).copy(localPath); //is this right?

      setState(() {
        localImages[filename] = localFile;
      });
      print('LOCAL IMAGES: $localImages');


    //connected - upload automatically to firebase
    // if (connected) {

    //   try {
    //     String url = await uploadToFirebase(file, filename);
    //     setState(() {
    //       imageUrls.add(url);
    //     });
    //   } catch(e) {
    //     print('error storing images: $e');
    //   }

      //create references of folders/files
      // Reference refRoot = FirebaseStorage.instance.ref();

      // Reference refImageDir = refRoot.child('images').child(uid); //get reference to storage root and the user's folder
      // Reference refImage = refImageDir.child(filename); //create a reference for the image to be stored

      // //store file
      // try {
      //   await refImage.putFile(File(file.path));
      //   //get download url
      //   String url = await refImage.getDownloadURL();
      //   setState(() {
      //     imageUrls.add(url);
      //   });
      // } catch(e) {
      //   print('error storing images: $e');
      // }
    // } 

    //not connected - add upload task
    // if(!connected) {
      // final dir = await getApplicationDocumentsDirectory();
      // final localPath = '${dir.path}/$filename';
      // final localFile = File(localPath);

      // await File(file.path).copy(localPath); //is this right?

      // setState(() {
      //   localImages.add(localFile);
      // });
      // print('LOCAL IMAGES: $localImages');

      await uploadsBox.add(UploadTaskData(localPath: localPath, fileName: filename));
      print('AFTER AWAIT');
    // }
  }

  //reset "guided" variable
  @override
  void initState() {
    super.initState();
    setState(() {
      guided = false;
      dynamicForms = [DynamicFormWidget(key: Key('1'), logController: TextEditingController(), manageFormList: manageFormList)];
      dbRef.keepSynced(false);
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
                        child: Builder(
                        // index < imageUrls.length ? Builder(
                          builder: (context) {
                            //if not locally stored - display from firebase storage
                            //also check if image added to list
                            if (localImages.isEmpty && index < imageUrls.length) {
                              return Image.network(
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
                              );
                            }
                            //otherwise display local copy and check if added to list
                            else if (localImages.isNotEmpty && index < localImages.length) {
                              print('LOCAL IMAGES NOT EMPTY');
                              return Image.file(
                                localImages.values.elementAt(index),
                                height: 200,
                                width: 200,
                              );
                            } 
                            
                            //or if not added yet
                            else {
                              return Container(
                                alignment: Alignment.center,
                                height: 200,
                                width: 200,
                                child: CircularProgressIndicator()
                              );
                            }
                          }
                        )
                      ),
                  
                      //remove image
                      Expanded(
                        child: IconButton(
                          onPressed: () async {
                            String filename = localImages.keys.elementAt(index);
                            deleteLocalImage(filename);
                            setState(() {
                              localImages.remove(filename);
                              // imageUrls.removeAt(index);
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
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
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

          //new buttons style
          // ElevatedButton(
          //   child: Text('Save'),
          //   onPressed: (){},
          // ),
          // Align(
          //   child: ElevatedButton(
          //     child: Text("Help, I can't think of anything!"),
          //     onPressed: (){},
          //   ),
          //   alignment: Alignment.bottomCenter,
          // ),
          SizedBox(height: 16),

          //button to send logs to the database
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SwitchedColourButton (
              onClick: () async {
                bool nonEmptyLogs = false;
                try {
                  //send all text entries to database
                  for (final item in dynamicForms) {
                    String log = item.logController.text;
                    if (log.isNotEmpty) { //don't add empty entries
                      nonEmptyLogs = true;
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

                  //send all images to database
                  bool connected = await InternetConnection().hasInternetAccess; //first check internet
                  final dir = await getApplicationDocumentsDirectory(); //get docs directory
                  localImages.forEach((filename, file) async {
                    nonEmptyLogs = true;
                    if (connected) {
                      //connected - send directly to db
                      uploadToFirebase(file, filename); 
                    } else {
                      //not connected - add to upload tasks
                      final localPath = '${dir.path}/$filename';
                      await uploadsBox.add(UploadTaskData(localPath: localPath, fileName: filename));
                    }
                  });
                  setState(() { //reset
                    localImages = {};
                    numImages = 0;
                  });

                  // for (final url in imageUrls) {
                  //   //map to a dictionary
                  //   Map<String, String> gratitudeImages = {
                  //     'gratitude_item': url,
                  //     'date': DateTime.now().toIso8601String(),
                  //     'type': 'image'
                  //   };
                  //   //send to database
                  //   dbRef.push().set(gratitudeImages);
                  //   //remove images from screen
                  //   setState(() {
                  //     imageUrls = [];
                  //     numImages = 0;
                  //   });
                  // }
                } catch (e) {
                  print('error writing data: $e');
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
                      dbRef.keepSynced(false);
                    });
                  });
                }
              }, 
              text: "Save",
            ),
          ),
          // SwitchedColourButton (
          //   onClick: () {}, 
          //   text: "Help, I can't think of anything!",
          // ),
          
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

                    //keep track of whether they worked through their emotions in that session
                    if (preloaded.containsKey('guided')) {
                      guided = preloaded['guided'];
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