import 'package:astro44/ui/home/components/map_page.dart';
import 'package:astro44/ui/home/controllers/map_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final MapController c = Get.put(MapController())..getMap();

    return Obx(() {
      switch (c.status.value) {
        case Status.loading:
          {
            return const Center(child: CircularProgressIndicator());
          }
        case Status.success:
          return MapPage(markers: c.report);

        case Status.error:
          return  Center(child: Text(c.error.value));
      }
    });

    // return FutureBuilder<Widget?>(
    //     future: MapPage.create(),
    //     builder: (context, snapshot) {
    //       if (snapshot.hasData) {
    //         return snapshot.data!;
    //       } else if (snapshot.hasError) {
    //         return Text('Error: ${snapshot.error}');
    //       } else {
    //         return const CircularProgressIndicator();
    //       }
    //     },

    // );
  }
}
