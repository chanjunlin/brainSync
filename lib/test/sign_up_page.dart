/*import 'package:brainsync/model/user_profile.dart';
import 'package:brainsync/pages/form/signup_form.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/main.dart'; // Ensure this is the correct path to your main.dart
import 'package:mockito/mockito.dart';

class MockAlertService extends Mock implements AlertService {}

class MockAuthService extends Mock implements AuthService {}

class MockNavigationService extends Mock implements NavigationService {}

class MockDatabaseService extends Mock implements DatabaseService {}

void main () {
  group('sign up page test', () {
    late MockAuthService authService;
    late MockAlertService alertService;
    late MockNavigationService navigationService;
    late MockDatabaseService databaseService;

    setUpAll(() async {
      await Firebase.initializeApp();
    });


    setUp(() {
      authService = MockAuthService();
      alertService = MockAlertService();
      navigationService = MockNavigationService();
      databaseService = MockDatabaseService();

      final getIt = GetIt.instance;
      getIt.registerSingleton<AuthService>(authService);
      getIt.registerSingleton<AlertService>(alertService);
      getIt.registerSingleton<NavigationService>(navigationService);
      getIt.registerSingleton<DatabaseService>(databaseService);
  });

  tearDown(() {
      GetIt.instance.reset();
    });

    testWidgets("an account should be created when valid username and password are entered", (WidgetTester tester) async {
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

      await tester.enterText(firstNameField, 'John');
      await tester.enterText(lastNameField, 'Wong');
      await tester.enterText(emailField, 'johnwong@example.com');
      await tester.enterText(passwordField, 'TestPassword123!');
      await tester.enterText(repasswordField, 'TestPassword123!');
      await tester.tap(yearField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Year 1'));
      await tester.pumpAndSettle();

      isLoading = false;
      await tester.pump();
      
      print("Before tapping button: isLoading=$isLoading");
      await tester.tap(button);
      await tester.pumpAndSettle();
      print("After tapping button: isLoading=$isLoading");
    });
  });
}*/