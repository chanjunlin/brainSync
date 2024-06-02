import 'package:brainsync/common_widgets/dialog.dart';
import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:core';

import '../services/navigation_service.dart';
import 'package:get_it/get_it.dart';

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

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
  }

  Future<void> _createPost() async {
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

  Future<void> _showDiscardDialog(BuildContext context) async {
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

  Widget _sendButton() {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.brown[300],
      ),
      onPressed: _createPost,
      child: const Text('Create Post'),
    );
  }

  Widget _discardButton() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _showDiscardDialog(context);
          },
        ),
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
                  labelText: 'Title',
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
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
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
              Spacer(), // Add Spacer to push buttons to the bottom
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
                        child: _discardButton(),
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
                        child: _sendButton(),
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
