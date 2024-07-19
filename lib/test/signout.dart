import 'package:brainsync/pages/Profile/profile.dart';
import 'package:brainsync/pages/form/login_form.dart';
import 'package:brainsync/pages/home.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/alert_service.dart';

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

class MockNavigationService extends Mock implements NavigationService {
  @override
  Future<void> pushReplacementName(String routeName, {Object? arguments}) {
    return super.noSuchMethod(
      Invocation.method(#pushReplacementNamed, [routeName, arguments]),
      returnValue: Future.value(),
      returnValueForMissingStub: Future.value(),
    );
  }
}

class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  group('Login Page Widget Tests', () {
    late MockAuthService authService;
    late MockAlertService alertService;
    late MockNavigationService navigationService;
    late DatabaseService databaseService;


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

    testWidgets('Login Button Should Trigger Login Process',
        (WidgetTester tester) async {
      bool navigatedToHome = false;
      bool navigatedToLogin = false;
      bool navigatedToProfile = false;

      when(navigationService.pushReplacementName('/profile'))
          .thenAnswer((_) async {
        navigatedToProfile = true;
      });

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: LoginForm(
          setLoading: (_) {},
          navigateToHome: () {
            navigatedToHome = true;
            Navigator.push(
              tester.element(find.byType(LoginForm)),
              MaterialPageRoute(builder: (context) => const Home()),
            );
          },
          navigateToLogin: () {
            navigatedToLogin = true;
          },
        )),
        routes: {
          '/home': (context) => Scaffold(
            body: Column(
              children: [
                Text('Home Page'),
                IconButton(
                  key: const Key('personIcon'),
                  icon: Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Profile()),
                    );
                  },
                ),
              ],
            ),
          ),
          '/profile': (context) => Scaffold(
            body: Center(child: Text('Profile Page')),
          ),
        },
      ));

      await tester.pump();

      var emailField = find.byKey(const Key('emailField'));
      var passwordField = find.byKey(const Key('passwordField'));
      var loginButton = find.text("Login");
      var googleButton = find.text("Sign in with Google");

      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(loginButton, findsOneWidget);
      expect(googleButton, findsOneWidget);

      await tester.enterText(emailField, 'wuchenfeng0214@gmail.com');
      await tester.enterText(passwordField, 'Palkia123!');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      verify(authService.login('wuchenfeng0214@gmail.com', 'Palkia123!'))
          .called(1);

      expect(navigatedToHome, isTrue);

      var person = find.byIcon(Icons.person);
      expect(person, findsOneWidget);

      await tester.tap(person);
      await tester.pumpAndSettle();

      verify(navigationService.pushReplacementName('/profile')).called(1);

      /*var signout = find.byIcon(Icons.logout);
      expect(signout, findsOneWidget);*/
    });
  });
}