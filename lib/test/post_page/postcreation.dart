import 'package:brainsync/model/module.dart';
import 'package:brainsync/pages/Posts/post.dart';
import 'package:brainsync/services/api_service.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/alert_service.dart';

class MockAlertService extends Mock implements AlertService {}

class MockAuthService extends Mock implements AuthService {}

class MockNavigationService extends Mock implements NavigationService {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockApiService extends Mock implements ApiService {
  static const String baseUrl = "api.nusmods.com";
  static const String apiVersion = "v2";

  @override
  Future<List<Module>> fetchModules() async {
    return [
      Module(code: 'ABC123', title: 'Module 1'),
      Module(code: 'DEF456', title: 'Module 2'),
    ];
  }

  @override
  String getCurrentAcadYear() {
    final DateTime now = DateTime.now();
    final DateTime midJuly = DateTime(now.year, 7, 15); 
    final int startYear = now.isBefore(midJuly) ? now.year - 1 : now.year;
    final int endYear = startYear + 1;
    return '$startYear-$endYear';
  }
}

void main () {
  group('post creation page', (){
    late MockAuthService authService;
    late MockAlertService alertService;
    late MockNavigationService navigationService;
    late MockDatabaseService databaseService;
    late MockApiService apiService;

    setUpAll(() async {
      await Firebase.initializeApp();
    });


    setUp(() {
      authService = MockAuthService();
      alertService = MockAlertService();
      navigationService = MockNavigationService();
      databaseService = MockDatabaseService();
      apiService = MockApiService();

      final getIt = GetIt.instance;
      getIt.registerSingleton<AuthService>(authService);
      getIt.registerSingleton<AlertService>(alertService);
      getIt.registerSingleton<NavigationService>(navigationService);
      getIt.registerSingleton<DatabaseService>(databaseService);
      getIt.registerSingleton<ApiService>(apiService);
  });
  tearDown(() {
      GetIt.instance.reset();
    });

    testWidgets("post creation test", (WidgetTester tester) async {

      when(apiService.fetchModules()).thenAnswer((_) async => [
        Module(code: 'ABC123', title: 'Module 1'),
        Module(code: 'DEF456', title: 'Module 2'),
      ]);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: PostsPage()),
      ));

      await apiService.fetchModules();
      await tester.pumpAndSettle();

      //idk why it fetchmodules is not loaded zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
    });
});
}