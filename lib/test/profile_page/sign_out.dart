import 'package:brainsync/model/module.dart';
import 'package:brainsync/pages/Profile/user_profile/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';
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

class MockNavigationService extends Mock implements NavigationService {
  @override
  Future<void> pushReplacementName(String routeName) {
    return Future.value();
  }
}

class MockDatabaseService extends Mock implements DatabaseService {
  @override
  Future<DocumentSnapshot> fetchCurrentUser() async {
    final profileData = {
      'bio': 'Help me plsz',
      'firstName': 'John',
      'lastName': 'Wong',
      'pfpURL': 'assets/img/apple.png',
      'profileCoverURL': 'assets/img/google.png',
      'uid': 'test_uid',
      'year': '2024',
      'completedModules': [],
      'currentModules': [],
      'currentCredits': 0,
      'friendList': [],
      'friendReqList': [],
      'myComments': [],
      'myPosts': [],
      'myLikedComments': [],
      'myLikedPosts': [],
    };
    final mockDocumentSnapshot = MockDocumentSnapshot(profileData);
    return Future.value(mockDocumentSnapshot);
  }
}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {
  final Map<String, dynamic> _data;

  MockDocumentSnapshot(this._data);

  @override
  bool get exists => true;

  @override
  Map<String, dynamic> data() => _data;
}


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
      await tester.pumpWidget(MaterialApp(
        home: const Profile(
          profileImageProvider: AssetImage('assets/img/apple.png'),
          coverImageProvider: AssetImage('assets/img/google.png'),
        ),
        routes: {
          '/login': (context) => const Scaffold(body: Text('Login Page')),
        },
      ));

      await tester.pumpAndSettle();

      var logout = find.byIcon(Icons.logout);

      expect(logout, findsOneWidget);

      await tester.tap(logout); 
      await tester.pumpAndSettle();
    });
  });
}