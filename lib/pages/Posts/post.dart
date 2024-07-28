import 'dart:async';

import 'package:badword_guard/badword_guard.dart';
import 'package:brainsync/common_widgets/custom_dialog.dart';
import 'package:brainsync/common_widgets/seach_bar_2.dart';
import 'package:brainsync/model/module.dart';
import 'package:brainsync/model/post.dart';
import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/api_service.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../services/navigation_service.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  PostsPageState createState() => PostsPageState();
}

class PostsPageState extends State<PostsPage> {
  String? userProfilePfp, name;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final GetIt _getIt = GetIt.instance;
  final LanguageChecker _checker = LanguageChecker();
  late AlertService _alertService;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late NavigationService _navigationService;
  late ApiService _apiService;
  late Future<List<Module>> futureModules;
  List<Module> filteredModules = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _navigationService = _getIt.get<NavigationService>();
    _apiService = _getIt.get<ApiService>();
    futureModules = _apiService.fetchModules();
    titleController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void filterModules(String query) async {
    final modules = await futureModules;
    setState(() {
      if (query.isEmpty) {
        filteredModules = modules;
      } else {
        filteredModules = modules
            .where((module) =>
            module.code.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  bool isValidModuleCode(String title) {
    return filteredModules.any((module) => module.code == title);
  }

  void clearSearch() {
    titleController.clear();
  }

  void handleSuggestionSelected(String suggestion) {
    setState(() {
      titleController.text = suggestion;
      filteredModules.clear();
    });
  }

  Future<void> createPost() async {
    if (_formKey.currentState!.validate()) {
      String title = titleController.text.trim();
      if (!isValidModuleCode(title)) {
        _alertService.showToast(
          text: "Invalid module code!",
          icon: Icons.error,
        );
        return;
      }

      String content = contentController.text;
      if (_checker.containsBadLanguage(content)) {
        _alertService.showToast(
          text: "Post contains inappropriate content!",
          icon: Icons.error,
        );
        return;
      }

      String filteredContent = _checker.filterBadWords(content);
      await _databaseService.createNewPost(
        post: Post(
          authorName: _authService.currentUser!.uid,
          content: filteredContent,
          title: title,
          timestamp: Timestamp.now(),
        ),
      );

      titleController.clear();
      contentController.clear();
      _alertService.showToast(
        text: "Post created successfully!",
        icon: Icons.check,
      );
      _navigationService.pushReplacementName("/home");
    }
  }

  Widget discardButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[300],
        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.02),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () {
        CustomDialog.show(
          context: context,
          title: "Delete Post",
          content: "Do you want to delete post?",
          cancelText: "Cancel",
          discardText: "Confirm",
          toastText: "Post Cancelled",
          onDiscard: () {
            _navigationService.pushName("/home");
          },
        );
      },
      child: Text(
        'Discard Post',
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.04,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget sendButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.brown[300],
        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.02),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: createPost,
      child: Text(
        'Create Post',
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.04,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Create a Post!",
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.05,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.brown[300],
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height - 150,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Module Code",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[800],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  CustomSearchBar(
                    key: const Key("ModuleCodeField"),
                    controller: titleController,
                    onChanged: (value) {
                      filterModules(value);
                    },
                    suggestions: filteredModules,
                    onSuggestionSelected: handleSuggestionSelected,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    "Content",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[800],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  TextFormField(
                    key: const Key("ContentField"),
                    cursorColor: Colors.brown[300],
                    controller: contentController,
                    decoration: InputDecoration(
                      labelText: 'Content',
                      labelStyle: TextStyle(
                        color: Colors.brown[800],
                      ),
                      prefixIcon: Icon(
                        Icons.text_fields,
                        color: Colors.brown[300],
                      ),
                      focusColor: Colors.brown[300],
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.brown[300]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.brown[300]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.brown[300]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    maxLines: null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter content';
                      }
                      return null;
                    },
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: screenWidth * 0.02),
                          child: discardButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: screenWidth * 0.02),
                          child: sendButton(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
