import 'package:brainsync/pages/Administation/register.dart';
import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

import '../pages/form/signup_form.dart';

class MockAlertService extends Mock implements AlertService {}

class MockAuthService extends Mock implements AuthService {
  @override
  Future<String> register(String name, String password, String email) async {
    // Return a mocked value or handle different scenarios
    return "true"; // Example of a mocked successful registration
  }
}

class MockNavigationService extends Mock implements NavigationService {}

class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  group('Register page test', () {
    late MockAuthService authService;
    late MockAlertService alertService;
    late MockDatabaseService databaseService;
    late MockNavigationService navigationService;
    late Widget registerPage;

    setUp(() {
      authService = MockAuthService();
      alertService = MockAlertService();
      databaseService = MockDatabaseService();
      navigationService = MockNavigationService();

      final getIt = GetIt.instance;
      getIt.registerSingleton<AuthService>(authService);
      getIt.registerSingleton<AlertService>(alertService);
      getIt.registerSingleton<DatabaseService>(databaseService);
      getIt.registerSingleton<NavigationService>(navigationService);
    });

    registerPage = const MaterialApp(
      home: RegisterPage(),
    );

    tearDown(() {
      GetIt.instance.reset();
    });

    testWidgets('Form fields and SignUp button are rendered correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SignUpForm()),
        ),
      );

      await tester.tap(find.byKey(const Key('signupbutton')));
      await tester.pumpAndSettle();

      expect(find.text("Enter a valid first name"), findsOneWidget);
    });
  });
}

