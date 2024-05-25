import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:brainsync/auth.dart';
import 'package:get_it/get_it.dart';

import '../services/auth_service.dart';
import '../services/navigation_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  late AuthService _authService;
  late NavigationService _navigationService;

  final GetIt _getIt = GetIt.instance;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
  }

  String? errorMessage = '';

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword = TextEditingController();


  Future<void> createUserWithEmailAndPassword() async {
    if (_controllerPassword.text != _controllerConfirmPassword.text) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
      return;
    }
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      _navigationService.pushReplacementNamed("/login");
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = 'Invalid email or password';
      });
    }
  }

  Widget _entryField(
    String title,
    TextEditingController controller, {bool obscureText = false}
    ) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : '$errorMessage',
      style: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: 250,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.cyan,
          foregroundColor: Colors.white,
        ),
        onPressed: createUserWithEmailAndPassword,
        child: const Text('Register'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to BrainSync", style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 46, 108, 139),
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
              Image.asset("assets/img/study.png", alignment: Alignment.topCenter),
              const SizedBox(height: 20),
              const Text("Hello! Register an account!", style: TextStyle(
                fontSize: 30
              ),
              ),
              _entryField('email', _controllerEmail),
              _entryField('Password', _controllerPassword, obscureText: true),
              _entryField('Confirm Password', _controllerConfirmPassword, obscureText: true),
              _errorMessage(),
              const SizedBox(height: 50,),
              _submitButton(),
            ],
          ),
        )
      ),
    );
  }
}