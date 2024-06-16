import 'package:brainsync/services/navigation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../services/alert_service.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final GetIt _getIt = GetIt.instance;
  final TextEditingController _emailController = TextEditingController();

  late AlertService _alertService;
  late NavigationService _navigationService;

  String? errorMessage = " ";

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _navigationService = _getIt.get<NavigationService>();
  }

  Future<void> sendPasswordResetEmail() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text);
      _alertService.showToast(
        text: "Password reset email sent!",
        icon: Icons.check,
      );
      _navigationService.pushReplacementName("/login");
    } on FirebaseAuthException catch (e) {
      _alertService.showToast(
        text: "Invalid email, $e",
        icon: Icons.error_outline_rounded,
      );
    }
  }

  Widget sendButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
        color: Colors.brown[300],
        onPressed: sendPasswordResetEmail,
        child: const Text(
          'Continue',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget entryField(String title, TextEditingController controller,
      {IconData? prefixIcon}) {
    return TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: title,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Forgot Password",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 161, 136, 127),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Forgot Password?",
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Enter you email below to reset your password",
                style: TextStyle(
                  color: Color.fromARGB(255, 79, 78, 78),
                ),
              ),
              const SizedBox(height: 20),
              Image.asset(
                "assets/img/lock1.png",
                alignment: Alignment.topCenter,
              ),
              entryField("email", _emailController, prefixIcon: Icons.email),
              const SizedBox(height: 30),
              sendButton(),
            ],
          ),
        ),
      ),
    );
  }
}
