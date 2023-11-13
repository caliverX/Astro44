import 'package:astro44/ui/auth/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfielController extends GetxController {
  var username = 'username'.obs;
  var fullname = 'fullname'.obs;
  var email = 'email'.obs;

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        username.value = data['username'];
        fullname.value = data['fullname'];
      } else {
        Get.snackbar('Error', 'User not found');
      }
    }
  }
}

class SettingsPage extends StatelessWidget {
  final ProfielController profileController = Get.put(ProfielController());

  SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Page'),
        backgroundColor: Colors.grey[500],
      ),
      body: GetBuilder<ProfielController>(
        init: ProfielController(),
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 50,
                      child: Icon(
                        Icons.person,
                        size: 50,
                      ),
                      // This is the user icon
                      backgroundColor: Colors.grey,
                    ),
                  ),
                  ListTile(
                    title: const Text('Username'),
                    subtitle: Text(controller.username.value),
                  ),
                  ListTile(
                    title: const Text('Full Name'),
                    subtitle: Text(controller.fullname.value),
                  ),
                  ListTile(
                    title: const Text('Email'),
                    subtitle: Text(controller.email.value),
                  ),
                  ElevatedButton(
                    onPressed: () => profileController.signOut(),
                    child: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey, // background color
                      onPrimary: Colors.white, // text color
                      elevation: 5, // button's elevation
                      shape: RoundedRectangleBorder(
                        // button's shape
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
