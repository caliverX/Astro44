import 'package:astro44/ui/admin/admin_controller.dart';
import 'package:astro44/ui/admin/admin_settings.dart';
import 'package:astro44/ui/home/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class AdminMasterPage extends StatefulWidget {
  static final List<Widget> _pages = <Widget>[
    HomePage(),
    const AdminSettings(),
  ];

  const AdminMasterPage({super.key});

  @override
  State<AdminMasterPage> createState() => _AdminMasterPageState();
}

class _AdminMasterPageState extends State<AdminMasterPage> {
  final AdminController controller = Get.put(AdminController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => AdminMasterPage._pages[controller.tabIndex.value]),
      bottomNavigationBar: Obx(() {
        return AnimatedBottomNavigationBar(
          icons: const [Icons.home, Icons.settings],
          activeIndex: controller.tabIndex.value,
          gapLocation: GapLocation.none,
          notchSmoothness: NotchSmoothness.defaultEdge,
          leftCornerRadius: 24,
          rightCornerRadius: 24,
          onTap: (index) => controller.changeTabIndex(index),
        );
      }),
    );
  }
}