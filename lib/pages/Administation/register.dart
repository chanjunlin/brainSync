import 'dart:io';
import 'package:brainsync/pages/form/form_header.dart';
import 'package:brainsync/pages/form/signup_form.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../services/navigation_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? name, email, password;

  final GetIt _getIt = GetIt.instance;

  late NavigationService _navigationService;

  File? selectedImage;

  @override
  void initState() {
    super.initState();
    _navigationService = _getIt.get<NavigationService>();
  }

  String? errorMessage = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Welcome to BrainSync!",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.brown[300],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FormHeader(
              image: Image.asset(
                "assets/img/people.png",
                height: MediaQuery.of(context).size.height * 0.25,
                fit: BoxFit.contain,
              ),
              title: 'Get on board!',
              subTitle: 'Create your profile to start your journey',
            ),
            const SignUpForm(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            TextButton(
              onPressed: () {
                _navigationService.pushName("/login");
              },
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(
                        color: Colors.brown[800],
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
                    TextSpan(
                      text: "Login",
                      style: TextStyle(
                        color: Colors.brown[800],
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
