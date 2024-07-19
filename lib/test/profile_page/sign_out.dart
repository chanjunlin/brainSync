import 'package:brainsync/model/module.dart';
import 'package:brainsync/pages/Profile/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';
import 'package:brainsync/pages/Posts/post.dart';
import 'package:brainsync/services/api_service.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:brainsync/services/alert_service.dart';

class MockAuthService extends Mock implements AuthService {
  @override
  Future<bool> signOut() async {
    return Future.value(true);
  }
}

class MockApiService extends Mock implements ApiService {
  @override
  Future<List<Module>> fetchModules() async {
    return [Module(code: "CS2040S", title: "Data Structures and Algorithms")];
  }
}

class MockAlertService extends Mock implements AlertService {}

class MockNavigationService extends Mock implements NavigationService {}

class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  group('profile page test', () {
    late AuthService authService;
    late AlertService alertService;
    late ApiService apiService;
    late NavigationService navigationService;
    late DatabaseService databaseService;

    setUp(() {
      apiService = MockApiService();
      authService = MockAuthService();
      alertService = MockAlertService();
      navigationService = MockNavigationService();
      databaseService = MockDatabaseService();

      final getIt = GetIt.instance;
      getIt.registerSingleton<ApiService>(apiService);
      getIt.registerSingleton<AuthService>(authService);
      getIt.registerSingleton<AlertService>(alertService);
      getIt.registerSingleton<NavigationService>(navigationService);
      getIt.registerSingleton<DatabaseService>(databaseService);
    });
    tearDown(() {
      GetIt.instance.reset();
    });
    testWidgets('sign-out button', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Profile(
          profileImageProvider: AssetImage('assets/img/apple.png'),
          coverImageProvider: AssetImage('assets/img/google.png'),
        ) 
      ));

      await tester.pumpAndSettle();

      var logout = find.byIcon(Icons.logout);
      var profile = find.text('Edit Profile');

      expect(logout, findsOneWidget);
      expect(profile, findsOneWidget);

      await tester.tap(profile); 
      await tester.pumpAndSettle();
    });
  });
}