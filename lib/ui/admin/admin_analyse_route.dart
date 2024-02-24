import 'package:astro44/ui/admin/admin_analyse.dart';
import 'package:astro44/ui/admin/admin_analyse_type.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnalyseController extends GetxController {}

class AdminAnalyseRoute extends StatefulWidget {
  const AdminAnalyseRoute({super.key});
  @override
  State<AdminAnalyseRoute> createState() => _AdminAnalyseRouteState();
}

class _AdminAnalyseRouteState extends State<AdminAnalyseRoute> {
  AnalyseController profileController = Get.put(AnalyseController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Analyse".tr),
      ),
      body: GetBuilder<AnalyseController>(
        init: AnalyseController(),
        builder: (controller) {
          return ListView(
            children: <Widget>[
              ListTile(
                title: Text('Analyse by Date and type and Street'.tr),
                onTap: () {
                  Get.to(() =>  AdminAnalyzePage());
                },
              ),
              ListTile(
                title: Text('Report is Fixed'.tr),
                onTap: () {
                  Get.to(() => AdminAnalyze());
                },
              )
            ],
          );
        },
      ),
    );
  }
}
