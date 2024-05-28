import 'package:brainsync/common_widgets/chat_tile.dart';
import 'package:brainsync/common_widgets/search_bar.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../model/user_profile.dart';
import '../services/navigation_service.dart';
import 'package:brainsync/pages/chat.dart';

import 'post.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({super.key});

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  final GetIt _getIt = GetIt.instance;

  late NavigationService _navigationService;
  late DatabaseService _databaseService;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'BrainSync',
          style: TextStyle(),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _navigationService.pushName("/addFriends");
            },
            icon: Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearch(),
              );
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: SingleChildScrollView(child: _buildUI()),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 20,
          ),
          child: GNav(
            backgroundColor: Colors.black,
            tabBackgroundColor: Colors.grey,
            color: Colors.white,
            activeColor: Colors.white,
            gap: 8,
            tabs: [
              GButton(
                icon: Icons.home,
                text: "Home",
                onPressed: () async {
                  _navigationService.pushName(
                    "/home",
                  );
                },
              ),
              GButton(
                icon: Icons.chat,
                text: "Chats",
              ),
              GButton(
                icon: Icons.add,
                text: "Create",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostsPage()),
                  );
                },
              ),
              GButton(
                icon: Icons.person_2,
                text: "Profile",
                onPressed: () async {
                  _navigationService.pushName("/profile");
                },
              ),
            ],
            selectedIndex: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildUI() {
    return Column(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 20.0,
            ),
            child: _chatList(),
          ),
        ),
      ],
    );
  }

  Widget _chatList() {
    return StreamBuilder(
      stream: _databaseService.getUserProfiles(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Unable to load data"),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          final users = snapshot.data!.docs;
          return ListView.builder(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (context, index) {
              UserProfile? user = users[index].data();
              print(user.firstName);
              if (user != null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: ChatTile(
                    userProfile: user,
                    onTap: () async {
                      final chatExists = await _databaseService.checkChatExist(
                          _authService.user!.uid, user.uid!);
                      if (!chatExists) {
                        await _databaseService.createNewChat(
                            _authService.user!.uid, user.uid!);
                      }
                      _navigationService.push(MaterialPageRoute(builder: (context) {
                        return ChatPage(
                          chatUser: user,
                        );
                      }));
                    },
                  ),
                );
              } else {
                return SizedBox(); // Return an empty SizedBox if user is null
              }
            },
          );

        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
