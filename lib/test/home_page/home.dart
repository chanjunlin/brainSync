import 'package:brainsync/common_widgets/bottomBar.dart';
import 'package:brainsync/pages/Chats/friends_chat.dart';
import 'package:brainsync/pages/home.dart';
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

class MockNavigationService extends Mock implements NavigationService {}

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
      await tester.pumpWidget(const MaterialApp(
        home:Scaffold(body: CustomBottomNavBar(initialIndex: 0)),
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



      await tester.tap(chat);
      await tester.pumpAndSettle(); //why doesnt thus workkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkzzzzzzzzzzzzzzzzzzzzzzzzz

    });
  });
}