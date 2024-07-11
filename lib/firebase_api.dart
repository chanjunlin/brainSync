import 'package:brainsync/services/navigation_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final GetIt _getIt = GetIt.instance;
  late final NavigationService _navigationService = _getIt.get<NavigationService>();

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print(fCMToken);
    initPushNotifications();
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    _navigationService.navigatorKey?.currentState?.pushNamed(
      ('/notifications'),
      arguments: message,
    );
  }

  Future initPushNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}
