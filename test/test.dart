// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:brainsync/pages/form/signup_form.dart';
// import 'package:brainsync/model/user_profile.dart';
// import 'package:mockito/mockito.dart';
// import 'package:get_it/get_it.dart';
//
// import '../../services/auth_service.dart';
// import '../../services/navigation_service.dart';
// import '../../services/alert_service.dart';
// import '../../services/database_service.dart';
//
// void main() {
//   final GetIt getIt = GetIt.instance;
//
//   setUp(() {
//     getIt.reset();
//     getIt.registerSingleton<AuthService>(MockAuthService());
//     getIt.registerSingleton<NavigationService>(MockNavigationService());
//     getIt.registerSingleton<AlertService>(MockAlertService());
//     getIt.registerSingleton<DatabaseService>(MockDatabaseService());
//   });
//
//   tearDown(() {
//     getIt.reset();
//   });
//
//   testWidgets('Empty fields validation', (WidgetTester tester) async {
//     await tester.pumpWidget(MaterialApp(home: Scaffold(body: SignUpForm())));
//
//     await tester.tap(find.byKey(const Key('signupbutton')));
//     await tester.pump();
//
//     expect(find.text('This field is required'), findsWidgets);
//   });
//
//   testWidgets('Invalid email format', (WidgetTester tester) async {
//     await tester.pumpWidget(MaterialApp(home: Scaffold(body: SignUpForm())));
//
//     await tester.enterText(find.byKey(const Key('emailField')), 'invalidEmail');
//     await tester.tap(find.byKey(const Key('signupbutton')));
//     await tester.pump();
//
//     expect(find.text('Enter a valid email'), findsOneWidget);
//   });
//
//   testWidgets('Password mismatch', (WidgetTester tester) async {
//     await tester.pumpWidget(MaterialApp(home: Scaffold(body: SignUpForm())));
//
//     await tester.enterText(find.byKey(const Key('passwordField')), 'Password123!');
//     await tester.enterText(find.byKey(const Key('repasswordField')), 'Password321!');
//     await tester.tap(find.byKey(const Key('signupbutton')));
//     await tester.pump();
//
//     expect(find.text('Passwords do not match!'), findsOneWidget);
//   });
//
//   testWidgets('Successful registration', (WidgetTester tester) async {
//     final MockAuthService mockAuthService = getIt<AuthService>() as MockAuthService;
//     final MockDatabaseService mockDatabaseService = getIt<DatabaseService>() as MockDatabaseService;
//     final MockNavigationService mockNavigationService = getIt<NavigationService>() as MockNavigationService;
//
//     when(mockAuthService.register(any, any, any)).thenAnswer((_) async => 'true');
//     when(mockAuthService.sendEmailVerification()).thenAnswer((_) async => {});
//
//     await tester.pumpWidget(MaterialApp(home: Scaffold(body: SignUpForm())));
//
//     await tester.enterText(find.byKey(const Key('firstNameField')), 'John');
//     await tester.enterText(find.byKey(const Key('lastNameField')), 'Doe');
//     await tester.enterText(find.byKey(const Key('emailField')), 'john.doe@example.com');
//     await tester.enterText(find.byKey(const Key('passwordField')), 'Password123!');
//     await tester.enterText(find.byKey(const Key('repasswordField')), 'Password123!');
//     await tester.tap(find.byKey(const Key('signupbutton')));
//     await tester.pump();
//
//     verify(mockDatabaseService.createUserProfile(
//       userProfile: anyNamed('userProfile'),
//     )).called(1);
//     verify(mockNavigationService.pushReplacementName('/login')).called(1);
//   });
//
//   testWidgets('Unsuccessful registration (email already in use)', (WidgetTester tester) async {
//     final MockAuthService mockAuthService = getIt<AuthService>() as MockAuthService;
//     final MockAlertService mockAlertService = getIt<AlertService>() as MockAlertService;
//
//     when(mockAuthService.register(any, any, any)).thenThrow(FirebaseAuthException(code: 'email-already-in-use', message: 'Email already in use'));
//
//     await tester.pumpWidget(MaterialApp(home: Scaffold(body: SignUpForm())));
//
//     await tester.enterText(find.byKey(const Key('firstNameField')), 'John');
//     await tester.enterText(find.byKey(const Key('lastNameField')), 'Doe');
//     await tester.enterText(find.byKey(const Key('emailField')), 'john.doe@example.com');
//     await tester.enterText(find.byKey(const Key('passwordField')), 'Password123!');
//     await tester.enterText(find.byKey(const Key('repasswordField')), 'Password123!');
//     await tester.tap(find.byKey(const Key('signupbutton')));
//     await tester.pump();
//
//     verify(mockAlertService.showToast(
//       text: 'Email already in use',
//     )).called(1);
//   });
// }
