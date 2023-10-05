import 'package:astro44/ui/pages/home_page.dart';
import 'package:astro44/ui/pages/notification_page.dart';
import 'package:astro44/ui/pages/report_page.dart';
import 'package:astro44/ui/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class HomeNavigationBar extends StatefulWidget {
  static final List<Widget> _pages = <Widget>[
    HomePage(),
    const ReportPage(),
    const NotificationPage(),
    const SettingsPage(),
  ];

  const HomeNavigationBar({Key? key}) : super(key: key);

  @override
  State<HomeNavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<HomeNavigationBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
         // Change the navigation bar color here
      ),
      child: Scaffold(
        
        body: HomeNavigationBar._pages[_selectedIndex],
        bottomNavigationBar: AnimatedBottomNavigationBar(
          icons: [
            Icons.home,
            Icons.add_circle_sharp,
            Icons.notifications,
            Icons.settings,
          ],
          activeIndex: _selectedIndex,
          gapLocation: GapLocation.none,
          notchSmoothness: NotchSmoothness.defaultEdge,
          leftCornerRadius: 24,
          rightCornerRadius: 24,
          backgroundColor: Colors.grey[500], // Set background color to grey[500]
          activeColor: Colors.black, // Set icon color to black
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}
