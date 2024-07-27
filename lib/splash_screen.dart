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
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
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
      backgroundColor: Colors.brown.shade100,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Image.asset(
            'assets/img/brainsync.png',
            width: MediaQuery.of(context).size.width * 1,
            height: MediaQuery.of(context).size.height * 1,
          ),
        ),
      ),
    );
  }
}
