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

    testWidgets('Empty form fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SignUpForm()),
        ),
      );

      await tester.tap(find.byKey(const Key('signupbutton')));
      await tester.pumpAndSettle();

      expect(find.text('Name is required'), findsOneWidget);
      expect(find.text('Name is required '), findsOneWidget);
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required '), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
      expect(find.text('Please select a year'), findsOneWidget);
    });
  });
}
