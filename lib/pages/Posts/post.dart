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

import '../../services/navigation_service.dart';

class PostsPage extends StatefulWidget {
  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? userProfilePfp, name;

  late AlertService _alertService;
  late AuthService _authService;
  late NavigationService _navigationService;
  final GetIt _getIt = GetIt.instance;

  List<Module> _modules = [];
  List<Module> _filteredModules = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    _fetchModules();
    _titleController.addListener(() {
      _onSearchChanged();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _fetchModules() async {
    try {
      final modules = await ApiService.fetchModules();
      setState(() {
        _modules = modules;
      });
    } catch (e) {
      print("error");
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterModules(_titleController.text);
    });
  }

  void _filterModules(String type) {
    setState(() {
      _filteredModules = _modules
          .where((module) =>
              module.code.toLowerCase().startsWith(type.toLowerCase()))
          .take(10)
          .toList();
    });
  }

  bool isValidModuleCode(String title) {
    return _modules.any((module) => module.code == title);
  }

  Future<void> createPost() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('posts').add({
        'title': _titleController.text,
        'content': _contentController.text,
        'timestamp': Timestamp.now(),
        'authorName': _authService.currentUser!.uid, //change here
      });

      // Clear the text fields
      _titleController.clear();
      _contentController.clear();

      _alertService.showToast(
        text: "Post created successfully!",
        icon: Icons.check,
      );
      _navigationService.pushName("/home");
    }
  }

  Future<void> showDiscardDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        // makes it so that the user need to close the pop-up
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Discard Post?"),
            content: const SingleChildScrollView(
              child: ListBody(
                children: [
                  Text("Do you want to discard the post?"),
                ],
              ),
            ),
            actions: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                OutlinedButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.brown.shade800),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.brown[300],
                  ),
                  child: const Text("Discard"),
                  onPressed: () {
                    _alertService.showToast(
                      text: "Post has been discarded",
                    );
                    _navigationService.pushName("/home");
                  },
                )
              ])
            ],
          );
        });
  }

  Widget sendButton() {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.brown[300],
      ),
      onPressed: createPost,
      child: const Text('Create Post'),
    );
  }

  Widget discardButton() {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.red[300],
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
            });
      },
      child: const Text('Discard Post'),
    );
  }

  Widget _buildSuggestionList() {
    if (_filteredModules.isEmpty ||
        _titleController.text.isEmpty ||
        isValidModuleCode(_titleController.text)) {
      return Container();
    }
    return Container(
      constraints: const BoxConstraints(maxHeight: 150),
      child: ListView.builder(
        itemCount: _filteredModules.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_filteredModules[index].code),
            onTap: () {
              setState(() {
                _titleController.text = _filteredModules[index]
                    .code; //provide suggestions for title
              });
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Create a Post!",
          style: TextStyle(
            color: Colors.brown[800],
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                style: TextStyle(
                  color: Colors.brown[800],
                ),
                cursorColor: Colors.brown[300],
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Module Code',
                  labelStyle: TextStyle(
                    color: Colors.brown[800],
                  ),
                  focusColor: Colors.brown[300],
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown[300]!),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown[300]!),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a module code';
                  } else if (!isValidModuleCode(value)) {
                    return 'Invalid module code';
                  }
                  return null;
                },
              ),
              _buildSuggestionList(),
              const SizedBox(height: 30),
              TextFormField(
                cursorColor: Colors.brown[300],
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  labelStyle: TextStyle(
                    color: Colors.brown[800],
                  ),
                  focusColor: Colors.brown[300],
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown[300]!),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown[300]!),
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
              const Spacer(), // Add Spacer to push buttons to the bottom
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      // Adjust the padding to control the spacing
                      child: SizedBox(
                        height: 50,
                        // Adjust the height to make the buttons larger
                        child: discardButton(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      // Adjust the padding to control the spacing
                      child: SizedBox(
                        height: 50,
                        // Adjust the height to make the buttons larger
                        child: sendButton(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
