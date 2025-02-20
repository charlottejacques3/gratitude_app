import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

//database imports
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

//import files
import 'guiding_pages/main_guiding_page.dart';

//image selection
import 'package:image_picker/image_picker.dart';
enum ImageSourceType { gallery, camera }


class GratitudeLogPage extends StatefulWidget {
  const GratitudeLogPage({super.key, });//this.filledInLogs=''});

  // String filledInLogs = '';

  @override
  State<GratitudeLogPage> createState() => _GratitudeLogPageState();

  // static _GratitudeLogPageState of(BuildContext context) =>
  //   context.findAncestorStateOfType<_GratitudeLogPageState>();
}


class _GratitudeLogPageState extends State<GratitudeLogPage> {
  
  List<DynamicFormWidget> dynamicForms = [DynamicFormWidget(logController: TextEditingController())];
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('GratitudeLogs');

  //images
  List<String> imageUrls = [];

  //get images
  // void handleImageUpload(BuildContext context, var source) {
  //   Navigator.push(context,
  //   MaterialPageRoute(builder: (context) => ImagePickerWidget(type:source)));
  // }
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
      // setState(() async {
      String url = await refImage.getDownloadURL();
        
      // });
      // print(imageUrl);
      setState(() {
        imageUrls.add(url);
      });
      print('urls: $imageUrls');
      print('after download url');
    } catch(e) {
      print('error storing images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          // ElevatedButton(
          //   onPressed: () {
          //     try {
          //       NotificationService.showInstantNotification(
          //         title: "Title",
          //         body: "Body"
          //       );
          //     } catch (e) {
          //       print("notification service error: $e");
          //     }
          //   }, 
          //   child: Text('send instant notification')
          // ),
          // ElevatedButton(
          //   onPressed: () {
          //     DateTime scheduleDate = DateTime.now().add(const Duration(seconds: 5));
          //     NotificationService.scheduledNotification(
          //       title: "Scheduled notification", 
          //       body: "body", 
          //       scheduledTime: scheduleDate
          //     );
          //   }, 
          //   child: Text('send scheduled notification')
          // ),
          SizedBox(height: 30),
          Center(
            child: Text(
              'What are you grateful for today?',
              style: Theme.of(context).textTheme.titleLarge!
            ),
          ),
          ListView.builder(
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
            itemCount: imageUrls.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              try {
                return Image.network(
                  imageUrls[index],
                  height: 100,
                  width: 100,
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
                  flex: 5,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        dynamicForms.add(DynamicFormWidget(logController: TextEditingController()));
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

                        //if there is preloaded data from the inspiration page, set it
                        if (preloaded != null) {
                            setState(() {
                              dynamicForms = [DynamicFormWidget(logController: TextEditingController(text: preloaded))];
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
  const DynamicFormWidget({super.key, required this.logController});//required this.initialVal});

  final TextEditingController logController; // = TextEditingController(text: initialVal);

  //how to dispose of controller after?

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
    );
  }
}