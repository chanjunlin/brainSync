import 'package:brainsync/pages/Posts/actual_post.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/alert_service.dart';

class MockAuthService extends Mock implements AuthService {}

class MockAlertService extends Mock implements AlertService {}

class MockNavigationService extends Mock implements NavigationService {}

class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  group("comments test", () {
    late MockAuthService authService;
    late MockAlertService alertService;
    late MockNavigationService navigationService;
    late MockDatabaseService databaseService;

    setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
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

    testWidgets("inappropriate text", (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PostDetailPage(
          postId: "t01OXTmo0lzSIOCUViuS",
          title: "CS2040S",
          content: "help me",
          timestamp: DateTime(2024, 7, 26, 12, 30),
          authorName: "John Wong",
        ),
      ));

      var comment = find.byType(TextField);
      expect(comment, findsOneWidget);

      var button = find.byIcon(Icons.send);
      expect(button, findsOneWidget);

      await tester.enterText(comment, 'shit');
      await tester.tap(button);
      await tester.pumpAndSettle();

      verify(alertService.showToast(
      text: 'Comment contains inappropriate content!',
      icon: Icons.error,
    )).called(1);
    });
  });
}