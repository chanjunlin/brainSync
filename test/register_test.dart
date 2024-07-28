import 'package:brainsync/common_widgets/custom_form_field.dart';
import 'package:brainsync/pages/form/signup_form.dart';
import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
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

    testWidgets('Form fields and SignUp button are rendered correctly',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(body: SignUpForm()),
            ),
          );

          expect(find.byType(CustomFormField), findsNWidgets(5));
          expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
          expect(find.byType(ElevatedButton), findsOneWidget);
          expect(find.text('Sign Up'), findsOneWidget);
        });

    testWidgets('Empty form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SignUpForm()),
        ),
      );

      await tester.tap(find.byKey(const Key('signupbutton')));
      await tester.pumpAndSettle();

      expect(find.text('First name is required'), findsOneWidget);
      expect(find.text('Last name is required'), findsOneWidget);
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsAtLeastNWidgets(2));
      expect(find.text('Please select a year'), findsOneWidget);
    });

    testWidgets('Invalid character in first name and last name field',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(body: SignUpForm()),
            ),
          );
          var firstNameField = find.byKey(const Key("firstNameField"));
          var lastNameField = find.byKey(const Key("lastNameField"));
          await tester.enterText(firstNameField, 'junlin-');
          await tester.enterText(lastNameField, 'chan!!');

          await tester.tap(find.byKey(const Key('signupbutton')));
          await tester.pumpAndSettle();

          expect(find.text('First name can only contain letters & space'),
              findsOneWidget);

          expect(find.text('Last name can only contain letters & space'),
              findsOneWidget);
        });

    testWidgets('Testing email', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SignUpForm()),
        ),
      );
      var emailField = find.byKey(const Key("emailField"));
      await tester.enterText(emailField, 'junlin@test.com');

      await tester.tap(find.byKey(const Key('signupbutton')));
      await tester.pumpAndSettle();

      expect(
          find.text('Enter a valid email address (Gmail or @u.nus.edu only)'),
          findsOneWidget);

      await tester.enterText(emailField, 'junlin@gmail.com');

      await tester.tap(find.byKey(const Key('signupbutton')));
      await tester.pumpAndSettle();

      expect(
          find.text('Enter a valid email address (Gmail or @u.nus.edu only)'),
          findsNothing);
    });

    testWidgets('Testing password', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SignUpForm()),
        ),
      );
      var passwordField = find.byKey(const Key("passwordField"));
      var repasswordField = find.byKey(const Key("repasswordField"));

      await tester.enterText(passwordField, 'test');
      await tester.tap(find.byKey(const Key('signupbutton')));
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 8 characters long'),
          findsOneWidget);

      await tester.enterText(passwordField, 'TestTest');
      await tester.tap(find.byKey(const Key('signupbutton')));
      await tester.pumpAndSettle();

      expect(
          find.text(
              'Password must include Uppercase and lowercase letters, numbers and special characters'),
          findsOneWidget);

      await tester.enterText(passwordField, 'Test123!');
      await tester.tap(find.byKey(const Key('signupbutton')));
      await tester.pumpAndSettle();

      expect(
          find.text(
              'Password must include Uppercase and lowercase letters, numbers and special characters'),
          findsNothing);
      expect(find.text('Password must be at least 8 characters long'),
          findsNothing);

      await tester.enterText(passwordField, 'Test123!');
      await tester.enterText(repasswordField, 'Test123!!');
      await tester.tap(find.byKey(const Key('signupbutton')));
      await tester.pumpAndSettle();

      verify(alertService.showToast(text: 'Passwords do not match!', )).called(1);

    });
  });
}
