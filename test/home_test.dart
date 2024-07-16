import 'package:brainsync/pages/Administation/forget_password.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:brainsync/services/alert_service.dart';

class MockAlertService extends Mock implements AlertService {}

class MockNavigationService extends Mock implements NavigationService {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  late MockAlertService alertService;
  late MockNavigationService navigationService;
  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    alertService = MockAlertService();
    navigationService = MockNavigationService();
    mockFirebaseAuth = MockFirebaseAuth();

    final getIt = GetIt.instance;
    getIt.registerSingleton<AlertService>(alertService);
    getIt.registerSingleton<NavigationService>(navigationService);
    getIt.registerSingleton<FirebaseAuth>(mockFirebaseAuth);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  testWidgets('invalid password test', (WidgetTester tester) async {
    // Mock behavior of FirebaseAuth
    when(mockFirebaseAuth.sendPasswordResetEmail(email: ''))
        .thenAnswer((_) =>
            Future<void>.error(FirebaseAuthException(code: 'invalid-email')));

    await tester.pumpWidget(MaterialApp(
      home: ForgetPassword(),
    ));

    var emailField = find.byType(TextField);
    var button = find.text('Continue');

    expect(emailField, findsOneWidget);
    expect(button, findsOneWidget);

    await tester.enterText(emailField, 'doesnotexist@gmail.com');
    await tester.tap(button);
    await tester.pumpAndSettle();

    verify(alertService.showToast(
      text: 'Invalid email, FirebaseAuthException (invalid-email)',
      icon: Icons.error_outline_rounded,
    )).called(1);
  });
}
