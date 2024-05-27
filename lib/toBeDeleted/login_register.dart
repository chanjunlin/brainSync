import 'package:brainsync/pages/register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:brainsync/auth.dart';
//import 'package:flutter/widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key : key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = 'Invalid email or password';
      });
    }

  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = 'Invalid email or password';
      });
    }
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
    {IconData? prefixIcon}
  ) {
    return TextField (
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      )
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' :  '$errorMessage', style: const TextStyle(
      color: Colors.red,
      fontWeight: FontWeight.bold,
    ));
  }

  Widget _submitButton() {
    return SizedBox(
      width: 250,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.cyan,
          foregroundColor: Colors.white,
        ),
        onPressed:
          isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
        child: Text(isLogin ? 'Login' : 'Register'),
    ),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RegisterPage()),
        );
      },
      child: Text(isLogin ? 'Register here' : 'Login',
      style: const TextStyle(
        decoration: TextDecoration.underline,
        color: Colors.cyan,
      ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        "Welcome To BrainSync!",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      centerTitle: true,
    ),
    body: SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset("assets/img/study.png", alignment: Alignment.topCenter),
            const SizedBox(height: 20),
            const Text(
              "Log in to continue",
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            _entryField('email', _controllerEmail, prefixIcon: Icons.email),
            _entryField('password', _controllerPassword, prefixIcon: Icons.lock),
            _errorMessage(),
            const SizedBox(height: 60),
            _submitButton(),
            const SizedBox(height: 20),
            const SizedBox(height: 100,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                _loginOrRegisterButton(),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}