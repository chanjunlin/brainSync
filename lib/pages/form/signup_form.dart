import 'dart:ffi';

import 'package:brainsync/model/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../const.dart';
import '../../services/alert_service.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/media_service.dart';
import '../../services/navigation_service.dart';
import '../../common_widgets/custom_form_field.dart';
import '../../services/storage_service.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
  });

  @override
  State<SignUpForm> createState() => SignUpFormState();
}

class SignUpFormState extends State<SignUpForm> {
  String? firstName, lastName, email, password, repassword, selectedYear;
  List<String>? friendList, friendReqList, currentModules, completedModules;

  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _signupFormKey = GlobalKey();

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late MediaService _mediaService;
  late StorageService _storageService;
  late DatabaseService _databaseService;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _storageService = _getIt.get<StorageService>();
    _mediaService = _getIt.get<MediaService>();
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
            Row(
              children: [
                Expanded(
                  child: CustomFormField(
                    labelText: "First Name",
                    hintText: "First Name",
                    height: MediaQuery.sizeOf(context).height * 0.09,
                    validationRegEx: NAME_VALIDATION_REGEX,
                    onSaved: (value) {
                      setState(() {
                        firstName = value;
                      });
                    },
                    // prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: CustomFormField(
                    labelText: "Last Name",
                    hintText: "Last Name",
                    height: MediaQuery.sizeOf(context).height * 0.09,
                    validationRegEx: NAME_VALIDATION_REGEX,
                    onSaved: (value) {
                      setState(() {
                        lastName = value;
                      });
                    },
                    // prefixIcon: Icon(Icons.person),
                  ),
                ),
              ],
            ),
            CustomFormField(
              labelText: "Email",
              hintText: "Email",
              height: MediaQuery.sizeOf(context).height * 0.09,
              validationRegEx: EMAIL_VALIDATION_REGEX,
              obscureText: false,
              onSaved: (value) {
                setState(() {
                  email = value;
                });
              },
              // prefixIcon: Icon(Icons.email),
            ),
            CustomFormField(
              labelText: "Password",
              hintText: "Password",
              height: MediaQuery.sizeOf(context).height * 0.09,
              validationRegEx: PASSWORD_VALIDATION_REGEX,
              obscureText: true,
              onSaved: (value) {
                setState(() {
                  password = value;
                });
              },
              // prefixIcon: Icon(Icons.lock),
            ),
            CustomFormField(
              labelText: "Retype Password",
              hintText: "Retype Password",
              height: MediaQuery.sizeOf(context).height * 0.09,
              validationRegEx: PASSWORD_VALIDATION_REGEX,
              obscureText: true,
              onSaved: (value) {
                setState(() {
                  repassword = value;
                });
              },
              // prefixIcon: Icon(Icons.lock),
            ),
            DropdownButtonFormField<String>(
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
                    color: Colors.brown, // Set the color to brown when focused
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
                  child: Text(year), // Removed the icon
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
              style: TextStyle(color: Colors.black),
              dropdownColor: Color(0xFFF8F9FF),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
                            if (repassword == password) {
                              String result = await _authService.register(
                                firstName!,
                                password!,
                                email!,
                              );
                              if (result == "true") {
                                await _databaseService.createUserProfile(
                                  userProfile: UserProfile(
                                    uid: _authService.user!.uid,
                                    firstName: firstName,
                                    lastName: lastName,
                                    pfpURL: PLACEHOLDER_PFP,
                                    profileCoverURL: PLACEHOLDER_PROFILE_COVER,
                                    friendList: friendList,
                                    friendReqList: friendReqList,
                                    year: selectedYear,
                                    completedModules: [],
                                    currentModules: [],
                                  ),
                                );
                                await _authService.sendEmailVerification();
                                // Update UI or navigate to a screen to inform the user to check their email
                                _alertService.showToast(
                                  text:
                                      "Registered successfully! Please check your email for verification.",
                                  icon: Icons.check,
                                );
                                // Navigate to login screen or any other screen
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
                    ? CircularProgressIndicator(
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
