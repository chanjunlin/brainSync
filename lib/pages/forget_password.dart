import 'package:brainsync/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:brainsync/auth.dart';


class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
    final TextEditingController _emailController = TextEditingController();
    String? errorMessage = " ";


      Future<void> _sendPasswordResetEmail() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent')));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context)=>const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = "Invalid email";
      });
    }
  }

    Widget _errorMessage() {
    return Text(errorMessage == '' ? '' :  '$errorMessage', style: const TextStyle(
      color: Colors.red,
      fontWeight: FontWeight.bold,
    ));
  }

    Widget _sendButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
      color: Colors.brown[300],
      onPressed: _sendPasswordResetEmail,
      child: const Text('Continue', style: TextStyle(
        color: Colors.white,
      ),),
    ),
    );
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password", style: TextStyle(
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
            const Text("Forgot Password?", style: TextStyle(
              fontSize: 30,
            ),),
            const SizedBox(height: 20),
            const Text("Enter you email below to reset your password", style: TextStyle(
              color: Color.fromARGB(255, 79, 78, 78),
            ),
            ),
            const SizedBox(height: 20),
            Image.asset("assets/img/lock1.png", alignment: Alignment.topCenter,),
            _entryField("email", _emailController, prefixIcon: Icons.email),
            _errorMessage(),
            const SizedBox(height: 30),
            _sendButton(),
          ],
        ),
      ),
      ),
    );
  }
}