import 'package:brainsync/const.dart';
import 'package:brainsync/pages/Administation/forget_password.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/common_widgets/custom_form_field.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  ValueNotifier userCredential = ValueNotifier('');


  String? email, password;
  String? errorMessage = '';
  bool isLogin = true;

  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _loginFormKey = GlobalKey();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;

  Future<bool> signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  Future<dynamic> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on Exception catch (e) {
      // TODO
      print('exception->$e');
    }
  }

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 20.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _headerText(),
            _loginForm(),
            _createAnAccount(),
          ],
        ),
      ),
    );
  }

  Widget _headerText() {
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
          const SizedBox(height: 10),
          Container(
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
            const SizedBox(height: 15,),
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
    return ValueListenableBuilder(
            valueListenable: userCredential,
            builder: (context, value, child) {
              return (userCredential.value == '' ||
                      userCredential.value == null)
                  ? Center(
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: SizedBox(
                  width: 50,
                  height: 50,
                  child: IconButton(
                    icon: Image.asset(
                      'assets/img/google.jpg',
                    ),
                    onPressed: () async {
                      userCredential.value = await signInWithGoogle();
                      if (userCredential.value != null) {
                        print(userCredential.value!.email);
                        _navigationService.pushReplacementName("/home");
                      }
                    },
                  ),
                ),
              ),
            )
                  : Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    width: 1.5, color: Colors.black54)),
                            child: Image.network(
                                userCredential.value.user!.photoURL.toString()),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(userCredential.value.user!.displayName
                              .toString()),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(userCredential.value.user!.email.toString()),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                              onPressed: () async {
                                bool result = await signOutFromGoogle();
                                if (result) userCredential.value = '';
                              },
                              child: const Text('Logout'))
                        ],
                      ),
                    );
            });
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
}