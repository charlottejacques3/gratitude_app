import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

//database imports
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gratitude_app/congrats_page.dart';

//import files
import 'guiding_pages/main_guiding_page.dart';

//image selection
import 'package:image_picker/image_picker.dart';
enum ImageSourceType { gallery, camera }


class GratitudeLogPage extends StatefulWidget {
  const GratitudeLogPage({super.key, });

  @override
  State<GratitudeLogPage> createState() => _GratitudeLogPageState();
}


class _GratitudeLogPageState extends State<GratitudeLogPage> {
  
  List<DynamicFormWidget> dynamicForms = [];//[DynamicFormWidget(key: Key(1.toString()), logController: TextEditingController(), manageFormList: manageFormList)];
  int nextKey = 2;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('GratitudeLogs');

  bool guided = false; //keeps track of whether they worked through emotions in this session

  //images
  List<String> imageUrls = [];

  //manage deletions of forms from the form widget
  void manageFormList(Key key) {
    print('rgoing to delete $key');

    //find right one to delete
    for (var formWidget in dynamicForms) {
      if (formWidget.key == key) {
        setState(() {
          dynamicForms.remove(formWidget);
        });
        print(formWidget.key);
      }
    }
  }

  //get images
  void handleImageUpload(var source) async {
    //get image from camera/gallery
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: source);
    print(file?.path);

    if (file == null) return;

    //create unique filename with the datetime
    String filename = DateTime.now().toIso8601String();
    print(filename);

    //create references of folders/files
    Reference refRoot = FirebaseStorage.instance.ref();
    Reference refImageDir = refRoot.child('images'); //get reference to storage root
    Reference refImage = refImageDir.child(filename); //create a reference for the image to be stored

    //store file
    try {
      await refImage.putFile(File(file.path));
      //get downnload url
      String url = await refImage.getDownloadURL();
      setState(() {
        imageUrls.add(url);
      });
      print('urls: $imageUrls');
      print('after download url');
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
            itemCount: imageUrls.length,
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
                        child: Image.network(
                          imageUrls[index],
                          height: 200,
                          width: 200,
                        ),
                      ),
                  
                      //remove image
                      Expanded(
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              imageUrls.removeAt(index);
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

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //guiding button
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 8.0, right: 4.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
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
                      child: Text("I can't think of anything",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              //button to send logs to the database
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 4.0, right: 8.0),
                  child: ElevatedButton(
                    child: Text('Done'),
                    onPressed: () async {
                    try {
                      print("in the try blockk");
                  
                      //send all text entries to database
                      for (final item in dynamicForms) {
                        String log = item.logController.text;
                        if (log.isNotEmpty) { //don't add empty entries
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
                          });
                      }
                    } catch (e) {
                      print('error writing data: $e');
                    }
                    
                    //navigate to congrats page
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => CongratsPage(reframed: guided,))
                    );
                  }, 
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



class DynamicFormWidget extends StatelessWidget {

  // final String initialVal;
  const DynamicFormWidget({super.key, required this.logController, required this.manageFormList});//required this.initialVal});

  final TextEditingController logController; // = TextEditingController(text: initialVal);
  final manageFormList;

  //how to dispose of controller after?

  @override
  Widget build(BuildContext context) {
    // return ListTile(
    //   title: TextFormField(
    //     controller: logController,
    //     // initialValue: initialVal,
    //     keyboardType: TextInputType.multiline,
    //     minLines: 1,
    //     maxLines: 3,
    //     validator: (value) {
    //       if (value == null || value.isEmpty) {
    //         return 'Please enter some text';
    //       }
    //       return null;
    //     },
    //   ),

    //   //delete log button
    //   trailing: IconButton(
    //     icon: Icon(Icons.delete),
    //     onPressed: () => manageFormList(key)
    //   ),
    // );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
      
          //form entries
          Expanded(
            flex: 7,
            child: TextFormField(
              controller: logController,
              // initialValue: initialVal,
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              }, 
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