import 'package:astro44/ui/home/pages/home_page.dart';
import 'package:astro44/ui/notification/notification_page.dart';
import 'package:astro44/ui/report/report_page.dart';
import 'package:astro44/ui/setting/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class MasterPage extends StatefulWidget {
  static final List<Widget> _pages = <Widget>[
    HomePage(),
    const ReportPage(),
    const NotificationPage(),
    const SettingsPage(),
  ];

  final User? user;

  const MasterPage({Key? key, this.user}) : super(key: key);

  @override
  State<MasterPage> createState() => _MasterPageState();
}

class _MasterPageState extends State<MasterPage> {
  int _selectedIndex = 0;
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          // Change the navigation bar color here
          ),
      child: Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.grey[500],
        actions: [
          IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))
        ],
      ),
        body: MasterPage._pages[_selectedIndex],
        bottomNavigationBar:
        
         AnimatedBottomNavigationBar(
          icons: const [
            
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
          backgroundColor:
              Colors.grey[500], // Set background color to grey[500]
          activeColor: Colors.black, // Set icon color to black
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}
