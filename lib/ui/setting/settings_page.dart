import 'package:astro44/ui/auth/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:astro44/ui/setting/settings_page.dart' show ProfielControlle;

class ProfielControlle extends GetxController {
  var username = 'username'.obs;
  var fullname = 'fullname'.obs;
  var email = 'email'.obs;
  var currentLocale = Locale('en', 'US').obs;

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
    currentLocale.value = Get.locale!;
  }

  void toggleLanguage() {
    if (currentLocale.value.languageCode == 'ar') {
      Get.updateLocale(const Locale('en', 'US'));
      currentLocale.value = const Locale('en', 'US');
    } else {
      Get.updateLocale(const Locale('ar', 'SA'));
      currentLocale.value = const Locale('ar', 'SA');
    }
  }
}

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ProfielControlle profileController = Get.put(ProfielControlle());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings Page'.tr),
        backgroundColor: Colors.grey[500],
      ),
      body: GetBuilder<ProfielControlle>(
        init: ProfielControlle(),
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: SingleChildScrollView(
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
                      title: Text('Username'.tr),
                      subtitle: Text(controller.username.value),
                    ),
                    ListTile(
                      title: Text('Full Name'.tr),
                      subtitle: Text(controller.fullname.value),
                    ),
                    ListTile(
                      title: Text('Email'.tr),
                      subtitle: Text(controller.email.value),
                    ),
                    ElevatedButton(
                      onPressed: () => profileController.signOut(),
                      child: Text('Sign Out'.tr),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey, // background color
                        onPrimary: Colors.white, // text color
                        elevation: 5, // button's elevation
                        shape: RoundedRectangleBorder(
                          // button's shape
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed:
                          profileController.toggleLanguage, // Update this line
                      child: Obx(() {
                        String currentLocale =
                            profileController.currentLocale.value.languageCode;
                        return Text(currentLocale == 'ar'
                            ? 'Switch to English'.tr
                            : 'Switch to Arabic'.tr);
                      }),

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
            ),
          );
        },
      ),
    );
  }
}
