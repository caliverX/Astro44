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

  const NavigationBar({Key? key}) : super(key: key);

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
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: Colors.grey, // Change the navigation bar color here
      ),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.grey,
            body: NavigationBar._pages[_selectedIndex],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavigationBar(
              items:  <BottomNavigationBarItem>[
                BottomNavigationBarItem(backgroundColor: Colors.grey[300],
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
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}