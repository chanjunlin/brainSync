import 'package:brainsync/services/navigation_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final GetIt _getIt = GetIt.instance;
  late final NavigationService _navigationService;

  FirebaseApi() {
    _navigationService = _getIt.get<NavigationService>();
  }

  Future<void> initNotifications() async {
    try {
      await _firebaseMessaging.requestPermission();
      final fCMToken = await _firebaseMessaging.getToken();
      print('Token: $fCMToken');
      initPushNotifications();
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    try {
      _navigationService.navigatorKey?.currentState?.pushNamed(
        '/notifications',
        arguments: message,
      );
    } catch (e) {
      print('Error navigating to notifications: $e');
    }
  }

  Future<void> initPushNotifications() async {
    try {
      FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    } catch (e) {
      print('Error initializing push notifications: $e');
    }
  }
}
