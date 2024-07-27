import 'package:brainsync/pages/form/login_form.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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
      backgroundColor: Colors.white,
      body: _isLoading ? buildLoadingScreen() : buildUI(),
    );
  }

  Widget buildUI() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
          child: Column(
            children: [
              headerText(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              LoginForm(
                setLoading: (bool isLoading) {
                  setState(() {
                    _isLoading = isLoading;
                  });
                },
                navigateToHome: () {
                  _navigationService.pushReplacementName("/home");
                },
                navigateToLogin: () {
                  _navigationService.pushReplacementName("/login");
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
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Welcome Back!",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.08,
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
            ),
          ),
          Text(
            "Please sign in to continue",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.04,
              color: Colors.brown[800],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Image.asset(
            "assets/img/study.png",
            width: MediaQuery.of(context).size.width * 1,
            alignment: Alignment.topCenter,
            fit: BoxFit.fitWidth,
          ),
        ],
      ),
    );
  }

  Widget createAnAccount() {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Don\'t have an account? ',
            style: TextStyle(
              color: Colors.brown[800],
              fontSize: MediaQuery.of(context).size.width * 0.04,
            ),
          ),
          TextButton(
            child: Text(
              "Sign Up",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.brown[300],
                fontSize: MediaQuery.of(context).size.width * 0.04,
              ),
            ),
            onPressed: () async {
              _navigationService.pushName("/register");
            },
          ),
        ],
      ),
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
