import 'package:brainsync/auth.dart';
import 'package:brainsync/pages/form/login_form.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../common_widgets/custom_form_field.dart';
import '../../const.dart';
import '../../services/alert_service.dart';
import '../../services/auth_service.dart';
import 'forget_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _loginFormKey = GlobalKey();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;


  late NavigationService _navigationService;
  late AlertService _alertService;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _authService = _getIt.get<AuthService>();
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white, // Set the background color here
      body: _isLoading ? buildLoadingScreen() : buildUI(), // Show loading screen if _isLoading is true
    );
  }

  Widget buildUI() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
          SizedBox(height: 10),
          Image.asset(
            "assets/img/study.png",
            alignment: Alignment.topCenter,
            fit: BoxFit.fitWidth,
          ),
        ],
      ),
    );
  }

  Widget createAnAccount() {
          const SizedBox(height: 10),
          return Container(
            width: double.infinity,  // Matches the width of the form fields
            child: Image.asset(
              "assets/img/study.png",
              alignment: Alignment.topCenter,
              fit: BoxFit.fitWidth, // Ensure the image fits within the container width
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginForm() {
    return Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomFormField(
              labelText: "Email",
              hintText: "Enter a valid email",
              height: MediaQuery.sizeOf(context).height * 0.09,
              validationRegEx: EMAIL_VALIDATION_REGEX,
              onSaved: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
            CustomFormField(
              labelText: "Password",
              hintText: "Enter a valid password",
              obscureText: true,
              height: MediaQuery.sizeOf(context).height * 0.09,
              validationRegEx: PASSWORD_VALIDATION_REGEX,
              onSaved: (value) {
                setState(() {
                  password = value;
                });
              },
            ),
            _forgetPassword(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  if (_loginFormKey.currentState?.validate() ?? false) {
                    _loginFormKey.currentState?.save();
                    bool result = await _authService.login(email!, password!);
                    if (result) {
                      _navigationService.pushReplacementName("/home");
                    } else {
                      _alertService.showToast(
                        text: "Invalid email or password! (Checked if you have verified your email)",
                        icon: Icons.error_outline_rounded,
                      );
                    }
                  }
                },
                child: const Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text("----------or sign in with----------", style: TextStyle(
                fontSize: 12,
                color: Color.fromARGB(255, 78, 52, 46),
              ),
              ),
            ),
            _googlebutton(),
          ],
        ),
      );
  }

  Widget _forgetPassword() {
    return Center(
      child: TextButton(
        child: Text(
          "Forget Your Password?",
          style: TextStyle(
            decoration: TextDecoration.underline,
            color: Colors.brown.shade800,
            fontSize: 12,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ForgetPassword(),
            ),
          );
        },
      ),
    );
  }

  Widget _googlebutton() {
    return Center(child: SizedBox(
      height: 50,
      child: SignInButton(Buttons.google,
      text: "google",
      onPressed: _googlesignin,
      ),
    ),);
  }

  void _googlesignin() {
    try {
      GoogleAuthProvider _googleAuthProvider = GoogleAuthProvider();
      _auth.signInWithProvider(_googleAuthProvider);
    }
    catch (error) {
      print(error);
    }
  }

  Widget _createAnAccount() {
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


