import 'package:brainsync/pages/form/login_form.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  final GetIt _getIt = GetIt.instance;

  late NavigationService _navigationService;

  @override
  void initState() {
    super.initState();
    _navigationService = _getIt.get<NavigationService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _isLoading
          ? buildLoadingScreen()
          : buildUI(), // Show loading screen if _isLoading is true
    );
  }

  Widget buildUI() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 20.0,
          ),
          child: Column(
            children: [
              headerText(),
              LoginForm(
                setLoading: (bool isLoading) {
                  setState(() {
                    _isLoading = isLoading;
                  });
                },
                navigateToHome: () {
                  _navigationService.pushReplacementName("/home");
                },
              ),
              createAnAccount(),
            ],
          ),
        ),
      ),
    );
  }

  Widget headerText() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Welcome Back!",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
            ),
          ),
          Text(
            "Please sign in to continue",
            style: TextStyle(
              color: Colors.brown[800],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            child: Image.asset(
              "assets/img/study.png",
              alignment: Alignment.topCenter,
              fit: BoxFit.fitWidth,
            ),
          ),
        ],
      ),
    );
  }

  Widget createAnAccount() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: TextStyle(color: Colors.brown[800]),
        ),
        GestureDetector(
          child: Text(
            "Sign Up",
            style: TextStyle(
                fontWeight: FontWeight.w800, color: Colors.brown[300]),
          ),
          onTap: () async {
            _navigationService.pushName("/register");
          },
        )
      ],
    );
  }

  Widget buildLoadingScreen() {
    return Center(
      child: CircularProgressIndicator(
        color: Colors.brown[300],
      ),
    );
  }
}
