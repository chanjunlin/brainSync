import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../common_widgets/dialog.dart';
import '../../model/module.dart';
import '../../services/alert_service.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/navigation_service.dart';

class PostsPage extends StatefulWidget {
  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AlertService _alertService;
  late AuthService _authService;
  late NavigationService _navigationService;
  final GetIt _getIt = GetIt.instance;

  List<Module> modules = [];
  List<Module> filteredModules = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    fetchModules();
    _titleController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> fetchModules() async {
    try {
      final fetchModules = await ApiService.fetchModules();
      setState(() {
        modules = fetchModules;
      });
    } catch (e) {
      print("Error fetching modules: $e");
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterModules(_titleController.text);
    });
  }

  void _filterModules(String query) async {
    await Future.delayed(Duration(milliseconds: 300));
    setState(() {
      filteredModules = modules
          .where((module) =>
              module.code.toLowerCase().contains(query.toLowerCase()) ||
              module.title.toLowerCase().contains(query.toLowerCase()))
          .take(10)
          .toList();
    });
  }

  bool isValidModuleCode(String title) {
    return modules.any((module) => module.code == title);
  }

  Future<void> createPost() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('posts').add({
        'title': _titleController.text,
        'content': _contentController.text,
        'timestamp': Timestamp.now(),
        'authorName': _authService.currentUser!.uid,
      });

      _titleController.clear();
      _contentController.clear();

      _alertService.showToast(
        text: "Post created successfully!",
        icon: Icons.check,
      );
      _navigationService.pushName("/home");
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
      child: Text(
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
    if (filteredModules.isEmpty ||
        _titleController.text.isEmpty ||
        isValidModuleCode(_titleController.text)) {
      return Container();
    }
    return Container(
      constraints: const BoxConstraints(maxHeight: 150),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.brown[300]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListView.builder(
        itemCount: filteredModules.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(filteredModules[index].code),
            onTap: () {
              setState(() {
                _titleController.text = filteredModules[index].code;
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
        backgroundColor: Colors.brown[200],
        elevation: 0,
      ),
      body: Padding(
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a module code';
                  } else if (!isValidModuleCode(value)) {
                    return 'Invalid module code';
                  }
                  return null;
                },
              ),
              buildSuggestionList(),
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
              Spacer(),
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
    );
  }
}
