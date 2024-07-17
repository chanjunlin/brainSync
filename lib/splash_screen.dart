import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:brainsync/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late AnimationController _controller;
  late Animation<Offset> brainAnimation;
  late Animation<Offset> syncAnimation;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    brainAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    syncAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    String initialRoute = _authService.currentUser == null ? '/login' : '/home';
    Navigator.pushReplacementNamed(context, initialRoute);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade300,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SlideTransition(
              position: brainAnimation,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: const Text(
                  'Brain',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SlideTransition(
              position: syncAnimation,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: const Text(
                  'Sync',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
