import 'package:astro44/ui/admin/admin.dart';
import 'package:astro44/ui/admin/admin_report_isfixed.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminSettings extends StatefulWidget {
  const AdminSettings({super.key});
  

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
  
}
Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

class _AdminSettingsState extends State<AdminSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Settings"),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('User Report'),
            onTap: () {
              Get.to(() => const AdminPage());
            },
          ),
          ListTile(
            title: const Text('Report is Fixed'),
            onTap: () {
              Get.to(() => AdminReportisFixed());
            },
          ),
          const ListTile(
            title: Text('Sign Out'),
            onTap: signOut,
          ),
        ],
      ),
    );
  }
}
