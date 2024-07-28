import 'package:brainsync/model/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../common_widgets/custom_form_field.dart';
import '../../const.dart';
import '../../services/alert_service.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/navigation_service.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
  });

  @override
  State<SignUpForm> createState() => SignUpFormState();
}

class SignUpFormState extends State<SignUpForm> {
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController repassword = TextEditingController();

  String? bio, selectedYear;
  List<String>? chats,
      friendList,
      friendReqList,
      currentModules,
      completedModules,
      myComments,
      myPosts;

  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _signupFormKey = GlobalKey();

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureRepassword = true;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  List<String> getYearOptions() {
    return ["Year 1", "Year 2", "Year 3", "Year 4"];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Form(
        key: _signupFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Expanded(
                child: CustomFormField(
                  key: const Key('firstNameField'),
                  labelText: "First Name",
                  hintText: "First Name",
                  height: MediaQuery.sizeOf(context).height * 0.09,
                  validator: (value) => validateFirstName(value?.trim()),
                  onSaved: (value) {
                    setState(() {
                      firstName.text = value!.trim();
                    });
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: CustomFormField(
                  key: const Key('lastNameField'),
                  labelText: "Last Name",
                  hintText: "Last Name",
                  height: MediaQuery.sizeOf(context).height * 0.09,
                  validator: (value) => validateLastName(value?.trim()),
                  onSaved: (value) {
                    setState(() {
                      lastName.text = value!.trim();
                    });
                  },
                ),
              ),
            ]),
            const SizedBox(height: 15),
            CustomFormField(
              key: const Key('emailField'),
              labelText: "Email",
              hintText: "Email",
              height: MediaQuery.sizeOf(context).height * 0.09,
              validator: (value) => validateEmail(value?.trim()),
              obscureText: false,
              onSaved: (value) {
                setState(() {
                  email.text = value!.trim();
                });
              },
            ),
            const SizedBox(height: 15),
            CustomFormField(
              key: const Key('passwordField'),
              labelText: "Password",
              hintText: "Password",
              height: MediaQuery.sizeOf(context).height * 0.09,
              validator: (value) => validatePassword(value?.trim()),
              obscureText: obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),
              onSaved: (value) {
                setState(() {
                  password.text = value!.trim();
                });
              },
            ),
            const SizedBox(height: 15),
            CustomFormField(
              key: const Key('repasswordField'),
              labelText: "Retype Password",
              hintText: "Retype Password",
              height: MediaQuery.sizeOf(context).height * 0.09,
              validator: (value) => validatePassword(value?.trim()),
              obscureText: obscureRepassword,
              suffixIcon: IconButton(
                icon: Icon(
                  obscureRepassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    obscureRepassword = !obscureRepassword;
                  });
                },
              ),
              onSaved: (value) {
                setState(() {
                  repassword.text = value!.trim();
                });
              },
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              key: const Key('yearField'),
              decoration: InputDecoration(
                labelText: "Year",
                filled: true,
                fillColor: Colors.transparent,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: Colors.brown,
                  ),
                ),
                labelStyle: TextStyle(
                  color: Colors.brown[800],
                ),
              ),
              value: selectedYear,
              items: getYearOptions().map((year) {
                return DropdownMenuItem<String>(
                  value: year,
                  child: Text(year),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedYear = value;
                });
              },
              onSaved: (value) {
                setState(() {
                  selectedYear = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a year';
                }
                return null;
              },
              style: const TextStyle(color: Colors.black),
              dropdownColor: const Color(0xFFF8F9FF),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const Key('signupbutton'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.brown[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          if (_signupFormKey.currentState!.validate()) {
                            _signupFormKey.currentState!.save();
                            if (repassword.text == password.text) {
                              String result = await _authService.register(
                                firstName.text,
                                password.text,
                                email.text,
                              );
                              if (result == "true") {
                                await _databaseService.createUserProfile(
                                  userProfile: UserProfile(
                                    bio: bio,
                                    firstName: firstName.text,
                                    lastName: lastName.text,
                                    pfpURL: placeholderPFP,
                                    profileCoverURL: placeholderProfileCover,
                                    uid: _authService.user!.uid,
                                    year: selectedYear,
                                    chats: chats,
                                    currentModules: completedModules,
                                    completedModules: currentModules,
                                    friendList: friendList,
                                    friendReqList: friendReqList,
                                    myComments: myComments,
                                    myPosts: myPosts,
                                  ),
                                );
                                await _authService.sendEmailVerification();
                                _alertService.showToast(
                                  text:
                                      "Registered successfully! Please check your email for verification.",
                                  icon: Icons.check,
                                );
                                _navigationService
                                    .pushReplacementName("/login");
                              } else {
                                throw Exception("Unable to register user");
                              }
                            } else {
                              _alertService.showToast(
                                text: "Passwords do not match!",
                                icon: Icons.error_outline_rounded,
                              );
                            }
                          }
                        } on FirebaseAuthException catch (e) {
                          _alertService.showToast(text: '${e.message}');
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                child: isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text('Sign Up'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
