import 'package:brainsync/pages/form/login_form.dart';
import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';

class MockAuthService extends Mock implements AuthService {
  @override
  Future<bool> login(String email, String password) {
    return super.noSuchMethod(
      Invocation.method(#login, [email, password]),
      returnValue: Future.value(true),
      returnValueForMissingStub: Future.value(true),
    );
  }
}

class MockAlertService extends Mock implements AlertService {}

class MockNavigationService extends Mock implements NavigationService {}

void main() {

  group('Login Page Widget Tests', () {
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

    testWidgets('Valid account', (WidgetTester tester) async {
      bool navigatedToHome = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: LoginForm(
              setLoading: (_) {},
              navigateToHome: () {
                navigatedToHome = true;
              },
              navigateToLogin: () {},
            )),
      ));

      await tester.pump();

      var emailField = find.byKey(const Key('emailField'));
      var passwordField = find.byKey(const Key('passwordField'));
      var button = find.text("Login");
      var googlebutton = find.text("Sign in with Google");

      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(button, findsOneWidget);
      expect(googlebutton, findsOneWidget);

      when(authService.login('wuchenfeng0214@gmail.com', 'Palkia123!'))
          .thenAnswer((_) async => true); //using this account as an example

      await tester.enterText(emailField, 'wuchenfeng0214@gmail.com');
      await tester.enterText(passwordField, 'Palkia123!');
      await tester.tap(button);
      await tester.tap(googlebutton);
      await tester.pumpAndSettle();

      verify(authService.login('wuchenfeng0214@gmail.com', 'Palkia123!'))
          .called(1);

      expect(navigatedToHome, isTrue);
    });
    testWidgets("Invalid email", (WidgetTester tester) async {
      bool navigatedToHome = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: LoginForm(
              setLoading: (_) {},
              navigateToHome: () {
                navigatedToHome = true;
              },
              navigateToLogin: () {},
            )),
      ));

      await tester.pump();

      var emailField = find.byKey(const Key('emailField'));
      var passwordField = find.byKey(const Key('passwordField'));
      var button = find.text("Login");
      var googlebutton = find.text("Sign in with Google");

      when(authService.login('doesnotexist@gmail.com', 'Palkia123!'))
          .thenAnswer((_) async => false);

      await tester.enterText(emailField, 'doesnotexist@gmail.com');
      await tester.enterText(passwordField, 'Palkia123!');
      await tester.tap(button);
      await tester.tap(googlebutton);
      await tester.pumpAndSettle();

      expect(navigatedToHome, isFalse);
    });
    testWidgets("Invalid password", (WidgetTester tester) async {
      bool navigatedToHome = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: LoginForm(
              setLoading: (_) {},
              navigateToHome: () {
                navigatedToHome = true;
              },
              navigateToLogin: () {},
            )),
      ));

      await tester.pump();

      var emailField = find.byKey(const Key('emailField'));
      var passwordField = find.byKey(const Key('passwordField'));
      var button = find.text("Login");
      var googlebutton = find.text("Sign in with Google");

      when(authService.login('e1115706@u.nus.edu', 'Test123'))
          .thenAnswer((_) async => false);

      await tester.enterText(emailField, 'e1115706@u.nus.edu');
      await tester.enterText(passwordField, 'Test123');
      await tester.tap(button);
      await tester.tap(googlebutton);
      await tester.pumpAndSettle();

      expect(navigatedToHome, isFalse);
    });
    testWidgets("Forget password", (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: LoginForm(
              setLoading: (_) {},
              navigateToHome: () {},
              navigateToLogin: () {},
            )),
      ));

      await tester.pump();

      var forgetPassword = find.text('Forget Your Password?');

      expect(forgetPassword, findsOneWidget);

      await tester.tap(forgetPassword);
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password?'), findsOneWidget);
    });
  });
}
