import 'package:brainsync/common_widgets/custom_form_field.dart';
import 'package:brainsync/common_widgets/square_tile.dart';
import 'package:brainsync/const.dart';
import 'package:brainsync/pages/Administation/forget_password.dart';
import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LoginForm extends StatefulWidget {
  final Function(bool) setLoading;
  final Function navigateToHome;
  final Function navigateToLogin;

  const LoginForm({
    super.key,
    required this.setLoading,
    required this.navigateToHome,
    required this.navigateToLogin,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey();
  final GetIt _getIt = GetIt.instance;

  late AlertService _alertService;
  late AuthService _authService;
  String? email, password;
  bool _obscurePassword = true;

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
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
        child: Form(
          key: _loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomFormField(
                key: const Key('emailField'),
                labelText: "Email",
                hintText: "Enter a valid email",
                height: MediaQuery.sizeOf(context).height * 0.07,
                validator: (value) => validateEmail(value),
                onSaved: (value) {
                  setState(() {
                    email = value?.trim();
                  });
                },
              ),
              const SizedBox(height: 15),
              CustomFormField(
                key: const Key('passwordField'),
                labelText: "Password",
                hintText: "Enter a valid password",
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                height: MediaQuery.sizeOf(context).height * 0.07,
                validator: (value) => validatePassword(value),
                onSaved: (value) {
                  setState(() {
                    password = value?.trim();
                  });
                },
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: forgetPassword(),
              ),
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
                    elevation: 5,
                    shadowColor: Colors.brown[100],
                  ),
                  onPressed: () async {
                    if (_loginFormKey.currentState?.validate() ?? false) {
                      _loginFormKey.currentState?.save();
                      widget.setLoading(true);
                      try {
                        bool result =
                            await _authService.login(email!, password!);
                        if (result) {
                          widget.navigateToHome();
                        } else {
                          _alertService.showToast(
                            text: "Invalid email or password!",
                            icon: Icons.error_outline_rounded,
                          );
                        }
                      } catch (error) {
                        _alertService.showToast(
                          text: "Invalid email or password!",
                          icon: Icons.error_outline_rounded,
                        );
                      } finally {
                        widget.setLoading(false);
                      }
                    }
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.brown,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "Or",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.brown[800],
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.brown,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: SquareTile(
                  imagePath: "assets/img/google.png",
                  onTap: () async {
                    widget.setLoading(true);
                    try {
                      print("pressed google button");
                      bool result =
                          await _authService.signInWithGoogle(context);
                      if (result) {
                        widget.navigateToHome();
                      } else {
                        widget.navigateToLogin();
                      }
                    } catch (error) {
                      _alertService.showToast(
                        text: "Error signing in with Google. Please try again.",
                        icon: Icons.error_outline_rounded,
                      );
                    } finally {
                      widget.setLoading(false);
                    }
                  },
                  label: "Sign in with Google",
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget forgetPassword() {
    return TextButton(
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
    );
  }
}
