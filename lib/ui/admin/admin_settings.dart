import 'package:astro44/ui/admin/admin.dart';
import 'package:astro44/ui/admin/admin_analyse_route.dart';
import 'package:astro44/ui/admin/admin_report_isfixed.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:astro44/ui/admin/admin_settings.dart' show ProfielController;

class ProfielController extends GetxController {
  var currentLocale = Locale('en', 'US').obs;

  Future<void> loadUserData() async {
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

class AdminSettings extends StatefulWidget {
  const AdminSettings({super.key});

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}

class _AdminSettingsState extends State<AdminSettings> {
  ProfielController profileController = Get.put(ProfielController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Settings".tr),
      ),
      body: GetBuilder<ProfielController>(
        init: ProfielController(),
        builder: (controller) {
          return ListView(
            children: <Widget>[
              ListTile(
                title: Text('User Report'.tr),
                onTap: () {
                  Get.to(() => const AdminPage());
                },
              ),
              ListTile(
                title: Text('Report is Fixed'.tr),
                onTap: () {
                  Get.to(() => AdminReportisFixed());
                },
              ),
              ListTile(
                title: Text('Analysing the reports'.tr),
                onTap: () {
                  Get.to(() => AdminAnalyseRoute());
                },
              ),
              ListTile(
                title: Text('Sign Out'.tr),
                onTap: signOut,
              ),
              ListTile(
                title: Obx(() {
                  String currentLocale =
                      profileController.currentLocale.value.languageCode;
                  return Text(currentLocale == 'ar'
                      ? 'Switch to English'.tr
                      : 'Switch to Arabic'.tr);
                }),
                onTap: profileController.toggleLanguage,
              ),
            ],
          );
        },
      ),
    );
  }
}
