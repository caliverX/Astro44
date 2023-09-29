import 'package:astro44/pages/home_page.dart';
import 'package:astro44/pages/notification_page.dart';
import 'package:astro44/pages/report_page.dart';
import 'package:astro44/pages/settings_page.dart';
import 'package:flutter/material.dart';

class NavigationBar extends StatefulWidget {
  static final List<Widget> _pages = <Widget>[
    HomePage(),
    const ReportPage(),
    const NotificationPage(),
    const SettingsPage(),
  ];

  const NavigationBar({super.key});

  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
      body: NavigationBar._pages[_selectedIndex],
    );
  }
}
