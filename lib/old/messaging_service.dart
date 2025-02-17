import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initializeMessaging() async {
    try {
      // Request notification permissions (provisional)
      print("before notication settings");
      final notificationSettings = await _firebaseMessaging.requestPermission(provisional: true);
      print("after notification settings");
    } catch (e) {
      print("caught notications settings exception $e");
    }
      // Handle APNs token for iOS
      final apnsToken = await _firebaseMessaging.getAPNSToken();
      if (apnsToken != null) {
        // Log the token or send it to your server
        print('APNs Token: $apnsToken');
      }

      // Handle token refresh events
      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        // Send the new token to your server
        print('Refreshed token: $token');
      });

      //Handle initial token
      String? initialToken = await _firebaseMessaging.getToken();
      if(initialToken != null) {
        print("Initial token: $initialToken");
      }

      //listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh
      .listen((fcmToken) {
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new
        // token is generated.
      })
      .onError((err) {
        // Error getting token.
      });

      await FirebaseMessaging.instance.setAutoInitEnabled(true);
    
  }
}
