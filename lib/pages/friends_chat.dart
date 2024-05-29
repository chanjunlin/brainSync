import 'package:brainsync/auth.dart';
import 'package:flutter/material.dart';
import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:get_it/get_it.dart';

import '../model/user_profile.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/navigation_service.dart';
import 'chat.dart';

class FriendsChats extends StatefulWidget {
  @override
  _FriendsChatsState createState() => _FriendsChatsState();
}

class _FriendsChatsState extends State<FriendsChats> {
  // variables
  final GetIt _getIt = GetIt.instance;

  late NavigationService _navigationService;
  late DatabaseService _databaseService;
  late AuthService _authService;

  bool hasChats = false;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _databaseService = _getIt.get<DatabaseService>();
    getFriends();
  }

  Future<void> getFriends() async {
    _allFriends = await _databaseService.getFriends();
    setState(() {
      _filteredFriends = _allFriends;
    });
  }

  TextEditingController _searchController = TextEditingController();
  List<UserProfile?> _allFriends = [];
  List<UserProfile?> _filteredFriends =
      []; // Filtered list based on search query

  Future<void> checkChats() async {
    String currentUserId = _authService.user!.uid;
    for (UserProfile? friend in _allFriends) {
      String? friendId = friend?.uid;
      bool chatExists =
          await _databaseService.checkChatExist(currentUserId, friendId!);
      if (chatExists) {
        setState(() {
          hasChats = true;
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends & Chats'),
      ),
      body: Column(
        children: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearch(
                  allFriends: _allFriends,
                ),
              );
            },
            icon: const Icon(Icons.search),
          ),

        ],
      ),
    );
  }
}

class CustomSearch extends SearchDelegate {
  final List<UserProfile?> allFriends; // Add a parameter for allFriends
  final GetIt _getIt = GetIt.instance;

  late DatabaseService _databaseService;
  late AuthService _authService;
  late NavigationService _navigationService;

  CustomSearch({required this.allFriends}) {
    _databaseService = _getIt.get<DatabaseService>();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<UserProfile> matchQuery = [];
    for (var person in allFriends) {
      if (person!.firstName!.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(person);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result.firstName ?? 'No Name'),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<UserProfile> matchQuery = [];
    for (var person in allFriends) {
      if (person!.firstName!.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(person);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result.firstName ?? 'No Name'),
          onTap: () async {
            final chatExists = await _databaseService.checkChatExist(
                _authService.user!.uid, result.uid!);
            if (!chatExists) {
              await _databaseService.createNewChat(
                  _authService.user!.uid, result.uid!);
            }
            _navigationService
                .push(MaterialPageRoute(builder: (context) {
              return ChatPage(
                chatUser: result,
              );
            }));
          },
        );
      },
    );
  }
}
