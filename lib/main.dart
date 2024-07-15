import 'dart:async';
import 'package:brainsync/firebase_options.dart';
import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:brainsync/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
const String academicYear = "2023-2024";

Future<void> main() async {
  await setup();
  runApp(MyApp());
}

Future<void> setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setUpFireBase();
  await registerServices();
}

class MyApp extends StatefulWidget {
  final GetIt _getIt = GetIt.instance;

  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late AlertService _alertService;
  late StreamSubscription<User?> userSubscription;
  late NavigationService _navigationService;

  @override
  void initState() {
    super.initState();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    _alertService = _getIt.get<AlertService>();
    userSubscription = FirebaseAuth.instance.authStateChanges().listen(
          (user) {
        // Avoid redundant sign-out calls
        if (user == null && _authService.currentUser != null) {
          _authService.signOut();
        }
      },
    );
  }

  @override
  void dispose() {
    userSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigationService.navigatorKey,
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      initialRoute: _authService.currentUser == null ? "/login" : "/home",
      routes: _navigationService.routes,
    );
  }
}
