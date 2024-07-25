import 'dart:io';

import 'package:brainsync/model/module.dart';
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

class MockAuthService extends Mock implements AuthService {}

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
  group('ApiService', () {
    late AuthService authService;
    late AlertService alertService;
    late ApiService apiService;
    late DatabaseService databaseService;
    late NavigationService navigationService;

    setUp(() {
      apiService = MockApiService();
      authService = MockAuthService();
      alertService = MockAlertService();
      databaseService = MockDatabaseService();
      navigationService = MockNavigationService();

      final getIt = GetIt.instance;
      getIt.registerSingleton<ApiService>(apiService);
      getIt.registerSingleton<AuthService>(authService);
      getIt.registerSingleton<AlertService>(alertService);
      getIt.registerSingleton<DatabaseService>(databaseService);
      getIt.registerSingleton<NavigationService>(navigationService);
    });

    tearDown(() {
      GetIt.instance.reset();
    });

    testWidgets('Empty text fields', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: PostsPage(),
      ));

      var moduleCodeField = find.byKey(const Key('ModuleCodeField'));
      expect(moduleCodeField, findsOneWidget);

      var contentField = find.byKey(const Key("ContentField"));
      expect(contentField, findsOneWidget);

      var createButton = find.text("Create Post");
      expect(createButton, findsOneWidget);

      await tester.tap(createButton);
      await tester.pumpAndSettle();

      var validationMessage = find.text("Please enter content");
      await Future.delayed(const Duration(seconds: 5));
      expect(validationMessage, findsOneWidget);
    });

    testWidgets('Empty module code field', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: PostsPage(),
      ));

      var moduleCodeField = find.byKey(const Key('ModuleCodeField'));
      expect(moduleCodeField, findsOneWidget);

      var contentField = find.byKey(const Key("ContentField"));
      expect(contentField, findsOneWidget);

      var createButton = find.text("Create Post");
      expect(createButton, findsOneWidget);

      await tester.enterText(contentField, 'Sample content');

      await tester.tap(createButton);
      await tester.pumpAndSettle();

      var validationMessage = find.text('Please enter a valid module code');
      await Future.delayed(const Duration(seconds: 5));
      expect(validationMessage, findsOneWidget);

    });

    testWidgets('Empty content field', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: PostsPage(),
      ));

      var moduleCodeField = find.byKey(const Key('ModuleCodeField'));
      expect(moduleCodeField, findsOneWidget);

      var contentField = find.byKey(const Key("ContentField"));
      expect(contentField, findsOneWidget);

      var createButton = find.text("Create Post");
      expect(createButton, findsOneWidget);

      await tester.enterText(moduleCodeField, 'CS2040S');

      await tester.tap(createButton);
      await tester.pumpAndSettle();

      var validationMessage = find.text('Please enter content');
      await Future.delayed(const Duration(seconds: 5));
      expect(validationMessage, findsOneWidget);

    });

    testWidgets('Invalid module code', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: PostsPage(),
      ));

      var moduleCodeField = find.byKey(const Key('ModuleCodeField'));
      expect(moduleCodeField, findsOneWidget);

      var contentField = find.byKey(const Key("ContentField"));
      expect(contentField, findsOneWidget);

      var createButton = find.text("Create Post");
      expect(createButton, findsOneWidget);

      await tester.enterText(moduleCodeField, 'CS2040');
      await tester.enterText(contentField, 'What is this?');

      await tester.tap(createButton);
      await tester.pumpAndSettle();

      alertService.showToast(text: 'Invalid module code!');
      await tester.pumpAndSettle();

      var validationMessage = find.text('Invalid module code!');
      await Future.delayed(const Duration(seconds: 5));
      expect(validationMessage, findsOneWidget);

    });
  });
}
