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

class signUpForm extends StatefulWidget {
  const signUpForm({
    super.key,
  });

  @override
  State<signUpForm> createState() => _signUpFormState();
}

class _signUpFormState extends State<signUpForm> {
  String? name,email,password, repassword;
  List<String>? friendList, friendReqList;

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Form(
        key: _signupFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomFormField(
              labelText: "Name",
              hintText: "Name",
              height: MediaQuery.sizeOf(context).height * 0.09,
              validationRegEx: NAME_VALIDATION_REGEX,
              onSaved: (value) {
                setState(() {
                  name = value;
                });
              },
            ),
            CustomFormField(
              labelText: "Email",
              hintText: "email",
              height: MediaQuery.sizeOf(context).height * 0.09,
              validationRegEx: EMAIL_VALIDATION_REGEX,
              obscureText: false,
              onSaved: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
            CustomFormField(
              labelText: "Password",
              hintText: "password",
              height: MediaQuery.sizeOf(context).height * 0.09,
              validationRegEx: PASSWORD_VALIDATION_REGEX,
              obscureText: true,
              onSaved: (value) {
                setState(() {
                  password = value;
                });
              },
            ),
            CustomFormField(
              labelText: "Retype Password",
              hintText: "password",
              height: MediaQuery.sizeOf(context).height * 0.1,
              validationRegEx: PASSWORD_VALIDATION_REGEX,
              obscureText: true,
              onSaved: (value) {
                setState(() {
                  repassword = value;
                });
              },
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  try {
                    if (_signupFormKey.currentState?.validate() ?? false) {
                      _signupFormKey.currentState?.save();
                      if (repassword == password) {
                        String result = await _authService.register(name!, password!, email!);
                        if (result == "true"){
                          print("hi");
                          await _databaseService.createUserProfile(
                              userProfile: UserProfile(
                                  uid: _authService.user!.uid,
                                  firstName: name,
                                  lastName: "doggie",
                                  pfpURL: PLACEHOLDER_PFP,
                                  profileCoverURL: PLACEHOLDER_PROFILE_COVER,
                                  friendList: friendList,
                                  friendReqList: friendReqList,
                              ),
                          );
                          _alertService.showToast(
                            text: "Registered successfully!",
                            icon: Icons.check,
                          );
                          _navigationService.pushReplacementName("/login");
                        } else {
                          throw Exception("Unable to register user");
                        }

                      } else {
                        _alertService.showToast(
                          text: "Passwords do not match!",
                          icon: Icons.error_outline_rounded ,
                        );
                      }
                    }
                  } on FirebaseAuthException catch (e) {
                    setState(() {
                      print("wrong");
                    });
                  }
                },
                child: const Text('Sign Up'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
