import 'package:brainsync/widgets/bottomBar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../services/auth_service.dart';
import '../services/navigation_service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final GetIt _getIt = GetIt.instance;

  int _selectedIndex = 0;

  late AuthService _authService;
  late NavigationService _navigationService;

  final double coverHeight = 280;
  final double profileHeight = 144;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          buildTop(),
          buildContent(),
        ],
      ),
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
                  _navigationService.pushName("/home");
                },
              ),
              GButton(
                icon: Icons.chat,
                text: "Chats",
                onPressed: () async {
                  _navigationService.pushNamed("/profile");
                },
              ),
              GButton(
                icon: Icons.qr_code,
                text: "QR",
                onPressed: () async {
                  _navigationService.pushNamed("/profile");
                },
              ),
              GButton(
                icon: Icons.person_2,
                text: "Profile",
              ),
            ],
            selectedIndex: 3,
            onTabChange: (index) {
              print(index);
            },
          ),
        ),
      ),
    );
  }

  Widget buildTop() {
    final double bottom = profileHeight / 2;
    final double top = coverHeight - profileHeight / 2;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
            margin: EdgeInsets.only(
              bottom: bottom,
            ),
            child: buildCoverImage()),
        Positioned(top: top, child: buildProfileImage()),
      ],
    );
  }

  Widget buildCoverImage() {
    return Container(
      color: Colors.grey,
      child: Image.network(
        'https://www.comp.nus.edu.sg/~ngne/WEFiles/Image/Gallery/ee8928e7-a052-4ad9-9e41-be48898249fa/c835da5a-2.jpg',
        height: coverHeight,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget buildProfileImage() {
    return CircleAvatar(
      radius: profileHeight / 2,
      backgroundColor: Colors.grey,
    );
  }

  Widget buildContent() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text('Name'),
        const SizedBox(height: 8),
        Text('What Year'),
        const SizedBox(height: 16),
        Divider(),
        const SizedBox(height: 16),
      ],
    );
  }
}
