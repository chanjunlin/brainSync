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

  late NavigationService _navigationService;
  final GetIt _getIt = GetIt.instance;

  @override
  void initState() {
    super.initState();
    _navigationService = _getIt.get<NavigationService>();
  }

  Future<void> _createPost() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('posts').add({
        'title': _titleController.text,
        'content': _contentController.text,
        'timestamp': Timestamp.now(),
        'authorName': "me",                                            //change here
      });

      // Clear the text fields
      _titleController.clear();
      _contentController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );
      _navigationService.pushName("/home");
    }
  }

  Future<void> _showDiscardDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // makes it so that the user need to close the pop-up
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
            OutlinedButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              child: const Text("Discard"),
              onPressed: () {
                _navigationService.pushName("/home");
              },
            )
            ]
            )
          ],
        );
      }
    );
  } 

  Widget _sendButton() {
    return FilledButton(
                onPressed: _createPost,
                child: const Text('Create Post'),
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
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _sendButton(),
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
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}