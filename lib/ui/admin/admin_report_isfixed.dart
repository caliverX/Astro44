import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AdminReportisFixedController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<DocumentSnapshot> documents = RxList<DocumentSnapshot>();
  final RxList<DocumentSnapshot> filteredDocuments = RxList<DocumentSnapshot>();

  @override
  void onInit() {
    super.onInit();
    _firestore.collectionGroup('notifications').snapshots().listen((snapshot) {
      documents.value = snapshot.docs;
      filteredDocuments.value =
          snapshot.docs.where((doc) => doc['isfixed'] == false).toList();
    });
  }

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
      icon: "@mipmap/ic_launcher",
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'notification',
    );
  }

  Future<void> _updateIsFixed(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({
      'isfixed': true,
      'message': 'Your report has been fixed by the government'
    });
  }
}

class AdminReportisFixed extends StatelessWidget {
  AdminReportisFixed({Key? key}) : super(key: key);

  final AdminReportisFixedController controller =
      Get.put(AdminReportisFixedController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Obx(() {
      if (controller.filteredDocuments.isEmpty) {
        return const Center(
          child: Text(
            'There is nothing to show here.',
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey,
            ),
          ),
        );
      }
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF450075),
              Color(0xFF002244),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: controller.filteredDocuments
                .map(
                  (doc) => Card(
                    child: ListTile(
                      title: Text(
                        doc['message'],
                        style: const TextStyle(fontSize: 16),
                      ),
                      subtitle: Text(
                        doc['description'],
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      leading: Image.network(
                        doc['image_url'],
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () {
                          final userId = doc.reference.parent.parent!.id;
                          final notificationId = doc.id;
                          controller._updateIsFixed(userId, notificationId);
                          controller._showNotification('Report Approved',
                              'Your report has been fixed by goverment .');
                        },
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Column(
                                children: [
                                  Image.network(doc['image_url']),
                                  Text(doc['description']),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                )
                .expand((card) => [card, const Divider()])
                .toList(),
          ),
        ),
      );
    }));
  }
}
