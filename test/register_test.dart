import 'package:brainsync/pages/form/signup_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:brainsync/services/alert_service.dart';
import 'package:mockito/mockito.dart';

class MockAlertService extends Mock implements AlertService {}

class MockAuthService extends Mock implements AuthService {}

class MockNavigationService extends Mock implements NavigationService {}

class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  group('Register page test', () {
    late MockAuthService authService;
    late MockAlertService alertService;
    late MockDatabaseService databaseService;
    late MockNavigationService navigationService;

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

    tearDown(() {
      GetIt.instance.reset();
    });

    tearDown(() {
      GetIt.instance.reset();
    });

    testWidgets("Valid fields -> Account created", (WidgetTester tester) async {
      bool isLoading = false;
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SignUpForm()),
      ));

      await tester.pump();

      var firstNameField = find.byKey(const Key('firstNameField'));
      var lastNameField = find.byKey(const Key('lastNameField'));
      var emailField = find.byKey(const Key('emailField'));
      var passwordField = find.byKey(const Key('passwordField'));
      var repasswordField = find.byKey(const Key('repasswordField'));
      var yearField = find.byKey(const Key('yearField'));
      var button = find.byKey(const Key('signupbutton'));

      expect(firstNameField, findsOneWidget);
      expect(lastNameField, findsOneWidget);
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(repasswordField, findsOneWidget);
      expect(yearField, findsOneWidget);
      expect(button, findsOneWidget);

      expect(
          await authService.register(
              "JunLin", "Test123!", "e1115706@u.nus.edu"),
          'true');
    });
  });
}
