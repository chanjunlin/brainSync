import 'package:brainsync/pages/home.dart';
import 'package:brainsync/pages/Posts/post.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/alert_service.dart';

class MockAuthService extends Mock implements AuthService {}

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
  group('home page test', () {
    late MockAuthService authService;
    late MockAlertService alertService;
    late MockNavigationService navigationService;
    late MockDatabaseService databaseService;

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

    testWidgets("home page test", (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => const Scaffold(body: Home()),
          '/post': (context) => const PostsPage(),
        },
      ));

      await tester.pump();

      expect(find.byType(CurvedNavigationBar), findsOneWidget);

      var chat = find.byIcon(Icons.chat);
      var add = find.byIcon(Icons.add);
      var notification = find.byIcon(Icons.notifications);
      var person = find.byIcon(Icons.person);

      expect(chat, findsOneWidget);
      expect(add, findsOneWidget);
      expect(notification, findsOneWidget);
      expect(person, findsOneWidget);

      await tester.tap(add);
      await tester.pumpAndSettle();

      verify(navigationService.pushReplacementName('/post')).called(1);
    });
  });
}
