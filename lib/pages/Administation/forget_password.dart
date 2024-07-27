import 'package:brainsync/common_widgets/edit_text_field.dart';
import 'package:brainsync/services/auth_service.dart';
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
  final _authService = GetIt.instance.get<AuthService>();

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
      await _authService.sendPasswordResetEmail(_emailController.text);
      _alertService.showToast(
        text: "Password reset email sent!",
        icon: Icons.check,
      );
    } on FirebaseAuthException {
      _alertService.showToast(
        text: "Invalid email",
        icon: Icons.error_outline_rounded,
      );
    }
  }

  Widget sendButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown[300],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: sendPasswordResetEmail,
        child: const Text(
          'Continue',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget entryField(String title, TextEditingController controller,
      {IconData? prefixIcon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CustomTextField(
        textController: controller,
        labelText: "Email address",
        vertical: 15,
        horizontal: 15,
        maxLines: 5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
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
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Enter your email below to reset your password",
                style: TextStyle(
                  color: Color.fromARGB(255, 79, 78, 78),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Image.asset(
                "assets/img/lock.png",
                height: 150,
              ),
              entryField("Email", _emailController, prefixIcon: Icons.email),
              const SizedBox(height: 30),
              sendButton(),
            ],
          ),
        ),
      ),
    );
  }
}
