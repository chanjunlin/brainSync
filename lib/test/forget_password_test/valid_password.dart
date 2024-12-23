import 'package:brainsync/pages/Administation/forget_password.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/navigation_service.dart';

class MockAlertService extends Mock implements AlertService {}

class MockAuthService extends Mock implements AuthService {
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    return super.noSuchMethod(
      Invocation.method(#sendPasswordResetEmail, [email]),
      returnValue: Future.value(),
      returnValueForMissingStub: Future.value(),
    );
  }
}

class MockNavigationService extends Mock implements NavigationService {}

void main() {
  late MockAlertService alertService;
  late MockNavigationService navigationService;
  late MockAuthService authService;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  setUp(() {
    alertService = MockAlertService();
    navigationService = MockNavigationService();
    authService = MockAuthService();

    final getIt = GetIt.instance;
    getIt.registerSingleton<AlertService>(alertService);
    getIt.registerSingleton<NavigationService>(navigationService);
    getIt.registerSingleton<AuthService>(authService);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  testWidgets('valid email test', (WidgetTester tester) async {
    when(authService.sendPasswordResetEmail('wuchenfeng0214@gmail.com'))
        .thenAnswer((_) async {});

    await tester.pumpWidget(const MaterialApp(
      home: ForgetPassword(),
    ));

    var emailField = find.byType(TextField);
    var button = find.text('Continue');

    expect(emailField, findsOneWidget);
    expect(button, findsOneWidget);

    await tester.enterText(emailField, 'wuchenfeng0214@gmail.com');
    await tester.tap(button);
    await tester.pumpAndSettle();

    verify(alertService.showToast(
      text: "Password reset email sent!",
      icon: Icons.check,
    )).called(1);
  });
}
