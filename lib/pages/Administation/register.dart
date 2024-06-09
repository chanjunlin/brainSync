import 'dart:io';

import 'package:brainsync/pages/form/form_header.dart';
import 'package:brainsync/services/media_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../const.dart';
import '../../services/auth_service.dart';
import '../../services/navigation_service.dart';
import 'package:brainsync/pages/form/signup_form.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? name, email, password;

  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _signupFormKey = GlobalKey();

  late AuthService _authService;
  late NavigationService _navigationService;
  late MediaService _mediaService;

  File? selectedImage;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _mediaService = _getIt.get<MediaService>();
  }

  String? errorMessage = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 10,
            ),
            FormHeader(
              image: Image.asset("assets/img/people.png"),
              title: 'Get on board!',
              subTitle: 'Create your profile to start your journey',
            ),
            const SignUpForm(),
            Column(
              children: [
                // const Text('OR'),
                // SizedBox(
                //   width: double.infinity,
                //   child: OutlinedButton.icon(
                //     onPressed: () {},
                //     icon: Icon(Icons.email),
                //     label: Text("Sign-In with Google"),
                //   ),
                // ),
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
                          ),
                        ),
                        TextSpan(
                          text: "Login",
                          style: TextStyle(
                            color: Colors.brown[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }
}