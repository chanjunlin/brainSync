import 'package:brainsync/pages/Administation/login.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/alert_service.dart';

class MockAuthService extends Mock implements AuthService {}

class MockAlertService extends Mock implements AlertService {}

class MockNavigationService extends Mock implements NavigationService {}

void main() {
  group('sign up button test', () {
    late MockAuthService authService;
    late MockAlertService alertService;
    late MockNavigationService navigationService;

    setUp(() {
      authService = MockAuthService();
      alertService = MockAlertService();
      navigationService = MockNavigationService();

      final getIt = GetIt.instance;
      getIt.registerSingleton<AuthService>(authService);
      getIt.registerSingleton<AlertService>(alertService);
      getIt.registerSingleton<NavigationService>(navigationService);
    });

    tearDown(() {
      GetIt.instance.reset();
    });

    testWidgets("sign up button", (WidgetTester tester) async {     
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: LoginPage()),
      ));

      await tester.pump();

      var signupbutton = find.text('Sign Up');

      expect(signupbutton, findsOneWidget);

      await tester.tap(signupbutton);
      await tester.pumpAndSettle();
    });
  });
}


