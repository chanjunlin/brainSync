// import 'package:curved_navigation_bar_with_label/curved_navigation_bar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class Testing extends StatefulWidget {
  const Testing({Key? key}) : super(key: key);

  @override
  State<Testing> createState() => _TestingState();
}

class _TestingState extends State<Testing> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Text('Home'),
    Text('Chats'),
    Text('Post'), // Placeholder for the middle tab
    Text('Notifications'),
    Text('Profile'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.transparent,
          buttonBackgroundColor: Colors.brown[300],
          color: Colors.brown.shade300,
          animationDuration: const Duration(milliseconds: 200),
          items: <Widget>[
            GestureDetector(
              child: Icon(
                Icons.home,
                size: 26,
                color: Colors.white,
              ),
              onTap: () {},
            ),
            GestureDetector(
              child: Icon(
                Icons.add,
                size: 26,
                color: Colors.white,
              ),
              onTap: () {},
            ),
            GestureDetector(
              child: Icon(
                Icons.add,
                size: 26,
                color: Colors.white,
              ),
              onTap: () {},
            ),
            GestureDetector(
              child: Icon(
                Icons.notifications,
                size: 26,
                color: Colors.white,
              ),
              onTap: () {},
            ),
            GestureDetector(
              child: Icon(
                Icons.person,
                size: 26,
                color: Colors.white,
              ),
              onTap: () {},
            ),
          ],
          onTap: (index) {
            setState(() {});
          }),
    );
  }
}
