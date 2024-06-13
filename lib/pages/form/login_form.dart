import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:brainsync/common_widgets/custom_form_field.dart';
import 'package:brainsync/common_widgets/square_tile.dart';
import 'package:brainsync/const.dart';
import 'package:brainsync/pages/Administation/forget_password.dart';
import 'package:brainsync/pages/home.dart';
import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:get_it/get_it.dart';

class LoginForm extends StatefulWidget {
  final Function(bool) setLoading;
  final Function navigateToHome;

  const LoginForm({Key? key, required this.setLoading, required this.navigateToHome}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey();
  final GetIt _getIt = GetIt.instance;

  late AlertService _alertService;
  late AuthService _authService;

  String? email, password;

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _authService = _getIt.get<AuthService>();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.05,
        ),
        child: Form(
          key: _loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomFormField(
                labelText: "Email",
                hintText: "Enter a valid email",
                height: MediaQuery.of(context).size.height * 0.09,
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
                height: MediaQuery.of(context).size.height * 0.09,
                validationRegEx: PASSWORD_VALIDATION_REGEX,
                onSaved: (value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
              const SizedBox(height: 30),
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
                      widget.setLoading(true);
                      bool result = await _authService.login(email!, password!);
                      widget.setLoading(false);

                      if (result) {
                        widget.navigateToHome();
                      } else {
                        _alertService.showToast(
                          text: "Invalid email or password! (Check if you have verified your email)",
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
              const SizedBox(height: 30),
              forgetPassword(),
              SquareTile(
                imagePath: "assets/img/google.png",
                onTap: () async {
                  widget.setLoading(true);
                  try {
                    await _authService.signInWithGoogle(context);
                    widget.navigateToHome();
                  } catch (error) {
                    print("Error signing in with Google: $error");
                  } finally {
                    widget.setLoading(false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget forgetPassword() {
    return Center(
      child: TextButton(
        child: Text(
          "Forget Your Password?",
          style: TextStyle(
            decoration: TextDecoration.underline,
            color: Colors.brown.shade800,
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
}