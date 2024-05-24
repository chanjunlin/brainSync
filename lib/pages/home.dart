import 'dart:convert';

import 'package:brainsync/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:brainsync/navBar.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:core';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final User? user = AuthService().currentUser;
  List _items =[];

  Future<void> getMods() async {
    var url = await http.get(Uri.https("api.nusmods.com", "v2/2018-2019/modules/CS2040.json"));
    var jsonData = await jsonDecode(url.body);
    for (var mods in jsonData)
      print(mods);
  }

  @override
  Widget build(BuildContext context) {
    getMods();

    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'BrainSync',
          style: TextStyle(),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Hi, ${user?.email}!"),
                      SizedBox(height: 10),
                      Text("Welcome Back!"),
                    ],
                  ),
                ),
                Container(
                  child: Text("Insert QR CODE here"),
                ),
              ],
            ),
          ),
          Divider(),
          Container(),
          Divider(),
          Container(),


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
            onTabChange: (index) {
              print(index);
            },
            tabs: [
              GButton(icon: Icons.home, text: "Home"),
              GButton(icon: Icons.chat, text: "Chats"),
              GButton(icon: Icons.qr_code, text: "QR"),
              GButton(icon: Icons.person_2, text: "Profile"),
            ],
          ),
        ),
      ),
    );
  }
}
