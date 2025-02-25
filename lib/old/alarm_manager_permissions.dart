// Future<void> requestAlarmPermission() async {
//   if (Platform.isAndroid) {
//     if (await Permission.scheduleExactAlarm.isDenied) {
//       // Only request permission if it's denied (for Android 14+)
//       print('request permission');
//       await Permission.scheduleExactAlarm.request();
//     }
//   }
// }


//in notificationScheduler
// requestAlarmPermission();
  // if (await Permission.scheduleExactAlarm.isGranted) {
    // final DateTime now = DateTime.now();
    // print("[$now] Hello, world! function='$notificationScheduler'");
  // } else {
  //   print('Permission required to schedule alarm');
  // }