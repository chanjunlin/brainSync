import 'dart:async';
import 'dart:core';

import 'package:brainsync/common_widgets/dialog.dart';
import 'package:brainsync/model/module.dart';
import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/api_service.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:badword_guard/badword_guard.dart';
import '../../services/navigation_service.dart';

class PostsPage extends StatefulWidget {
  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {

  String? userProfilePfp, name;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final GetIt _getIt = GetIt.instance;
  final LanguageChecker _checker = LanguageChecker();

  late AlertService _alertService;
  late AuthService _authService;
  late NavigationService _navigationService;

  late Future<List<Module>> futureModules;
  List<Module> filteredModules = [];
  Timer? _debounce;


  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    futureModules = ApiService.fetchModules();
    _titleController.addListener(onTitleChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void onTitleChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      filterModules(_titleController.text);
    });
  }

  void filterModules(String query) async {
    final modules = await futureModules;
    setState(() {
      filteredModules = modules
          .where((module) =>
              module.code.toLowerCase().startsWith(query.toLowerCase()))
          .toList();
    });
  }

  bool isValidModuleCode(String title) {
    return filteredModules.any((module) => module.code == title);
  }

  Future<void> createPost() async {
    if (_formKey.currentState!.validate()) {
      String content = _contentController.text;
      
      if (_checker.containsBadLanguage(content)) {
        _alertService.showToast(
          text: "Post contains inappropriate content!",
          icon: Icons.error,
        );
        return;
      }

      String filteredContent = _checker.filterBadWords(content);

      await FirebaseFirestore.instance.collection('posts').add({
        'title': _titleController.text,
        'content': filteredContent,
        'timestamp': Timestamp.now(),
        'authorName': _authService.currentUser!.uid,
      });

      _titleController.clear();
      _contentController.clear();

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
        padding: const EdgeInsets.symmetric(vertical: 14),
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
      child: const Text(
        'Discard Post',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget sendButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.brown[300],
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: createPost,
      child: const Text(
        'Create Post',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildSuggestionList() {
    final currentText = _titleController.text.trim();
    if (currentText.isEmpty || isValidModuleCode(currentText)) {
      return Container();
    }
    final List<Module> visibleModules = filteredModules.take(3).toList();
    return Positioned(
      top: 107,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.brown[300]!),
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFF8F9FF),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: visibleModules.map((module) {
            return ListTile(
              title: Text(module.code),
              onTap: () {
                setState(() {
                  _titleController.text = module.code;
                  filteredModules.clear();
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Create a Post!",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.brown[300],
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Module Code",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[800],
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Module Code',
                      labelStyle: TextStyle(
                        color: Colors.brown[800],
                      ),
                      prefixIcon: Icon(
                        Icons.code,
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
                    style: const TextStyle(fontSize: 16.0),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a module code';
                      } else if (!isValidModuleCode(value)) {
                        return 'Invalid module code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Content",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[800],
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    cursorColor: Colors.brown[300],
                    controller: _contentController,
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
                  const SizedBox(height: 20),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: discardButton(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: sendButton(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          buildSuggestionList(),
        ],
      ),
    );
  }
}