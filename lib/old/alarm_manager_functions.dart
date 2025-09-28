import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gratitude_app/utilities/firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';

//read settings from settings - NOT USED ANYMORE
Future<Map<dynamic, dynamic>> readSettings() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Map<dynamic, dynamic> values = {};
  try {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('users')
                                                          .child(FirebaseAuth.instance.currentUser!.uid)
                                                          .child('Settings');
    var dataSnapshot = await dbRef.once();
    values = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
    print(values);
  } catch (e) {
    print("error reading from firebase: $e");
  }
  return values;
}

//request ignore battery optimizations so the app can run in the background
Future<void> requestBatteryOptimizationExemption() async {
  // Check if we already have the permission
  print('initial: ${Permission.ignoreBatteryOptimizations.status}');
  if (await Permission.ignoreBatteryOptimizations.isGranted) {
    print('Battery optimization already disabled for app');
    return;
  }
  
  // Request the permission
  final status = await Permission.ignoreBatteryOptimizations.request();
  
  if (status.isGranted) {
    print('Battery optimization disabled for app');
  } else {
    print('Battery optimization permission denied');
    print(status);
  }
}