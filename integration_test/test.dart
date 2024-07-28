import 'package:brainsync/pages/Administation/login.dart';
import 'package:brainsync/pages/Administation/register.dart';
import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';

import '../test/login_test.dart';

class MockNavigationService extends Mock implements NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Future<void> pushName(String routeName, {Object? arguments}) async {
    await navigatorKey.currentState?.push(
      PageRouteBuilder(
        pageBuilder: (BuildContext context, Animation<double> animation1,
            Animation<double> animation2) {
          final pageBuilder = routes[routeName];
          if (pageBuilder != null) {
            return pageBuilder(context);
          } else {
            throw Exception('Route "$routeName" not found');
          }
        },
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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
    final getIt = GetIt.instance;
    getIt.reset();
  });

  testWidgets(
      'Navigates from LoginPage to RegisterPage on Sign Up button click',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const LoginPage(),
        routes: {
          '/register': (context) => const RegisterPage(),
        },
      ),
    );

    // Verify the presence of the "Sign Up" text
    expect(find.text("Don\'t have an account? "), findsOneWidget);
    expect(find.text("Sign Up"), findsOneWidget);

    // Find the TextButton
    final signUpButton = find.text("Sign Up");
    expect(signUpButton, findsOneWidget);

    // Click the TextButton
    await tester.tap(signUpButton);
    await tester.pumpAndSettle(); // Wait for navigation to complete

    // Verify that navigation occurred to the RegisterPage
    verify(navigationService.pushName('/register')).called(1);

    // Check if RegisterPage is displayed
    expect(find.byType(RegisterPage), findsOneWidget);
  });
}
